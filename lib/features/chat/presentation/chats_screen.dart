import 'package:asm/core/config/app_config.dart';
import 'package:asm/core/router/routes.dart';
import 'package:asm/core/theme/asm_colors.dart';
import 'package:asm/core/theme/asm_spacing.dart';
import 'package:asm/core/theme/asm_text_styles.dart';
import 'package:asm/core/utils/formatters.dart';
import 'package:asm/core/widgets/asm_empty_state.dart';
import 'package:asm/core/widgets/asm_error_view.dart';
import 'package:asm/core/widgets/asm_network_image.dart';
import 'package:asm/core/widgets/asm_skeleton.dart';
import 'package:asm/features/auth/presentation/auth_controller.dart';
import 'package:asm/features/chat/domain/conversation.dart';
import 'package:asm/features/chat/presentation/chat_providers.dart';
import 'package:asm/features/listings/domain/listing_image_url.dart';
import 'package:asm/features/listings/presentation/listing_providers.dart';
import 'package:asm/features/profile/presentation/profile_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Chatliste (Task 6.2): eine Zeile pro Konversation, sortiert nach
/// `last_message_at` (bereits so von `ChatRepository.conversations()`
/// geliefert).
class ChatsScreen extends ConsumerWidget {
  const ChatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final conversationsAsync = ref.watch(visibleConversationsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Chats')),
      body: conversationsAsync.when(
        loading: () => const Padding(
          padding: EdgeInsets.all(AsmSpacing.md),
          child: AsmSkeleton.listingList(),
        ),
        error: (error, stackTrace) => AsmErrorView(
          message: 'Chats konnten nicht geladen werden',
          onRetry: () => ref.invalidate(conversationsProvider),
        ),
        data: (conversations) => conversations.isEmpty
            ? const AsmEmptyState(
                icon: LucideIcons.messageSquare,
                title: 'Noch keine Chats',
                message:
                    'Schreib einem Verkaeufer ueber ein Inserat, um hier '
                    'eine Konversation zu sehen.',
              )
            : ListView.separated(
                padding: const EdgeInsets.all(AsmSpacing.md),
                itemCount: conversations.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: AsmSpacing.sm),
                itemBuilder: (context, index) =>
                    _ChatRow(conversation: conversations[index]),
              ),
      ),
    );
  }
}

class _ChatRow extends ConsumerWidget {
  const _ChatRow({required this.conversation});

  final Conversation conversation;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUserId = ref.watch(currentUserProvider)?.id;
    final listingAsync = ref.watch(listingByIdProvider(conversation.listingId));
    final imagePathsAsync = ref.watch(
      listingImagePathsProvider(conversation.listingId),
    );
    final otherAsync = ref.watch(
      profileByIdProvider(
        currentUserId == null
            ? conversation.buyerId
            : otherUserId(conversation, currentUserId),
      ),
    );
    // Letzte Nachricht kommt direkt von `conversation` (auf `conversations`
    // denormalisiert, siehe 0012_conversations_last_message.sql) statt aus
    // conversationMessagesProvider: eine schon aufgebaute, aber gerade im
    // Hintergrund liegende Chatliste (z. B. nach dem Zurueckkehren von der
    // Chat-Detailseite) bekam Aktualisierungen dieses zweiten Streams beim
    // Live-Testen nicht zuverlaessig mit, siehe DECISIONS.md.
    final messages =
        ref.watch(conversationMessagesProvider(conversation.id)).valueOrNull ??
        [];
    final unread = currentUserId != null && hasUnread(messages, currentUserId);

    final listing = listingAsync.valueOrNull;
    if (listing == null) return const SizedBox.shrink();

    final imageUrl = listingImageUrl(
      supabaseUrl: AppConfig.supabaseUrl,
      path: imagePathsAsync.valueOrNull?.firstOrNull,
    );
    final other = otherAsync.valueOrNull;
    final time = Formatters.relativeTime(
      conversation.lastMessageAt ?? conversation.createdAt,
    );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => context.push(AsmRoutes.chat(conversation.id)),
        borderRadius: BorderRadius.circular(AsmRadius.md),
        child: SizedBox(
          height: 96,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(AsmRadius.md),
                child: SizedBox(
                  width: 96,
                  height: 96,
                  child: AsmNetworkImage(path: imageUrl),
                ),
              ),
              const SizedBox(width: AsmSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            listing.title,
                            style: AsmTextStyles.titleS,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: AsmSpacing.xs),
                        Text(
                          time,
                          style: AsmTextStyles.bodyS.copyWith(
                            color: AsmColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    if (other != null)
                      Text(
                        other.displayName ?? other.username,
                        style: AsmTextStyles.bodyS.copyWith(
                          color: AsmColors.textSecondary,
                        ),
                      ),
                    const SizedBox(height: AsmSpacing.xxs),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            conversation.lastMessageBody ?? '',
                            style: AsmTextStyles.bodyM.copyWith(
                              color: unread
                                  ? AsmColors.textPrimary
                                  : AsmColors.textSecondary,
                              fontWeight: unread
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (unread) ...[
                          const SizedBox(width: AsmSpacing.xs),
                          Container(
                            key: Key('unreadDot_${conversation.id}'),
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AsmColors.danger,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
