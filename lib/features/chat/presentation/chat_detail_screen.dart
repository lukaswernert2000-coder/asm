import 'dart:async';

import 'package:asm/core/config/app_config.dart';
import 'package:asm/core/router/routes.dart';
import 'package:asm/core/theme/asm_colors.dart';
import 'package:asm/core/theme/asm_spacing.dart';
import 'package:asm/core/theme/asm_text_styles.dart';
import 'package:asm/core/widgets/asm_empty_state.dart';
import 'package:asm/core/widgets/asm_error_view.dart';
import 'package:asm/features/auth/presentation/auth_controller.dart';
import 'package:asm/features/chat/domain/conversation.dart';
import 'package:asm/features/chat/presentation/chat_providers.dart';
import 'package:asm/features/chat/presentation/widgets/chat_bubble.dart';
import 'package:asm/features/chat/presentation/widgets/listing_chip.dart';
import 'package:asm/features/listings/domain/listing_image_url.dart';
import 'package:asm/features/listings/presentation/listing_providers.dart';
import 'package:asm/features/moderation/presentation/moderation_providers.dart';
import 'package:asm/features/moderation/presentation/widgets/report_sheet.dart';
import 'package:asm/features/notifications/presentation/notification_providers.dart';
import 'package:asm/features/notifications/presentation/push_notification_service.dart';
import 'package:asm/features/profile/presentation/profile_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Chat-Detailseite (Task 6.2). Erreichbar ueber die Chatliste oder
/// `ListingDetailScreen`s "Nachricht schreiben" -- beide erreichen sie per
/// `push()`, ein Zurueck-Pfeil ist deshalb immer vorhanden (anders als bei
/// der Inserats-Detailseite, siehe dort `_detailAppBar`).
class ChatDetailScreen extends ConsumerWidget {
  const ChatDetailScreen({required this.conversationId, super.key});

  final String conversationId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final conversationAsync = ref.watch(
      conversationByIdProvider(conversationId),
    );

    return conversationAsync.when(
      loading: () => Scaffold(appBar: AppBar(title: const Text('Chat'))),
      error: (error, stackTrace) => Scaffold(
        appBar: AppBar(title: const Text('Chat')),
        body: AsmErrorView(
          message: 'Chat konnte nicht geladen werden',
          onRetry: () =>
              ref.invalidate(conversationByIdProvider(conversationId)),
        ),
      ),
      data: (conversation) => _ChatDetailScaffold(conversation: conversation),
    );
  }
}

Future<void> _deleteChat(
  BuildContext context,
  WidgetRef ref,
  String conversationId,
) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Chat löschen?'),
      content: const Text(
        'Der Chat wird aus deiner Liste entfernt. Schreibt die Gegenseite '
        'wieder, taucht er erneut auf.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Abbrechen'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Löschen bestätigen'),
        ),
      ],
    ),
  );
  if (confirmed != true) return;
  if (!context.mounted) return;
  await ref.read(hiddenConversationIdsProvider.notifier).hide(conversationId);
  if (context.mounted && context.canPop()) context.pop();
}

class _ChatDetailScaffold extends ConsumerStatefulWidget {
  const _ChatDetailScaffold({required this.conversation});

  final Conversation conversation;

  @override
  ConsumerState<_ChatDetailScaffold> createState() =>
      _ChatDetailScaffoldState();
}

