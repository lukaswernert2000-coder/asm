import 'dart:async';

import 'package:asm/core/router/app_router.dart';
import 'package:asm/core/router/routes.dart';
import 'package:asm/features/notifications/domain/push_message.dart';
import 'package:asm/features/notifications/presentation/notification_providers.dart';
import 'package:asm/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

const _androidChannelId = 'chat_messages';
const _androidChannelName = 'Chat-Nachrichten';

final _localNotifications = FlutterLocalNotificationsPlugin();

/// Init ist idempotent und ohne `ref` aufrufbar -- muss sowohl von der
/// Haupt-Isolate (`PushNotificationService.initialize`) als auch von der
/// eigenen Hintergrund-Isolate (`firebaseMessagingBackgroundHandler`) aus
/// funktionieren, letztere hat keinen Zugriff auf den Riverpod-Container.
Future<void> _ensureLocalNotificationsInitialized({
  void Function(NotificationResponse)? onTap,
}) async {
  const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
  const iosSettings = DarwinInitializationSettings(
    // Keine eigene Anfrage hier -- FirebaseMessaging.requestPermission()
    // deckt iOS/Android einheitlich ab, siehe
    // PushNotificationService.requestPermissionAndRegisterTokenIfNeeded().
    requestAlertPermission: false,
    requestSoundPermission: false,
    requestBadgePermission: false,
  );
  await _localNotifications.initialize(
    settings: const InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    ),
    onDidReceiveNotificationResponse: onTap,
  );
  await _localNotifications
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >()
      ?.createNotificationChannel(
        const AndroidNotificationChannel(
          _androidChannelId,
          _androidChannelName,
          description: 'Benachrichtigungen über neue Chat-Nachrichten',
          importance: Importance.high,
        ),
      );
}

Future<void> _showMessageNotification(RemoteMessage message) async {
  final title = message.data['title'] as String? ?? 'Neue Nachricht';
  final body = message.data['body'] as String? ?? '';
  await _localNotifications.show(
    id: message.hashCode,
    title: title,
    body: body,
    notificationDetails: const NotificationDetails(
      android: AndroidNotificationDetails(
        _androidChannelId,
        _androidChannelName,
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
    ),
    payload: conversationIdFromPushData(message.data),
  );
}

/// Muss eine Top-Level-Funktion sein (kein Closure/keine Methode) und vor
/// `runApp()` registriert werden, siehe `main.dart` -- laeuft in einer
/// eigenen Isolate ohne Riverpod-Container, wenn die App im Hintergrund
/// oder komplett beendet ist. Datennachrichten (kein `notification`-Feld im
/// FCM-Payload, siehe die Edge Function) laufen deshalb *immer* durch
/// dieselbe `_showMessageNotification()` wie im Vordergrund -- ein
/// einziger Weg, Nachrichten anzuzeigen, statt zwei verschiedene Pfade
/// (FCM-Auto-Anzeige vs. lokale Notification) synchron halten zu muessen.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await _ensureLocalNotificationsInitialized();
  await _showMessageNotification(message);
}

/// Orchestriert FCM: Vordergrund-Anzeige (mit Unterdrueckung fuer den
/// gerade offenen Chat), Tap-Navigation und Geraetetoken-Lebenszyklus.
/// `initialize()` laeuft einmalig beim App-Start (`app.dart`).
class PushNotificationService {
  PushNotificationService(this._ref);

  final Ref _ref;

  /// Push ist eine Zusatzfunktion, kein Kernfluss -- ein Plattformkanal-
  /// Fehler hier (fehlende Play Services, Testumgebung ohne Firebase, o.ae.)
  /// darf App-Start, Login/Logout oder das Senden einer Nachricht nie zum
  /// Absturz bringen. Jede oeffentliche Methode laeuft deshalb durch diesen
  /// Guard statt einzeln try/catch zu wiederholen; Fehler gehen trotzdem an
  /// Sentry, damit ein kaputter Push nicht unbemerkt bleibt.
  Future<void> _guard(Future<void> Function() action) async {
    try {
      await action();
    } on Object catch (error, stackTrace) {
      unawaited(Sentry.captureException(error, stackTrace: stackTrace));
    }
  }

