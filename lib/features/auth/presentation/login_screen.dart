import 'package:asm/core/errors/app_exception.dart';
import 'package:asm/core/router/routes.dart';
import 'package:asm/core/theme/asm_colors.dart';
import 'package:asm/core/theme/asm_spacing.dart';
import 'package:asm/core/theme/asm_text_styles.dart';
import 'package:asm/core/widgets/asm_button.dart';
import 'package:asm/core/widgets/asm_text_field.dart';
import 'package:asm/features/auth/presentation/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _submitting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    for (final controller in [_emailController, _passwordController]) {
      controller.addListener(() => setState(() {}));
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool get _isValid =>
      _emailController.text.isNotEmpty && _passwordController.text.isNotEmpty;

  Future<void> _submit() async {
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      await ref
          .read(authRepositoryProvider)
          .signIn(
            email: _emailController.text,
            password: _passwordController.text,
          );
      // Navigation nach Erfolg: globaler Listener in app.dart auf
      // authEventProvider (AuthChangeEvent.signedIn), nicht hier -- derselbe
      // Mechanismus greift auch beim asm://auth-callback Deep Link.
    } on AppException catch (_) {
      // Absichtlich immer dieselbe Meldung, unabhaengig vom tatsaechlichen
      // Fehler -- alles andere waere eine Nutzer-Enumeration (falsches
      // Passwort vs. unbekannte E-Mail unterscheidbar zu machen).
      if (!mounted) return;
      setState(() => _error = 'E-Mail oder Passwort ist falsch');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Anmelden')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AsmSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AsmTextField(controller: _emailController, label: 'E-Mail'),
            const SizedBox(height: AsmSpacing.md),
            AsmTextField(
              controller: _passwordController,
              label: 'Passwort',
              obscureText: true,
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => context.go(AsmRoutes.forgotPassword),
                child: Text(
                  'Passwort vergessen?',
                  style: AsmTextStyles.bodyM.copyWith(
                    color: AsmColors.brandBright,
                  ),
                ),
              ),
            ),
            if (_error != null) ...[
              Text(
                _error!,
                style: AsmTextStyles.bodyS.copyWith(
                  color: AsmColors.dangerText,
                ),
              ),
              const SizedBox(height: AsmSpacing.md),
            ],
            AsmButton(
              label: 'Anmelden',
              isLoading: _submitting,
              onPressed: _isValid && !_submitting ? _submit : null,
            ),
            const SizedBox(height: AsmSpacing.lg),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Noch kein Konto?',
                  style: AsmTextStyles.bodyM.copyWith(
                    color: AsmColors.textSecondary,
                  ),
                ),
                TextButton(
                  onPressed: () => context.go(AsmRoutes.register),
                  child: Text(
                    'Registrieren',
                    style: AsmTextStyles.bodyM.copyWith(
                      color: AsmColors.brandBright,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
