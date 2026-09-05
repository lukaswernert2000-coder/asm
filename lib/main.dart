import 'package:asm/app.dart';
import 'package:asm/core/config/app_config.dart';
import 'package:asm/core/storage/shared_preferences_provider.dart';
import 'package:asm/features/chat/presentation/chat_providers.dart';
import 'package:asm/features/listings/presentation/create_listing_providers.dart';
import 'package:asm/features/listings/presentation/listing_providers.dart';
import 'package:asm/features/notifications/presentation/notification_providers.dart';
import 'package:asm/features/notifications/presentation/push_notification_service.dart';
import 'package:asm/features/onboarding/presentation/onboarding_providers.dart';
import 'package:asm/features/search/presentation/search_history_providers.dart';
import 'package:asm/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  AppConfig.assertValid();

  await SentryFlutter.init(
    (options) {
      options
        ..dsn = AppConfig.sentryDsn
        ..sendDefaultPii = false
        ..environment = AppConfig.environment
        ..tracesSampleRate = AppConfig.isProd ? 0.2 : 1.0;
    },
    appRunner: () async {
      await Supabase.initialize(
        url: AppConfig.supabaseUrl,
        publishableKey: AppConfig.supabaseAnonKey,
      );
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      // Muss vor runApp() registriert sein: laeuft in einer eigenen Isolate,
      // wenn eine Nachricht eintrifft, waehrend die App im Hintergrund oder
      // komplett beendet ist.
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
      final prefs = await SharedPreferencesWithCache.create(
        cacheOptions: const SharedPreferencesWithCacheOptions(
          allowList: {
            hasSeenOnboardingPrefsKey,
            listingViewModePrefsKey,
            searchHistoryPrefsKey,
            createListingDraftPrefsKey,
            hiddenConversationsPrefsKey,
            hasRequestedNotificationPermissionPrefsKey,
          },
        ),
      );
      runApp(
        ProviderScope(
          overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
          child: const AsmApp(),
        ),
      );
    },
  );
}
