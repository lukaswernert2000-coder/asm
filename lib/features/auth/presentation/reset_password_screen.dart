import 'package:asm/core/errors/app_exception.dart';
import 'package:asm/core/router/routes.dart';
import 'package:asm/core/theme/asm_colors.dart';
import 'package:asm/core/theme/asm_spacing.dart';
import 'package:asm/core/theme/asm_text_styles.dart';
import 'package:asm/core/utils/validators.dart';
import 'package:asm/core/widgets/asm_button.dart';
import 'package:asm/core/widgets/asm_text_field.dart';
import 'package:asm/features/auth/presentation/auth_controller.dart';
import 'package:asm/features/auth/presentation/widgets/password_strength_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Erreichbar ausschliesslich ueber den `asm://reset-password`-Deep-Link
/// (globaler Listener in app.dart auf `authEventProvider`,
/// `AuthChangeEvent.passwordRecovery`), nicht ueber normale In-App-Navigation.
class ResetPasswordScreen extends ConsumerStatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  ConsumerState<ResetPasswordScreen> createState() =>
      _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final _passwordController = TextEditingController();

  bool _submitting = false;
  String? _submitError;

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  bool get _isValid => validatePassword(_passwordController.text) == null;

  Future<void> _submit() async {
    setState(() {
      _submitting = true;
      _submitError = null;
    });
    try {
      await ref
          .read(authRepositoryProvider)
          .updatePassword(_passwordController.text);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwort aktualisiert')),
      );
      context.go(AsmRoutes.home);
    } on AppException catch (error) {
      if (!mounted) return;
      setState(() {
        _submitting = false;
        _submitError = error.message;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Neues Passwort')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AsmSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AsmTextField(
              controller: _passwordController,
              label: 'Neues Passwort',
              obscureText: true,
            ),
            const SizedBox(height: AsmSpacing.xs),
            PasswordStrengthBar(password: _passwordController.text),
            const SizedBox(height: AsmSpacing.lg),
            if (_submitError != null) ...[
              Text(
                _submitError!,
                style: AsmTextStyles.bodyS.copyWith(
                  color: AsmColors.dangerText,
                ),
              ),
              const SizedBox(height: AsmSpacing.md),
            ],
            AsmButton(
              label: 'Passwort speichern',
              isLoading: _submitting,
              onPressed: _isValid && !_submitting ? _submit : null,
            ),
          ],
        ),
      ),
    );
  }
}