class _ChatDetailScaffoldState extends ConsumerState<_ChatDetailScaffold>
    with WidgetsBindingObserver {
  final _controller = TextEditingController();
  // `ref` ist in `dispose()` schon ungueltig -- den Notifier stattdessen
  // hier festhalten, das Objekt selbst lebt unabhaengig vom Widget im
  // Provider-Container weiter, `.clear()` darauf braucht kein `ref` mehr.
  OpenConversationNotifier? _openConversationNotifier;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    unawaited(
      Future.microtask(() {
        if (!mounted) return;
        final notifier = ref.read(openConversationIdProvider.notifier)
          ..open = widget.conversation.id;
        _openConversationNotifier = notifier;
        unawaited(
          ref.read(chatRepositoryProvider).markRead(widget.conversation.id),
        );
      }),
    );
  }

  // Push-Unterdrueckung fuer den gerade offenen Chat (Task 6.3) gilt nur,
  // solange die App wirklich im Vordergrund ist -- ohne das hier bliebe ein
  // im Hintergrund liegender Chat "offen" und wuerde faellig eintreffende
  // Nachrichten faelschlich stumm schalten.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!mounted) return;
    final notifier = ref.read(openConversationIdProvider.notifier);
    if (state == AppLifecycleState.resumed) {
      notifier.open = widget.conversation.id;
    } else {
      notifier.clear();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _openConversationNotifier?.clear();
    _controller.dispose();
    super.dispose();
  }

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    unawaited(
      ref
          .read(pendingMessagesProvider(widget.conversation.id).notifier)
          .send(text),
    );
    _controller.clear();
    // Kontextbezogene Berechtigungsanfrage nach der ersten gesendeten
    // Nachricht statt beim App-Start (Task 6.3) -- deutlich hoehere
    // Zustimmungsrate. `markNotificationPermissionRequested` laeuft zuerst,
    // damit ein zweiter schneller Tap auf Senden nicht doppelt anfragt.
    if (!ref.read(hasRequestedNotificationPermissionProvider)) {
      unawaited(_requestPushPermissionOnce());
    }
  }

  Future<void> _requestPushPermissionOnce() async {
    await markNotificationPermissionRequested(ref);
    // requestPermissionAndRegisterTokenIfNeeded() ist intern bereits
    // best-effort (siehe PushNotificationService._guard) -- kein eigenes
    // try/catch noetig.
    await ref
        .read(pushNotificationServiceProvider)
        .requestPermissionAndRegisterTokenIfNeeded();
  }

  @override
  Widget build(BuildContext context) {
    final conversation = widget.conversation;
    final currentUserId = ref.watch(currentUserProvider)?.id;
    final otherId = currentUserId == null
        ? conversation.buyerId
        : otherUserId(conversation, currentUserId);
    final otherAsync = ref.watch(profileByIdProvider(otherId));
    final other = otherAsync.valueOrNull;
    final listingAsync = ref.watch(
      listingByIdProvider(conversation.listingId),
    );
    final listing = listingAsync.valueOrNull;
    final imagePathsAsync = ref.watch(
      listingImagePathsProvider(conversation.listingId),
    );
    final imageUrl = listingImageUrl(
      supabaseUrl: AppConfig.supabaseUrl,
      path: imagePathsAsync.valueOrNull?.firstOrNull,
    );
    final messages =
        ref.watch(conversationMessagesProvider(conversation.id)).valueOrNull ??
        [];
    final pending = ref.watch(pendingMessagesProvider(conversation.id));

    // markRead erneut, wenn waehrend des offenen Chats neue fremde
    // Nachrichten eintreffen -- sonst bliebe der Ungelesen-Punkt in der
    // Chatliste faelschlich stehen, bis der Chat neu geoeffnet wird. Der
    // erste Ladevorgang (previous ohne Wert) wird uebersprungen, dafuer
    // sorgt schon initState -- sonst liefe markRead beim Oeffnen doppelt.
    ref.listen(conversationMessagesProvider(conversation.id), (
      previous,
      next,
    ) {
      if (previous?.hasValue != true) return;
      final incoming = next.valueOrNull;
      if (incoming == null || currentUserId == null) return;
      if (hasUnread(incoming, currentUserId)) {
        unawaited(
          ref.read(chatRepositoryProvider).markRead(conversation.id),
        );
      }
    });

    // `messages` kommt absteigend (neueste zuerst) aus dem Provider (Supabase
    // `.order()` ohne `ascending:` ist bereits descending) -- zusammen mit
    // `ListView.builder(reverse: true)` unten reicht das allein noch nicht:
    // `pending` muss VOR `messages` stehen und selbst umgekehrt (neuestes
    // Pending zuerst), sonst landen gerade gesendete Nachrichten optisch
    // ueber statt unter der zuletzt bestaetigten -- damit am Ende unten die
    // neueste und oben die aelteste Nachricht steht, wie in Chat-Apps ueblich.
    final bubbles = <Widget>[
      for (final p in pending.reversed)
        ChatBubble(
          body: p.body,
          isOwn: true,
          status: p.failed ? ChatBubbleStatus.failed : ChatBubbleStatus.sending,
          onRetry: p.failed
              ? () => ref
                    .read(pendingMessagesProvider(conversation.id).notifier)
                    .retry(p.localId)
              : null,
        ),
      for (final message in messages)
        ChatBubble(
          body: message.body ?? '',
          isOwn: message.senderId == currentUserId,
          timestamp: message.createdAt,
          isRead: message.readAt != null,
        ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(other?.displayName ?? other?.username ?? 'Chat'),
        actions: [
          PopupMenuButton<VoidCallback>(
            icon: const Icon(LucideIcons.moreVertical),
            onSelected: (action) => action(),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: () => showReportUserFlow(
                  context,
                  ref,
                  userId: otherId,
                  username: other?.username ?? '',
                  loginRedirectPath: AsmRoutes.chat(conversation.id),
                ),
                child: const Text('Melden'),
              ),
              PopupMenuItem(
                value: () => showBlockUserFlow(
                  context,
                  ref,
                  userId: otherId,
                  username: other?.username ?? '',
                  loginRedirectPath: AsmRoutes.chat(conversation.id),
                ),
                child: const Text('Nutzer blockieren'),
              ),
              PopupMenuItem(
                value: () => _deleteChat(context, ref, conversation.id),
                child: const Text('Chat löschen'),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: bubbles.isEmpty
                ? Column(
                    children: [
                      if (listing != null)
                        Padding(
                          padding: const EdgeInsets.all(AsmSpacing.md),
                          child: ListingChip(
                            listing: listing,
                            imageUrl: imageUrl,
                            onTap: () =>
                                context.push(AsmRoutes.listing(listing.id)),
                          ),
                        ),
                      const Expanded(
                        child: AsmEmptyState(
                          icon: LucideIcons.messageSquare,
                          title: 'Noch keine Nachrichten',
                          message:
                              'Frag den Verkäufer, ob der Artikel noch da '
                              'ist.',
                        ),
                      ),
                    ],
                  )
                : ListView.builder(
                    reverse: true,
                    padding: const EdgeInsets.all(AsmSpacing.md),
                    itemCount: bubbles.length + (listing == null ? 0 : 1),
                    itemBuilder: (context, index) {
                      if (index == bubbles.length) {
                        return Padding(
                          padding: const EdgeInsets.only(
                            bottom: AsmSpacing.sm,
                          ),
                          child: ListingChip(
                            listing: listing!,
                            imageUrl: imageUrl,
                            onTap: () =>
                                context.push(AsmRoutes.listing(listing.id)),
                          ),
                        );
                      }
                      return bubbles[index];
                    },
                  ),
          ),
          _Composer(
            controller: _controller,
            onSend: _send,
            // Nur die eigene Blockierrichtung ist clientseitig bekannt
            // (siehe Kommentar auf `isBlockedByMe`) -- hat die Gegenseite
            // mich blockiert, faengt die RLS-Policy aus
            // `0014_blocks_stop_messaging.sql` den Sendeversuch ab.
            blocked:
                ref.watch(isBlockedByMeProvider(otherId)).valueOrNull ?? false,
          ),
        ],
      ),
    );
  }
}

