import 'package:asm/core/errors/app_exception.dart';
import 'package:asm/core/theme/asm_colors.dart';
import 'package:asm/core/theme/asm_spacing.dart';
import 'package:asm/core/theme/asm_text_styles.dart';
import 'package:asm/core/utils/validators.dart';
import 'package:asm/core/widgets/asm_button.dart';
import 'package:asm/core/widgets/asm_text_field.dart';
import 'package:asm/features/auth/presentation/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _emailController = TextEditingController();

  bool _submitting = false;
  bool _sent = false;
  String? _submitError;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  bool get _isValid => validateEmail(_emailController.text) == null;

  Future<void> _submit() async {
    setState(() {
      _submitting = true;
      _submitError = null;
    });
    try {
      await ref
          .read(authRepositoryProvider)
          .resetPassword(_emailController.text);
      if (!mounted) return;
      setState(() {
        _submitting = false;
        _sent = true;
      });
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
      appBar: AppBar(title: const Text('Passwort vergessen')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AsmSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_sent)
              Text(
                'Falls ein Konto mit dieser E-Mail-Adresse existiert, haben '
                'wir eine E-Mail zum Zurücksetzen des Passworts geschickt.',
                style: AsmTextStyles.bodyM.copyWith(
                  color: AsmColors.textSecondary,
                ),
              )
            else ...[
              AsmTextField(controller: _emailController, label: 'E-Mail'),
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
                label: 'Link anfordern',
                isLoading: _submitting,
                onPressed: _isValid && !_submitting ? _submit : null,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