  Future<void> initialize() => _guard(() async {
    await _ensureLocalNotificationsInitialized(onTap: _onLocalNotificationTap);
    // Defaults (alert/badge/sound: false) sind bereits das gewuenschte
    // Verhalten -- iOS soll im Vordergrund nichts automatisch anzeigen,
    // _onForegroundMessage entscheidet das selbst (Unterdrueckung fuer den
    // gerade offenen Chat). Der Aufruf selbst ist trotzdem noetig, sonst
    // greift dieses explizite "nichts automatisch zeigen" nie.
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions();
    FirebaseMessaging.onMessage.listen(_onForegroundMessage);
    FirebaseMessaging.instance.onTokenRefresh.listen(
      (_) => unawaited(_registerIfAuthorized()),
    );
  });

  void _onForegroundMessage(RemoteMessage message) {
    final openConversationId = _ref.read(openConversationIdProvider);
    if (shouldSuppressPushForOpenChat(
      data: message.data,
      openConversationId: openConversationId,
    )) {
      return;
    }
    unawaited(_showMessageNotification(message));
  }

  void _onLocalNotificationTap(NotificationResponse response) {
    final conversationId = response.payload;
    if (conversationId == null || conversationId.isEmpty) return;
    unawaited(
      _ref.read(appRouterProvider).push(AsmRoutes.chat(conversationId)),
    );
  }

  /// Bei jedem Login den aktuellen Token neu registrieren, falls die
  /// Berechtigung in einer frueheren Session schon erteilt wurde -- ohne
  /// erneut zu fragen. Aufgerufen von `app.dart`s Auth-Event-Listener.
  Future<void> onSignedIn() => _guard(_registerIfAuthorized);

  /// Muss VOR dem eigentlichen `signOut()` aufgerufen werden, nicht als
  /// Reaktion auf das `signedOut`-Event: Supabase leert die lokale Session,
  /// bevor es das Event feuert, `auth.uid()` waere zu dem Zeitpunkt schon
  /// null und die RLS-Policy von `device_tokens` wuerde das DELETE auf 0
  /// Zeilen still verpuffen lassen. Siehe `profile_screen.dart`.
  Future<void> unregisterCurrentToken() => _guard(() async {
    final token = await FirebaseMessaging.instance.getToken();
    if (token == null) return;
    await _ref.read(deviceTokenRepositoryProvider).unregister(token);
  });

  Future<void> _registerIfAuthorized() async {
    final settings = await FirebaseMessaging.instance.getNotificationSettings();
    if (!_isGranted(settings)) return;
    await _registerCurrentToken();
  }

  /// Fragt die Berechtigung nur an, wenn sie noch nicht erteilt wurde --
  /// kontextbezogener Aufruf nach der ersten gesendeten Nachricht (Task 6.3),
  /// siehe `chat_detail_screen.dart`.
  Future<void> requestPermissionAndRegisterTokenIfNeeded() => _guard(() async {
    final current = await FirebaseMessaging.instance.getNotificationSettings();
    final settings = _isGranted(current)
        ? current
        : await FirebaseMessaging.instance.requestPermission();
    if (_isGranted(settings)) {
      await _registerCurrentToken();
    }
  });

  bool _isGranted(NotificationSettings settings) =>
      settings.authorizationStatus == AuthorizationStatus.authorized ||
      settings.authorizationStatus == AuthorizationStatus.provisional;

  Future<void> _registerCurrentToken() async {
    final token = await FirebaseMessaging.instance.getToken();
    if (token == null) return;
    await _ref
        .read(deviceTokenRepositoryProvider)
        .register(
          token: token,
          platform: defaultTargetPlatform == TargetPlatform.iOS
              ? 'ios'
              : 'android',
        );
  }
}

final Provider<PushNotificationService> pushNotificationServiceProvider =
    Provider<PushNotificationService>(PushNotificationService.new);