class _Composer extends StatelessWidget {
  const _Composer({
    required this.controller,
    required this.onSend,
    required this.blocked,
  });

  final TextEditingController controller;
  final VoidCallback onSend;
  final bool blocked;

  @override
  Widget build(BuildContext context) {
    if (blocked) {
      return SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(AsmSpacing.md),
          child: Text(
            'Ihr könnt euch nicht mehr schreiben.',
            style: AsmTextStyles.bodyM.copyWith(
              color: AsmColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.all(AsmSpacing.sm),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Container(
                constraints: const BoxConstraints(minHeight: 40),
                padding: const EdgeInsets.symmetric(
                  horizontal: AsmSpacing.sm,
                ),
                decoration: BoxDecoration(
                  color: AsmColors.surface,
                  border: Border.all(color: AsmColors.border),
                  borderRadius: BorderRadius.circular(AsmRadius.lg),
                ),
                child: TextField(
                  controller: controller,
                  minLines: 1,
                  maxLines: 5,
                  style: AsmTextStyles.bodyM.copyWith(
                    color: AsmColors.textPrimary,
                  ),
                  cursorColor: AsmColors.brandBright,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    hintText: 'Nachricht schreiben...',
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(
                      vertical: AsmSpacing.sm,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: AsmSpacing.xs),
            Semantics(
              label: 'Senden',
              button: true,
              child: IconButton(
                onPressed: onSend,
                icon: const Icon(
                  LucideIcons.send,
                  color: AsmColors.brandBright,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
