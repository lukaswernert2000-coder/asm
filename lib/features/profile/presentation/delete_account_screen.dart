import 'package:asm/core/errors/app_exception.dart';
import 'package:asm/core/router/routes.dart';
import 'package:asm/core/theme/asm_colors.dart';
import 'package:asm/core/theme/asm_spacing.dart';
import 'package:asm/core/theme/asm_text_styles.dart';
import 'package:asm/core/widgets/asm_button.dart';
import 'package:asm/core/widgets/asm_error_view.dart';
import 'package:asm/core/widgets/asm_skeleton.dart';
import 'package:asm/core/widgets/asm_text_field.dart';
import 'package:asm/features/auth/presentation/auth_controller.dart';
import 'package:asm/features/profile/presentation/profile_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

void _noop() {}

class DeleteAccountScreen extends ConsumerStatefulWidget {
  const DeleteAccountScreen({super.key});

  @override
  ConsumerState<DeleteAccountScreen> createState() =>
      _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends ConsumerState<DeleteAccountScreen> {
  final _confirmController = TextEditingController();
  bool _deleting = false;

  @override
  void dispose() {
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _confirmAndDelete(String username) async {
    _confirmController.clear();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => _DeleteConfirmationDialog(
        username: username,
        controller: _confirmController,
      ),
    );
    if (confirmed != true) return;
    if (!mounted) return;

    setState(() => _deleting = true);
    try {
      await ref.read(authRepositoryProvider).deleteAccount();
      if (!mounted) return;
      context.go(AsmRoutes.login);
    } on AppException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
    } finally {
      if (mounted) setState(() => _deleting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(currentProfileProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Account löschen')),
      body: profileAsync.when(
        loading: () => const Padding(
          padding: EdgeInsets.all(AsmSpacing.md),
          child: AsmSkeleton.detail(),
        ),
        error: (error, stackTrace) => AsmErrorView(
          message: 'Profil konnte nicht geladen werden',
          onRetry: () => ref.invalidate(currentProfileProvider),
        ),
        data: (profile) => profile == null
            ? const AsmErrorView(message: 'Nicht angemeldet', onRetry: _noop)
            : Padding(
                padding: const EdgeInsets.all(AsmSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Dein Konto wird endgültig gelöscht',
                      style: AsmTextStyles.titleL,
                    ),
                    const SizedBox(height: AsmSpacing.sm),
                    Text(
                      'Alle deine Inserate, Nachrichten, Favoriten und dein '
                      'Profil werden unwiderruflich entfernt. Das kann nicht '
                      'rückgängig gemacht werden.',
                      style: AsmTextStyles.bodyM.copyWith(
                        color: AsmColors.textSecondary,
                      ),
                    ),
                    const Spacer(),
                    AsmButton(
                      label: 'Account löschen',
                      variant: AsmButtonVariant.danger,
                      isLoading: _deleting,
                      onPressed: _deleting
                          ? null
                          : () => _confirmAndDelete(profile.username),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

class _DeleteConfirmationDialog extends StatelessWidget {
  const _DeleteConfirmationDialog({
    required this.username,
    required this.controller,
  });

  final String username;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Bist du sicher?'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Tippe deinen Nutzernamen "$username" ein, um zu bestätigen.'),
          const SizedBox(height: AsmSpacing.sm),
          AsmTextField(controller: controller, label: 'Nutzername'),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Abbrechen'),
        ),
        ValueListenableBuilder<TextEditingValue>(
          valueListenable: controller,
          builder: (context, value, _) => TextButton(
            onPressed: value.text == username
                ? () => Navigator.of(context).pop(true)
                : null,
            child: const Text('Endgültig löschen'),
          ),
        ),
      ],
    );
  }
}
