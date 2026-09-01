import 'package:asm/core/theme/asm_colors.dart';
import 'package:asm/core/theme/asm_spacing.dart';
import 'package:asm/core/theme/asm_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

enum ChatBubbleStatus { sent, sending, failed }

/// Eine Chat-Nachricht. Siehe 01-DESIGN-SYSTEM.md Abschnitt 5.6.
///
/// Nimmt Primitiv-Werte statt eines `Message` entgegen, damit dieselbe
/// Bubble auch eine noch nicht bestaetigte, optimistisch gesendete
/// Nachricht darstellen kann (`PendingMessage` hat noch keinen
/// Server-Zeitstempel und keine `id`).
class ChatBubble extends StatelessWidget {
  const ChatBubble({
    required this.body,
    required this.isOwn,
    this.timestamp,
    this.isRead = false,
    this.status = ChatBubbleStatus.sent,
    this.onRetry,
    super.key,
  });

  final String body;
  final bool isOwn;
  final DateTime? timestamp;
  final bool isRead;
  final ChatBubbleStatus status;
  final VoidCallback? onRetry;

  String get _timeLabel {
    final t = timestamp;
    if (t == null) return '';
    final hour = t.hour.toString().padLeft(2, '0');
    final minute = t.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.only(
      topLeft: const Radius.circular(AsmRadius.lg),
      topRight: const Radius.circular(AsmRadius.lg),
      bottomLeft: Radius.circular(isOwn ? AsmRadius.lg : 4),
      bottomRight: Radius.circular(isOwn ? 4 : AsmRadius.lg),
    );

    return Align(
      alignment: isOwn ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.78,
        ),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: AsmSpacing.xxs),
          padding: const EdgeInsets.symmetric(
            horizontal: AsmSpacing.sm,
            vertical: AsmSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: isOwn ? AsmColors.brand : AsmColors.surfaceRaised,
            borderRadius: radius,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                body,
                style: AsmTextStyles.bodyM.copyWith(
                  color: AsmColors.textPrimary,
                ),
              ),
              const SizedBox(height: AsmSpacing.xxs),
              _StatusRow(
                timeLabel: _timeLabel,
                isOwn: isOwn,
                isRead: isRead,
                status: status,
                onRetry: onRetry,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusRow extends StatelessWidget {
  const _StatusRow({
    required this.timeLabel,
    required this.isOwn,
    required this.isRead,
    required this.status,
    required this.onRetry,
  });

  final String timeLabel;
  final bool isOwn;
  final bool isRead;
  final ChatBubbleStatus status;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    if (status == ChatBubbleStatus.failed) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Nicht gesendet',
            style: AsmTextStyles.bodyS.copyWith(color: AsmColors.dangerText),
          ),
          const SizedBox(width: AsmSpacing.xxs),
          Semantics(
            label: 'Erneut senden',
            button: true,
            child: InkWell(
              onTap: onRetry,
              child: const Icon(
                LucideIcons.refreshCw,
                size: 14,
                color: AsmColors.dangerText,
              ),
            ),
          ),
        ],
      );
    }

    if (status == ChatBubbleStatus.sending) {
      return const Icon(
        LucideIcons.clock,
        size: 14,
        color: AsmColors.textSecondary,
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          timeLabel,
          style: AsmTextStyles.bodyS.copyWith(color: AsmColors.textSecondary),
        ),
        if (isOwn && isRead) ...[
          const SizedBox(width: AsmSpacing.xxs),
          const Icon(
            LucideIcons.checkCheck,
            size: 14,
            color: AsmColors.brandHi,
          ),
        ],
      ],
    );
  }
}
