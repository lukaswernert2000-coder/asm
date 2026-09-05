import 'dart:async';

import 'package:asm/core/errors/app_exception.dart';
import 'package:asm/core/router/routes.dart';
import 'package:asm/core/theme/asm_colors.dart';
import 'package:asm/core/theme/asm_spacing.dart';
import 'package:asm/core/theme/asm_text_styles.dart';
import 'package:asm/core/utils/formatters.dart';
import 'package:asm/core/utils/validators.dart';
import 'package:asm/core/widgets/asm_button.dart';
import 'package:asm/core/widgets/asm_checkbox.dart';
import 'package:asm/core/widgets/asm_text_field.dart';
import 'package:asm/features/auth/presentation/auth_controller.dart';
import 'package:asm/features/auth/presentation/widgets/password_strength_bar.dart';
import 'package:asm/features/profile/presentation/profile_providers.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

Future<DateTime?> _defaultPickBirthDate(BuildContext context) {
  final now = DateTime.now();
  return showDatePicker(
    context: context,
    initialDate: DateTime(now.year - 18, now.month, now.day),
    firstDate: DateTime(now.year - 120),
    lastDate: now,
    // Nur Kalender, keine Tastatureingabe: der native Ziffernblock fuer
    // Datumseingabe zeigt auf manchen Android-Tastaturen keinen "."
    // (deutsches Trennzeichen TT.MM.JJJJ) an, das Geburtsdatum liess sich
    // dadurch nicht eintippen -- nur der Kalender funktionierte zuverlaessig.
    initialEntryMode: DatePickerEntryMode.calendarOnly,
  );
}

/// Dateien laut Plan-Task 2.2 nennen keinen zweiten Screen fuer die
/// "E-Mail bestaetigen"-Ansicht -- als interner Zustand dieses Screens
/// umgesetzt statt als eigene Route. Siehe DECISIONS.md.
class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({this.pickBirthDate = _defaultPickBirthDate, super.key});

  /// Seam statt `showDatePicker` direkt aufzurufen -- der native Dialog laesst
  /// sich in Widget-Tests nur fragil ueber lokalisierte Button-Texte steuern.
  final Future<DateTime?> Function(BuildContext context) pickBirthDate;

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _birthDateController = TextEditingController();

  // Task 7.2: die Pflicht-Checkboxen verlinken jetzt in die App
  // (LegalScreen) statt auf die externe Website.
  late final _agbLinkRecognizer = TapGestureRecognizer()
    ..onTap = () => context.push(AsmRoutes.legal('agb'));
  late final _datenschutzLinkRecognizer = TapGestureRecognizer()
    ..onTap = () => context.push(AsmRoutes.legal('datenschutz'));

  DateTime? _birthDate;
  bool _agbChecked = false;
  bool _datenschutzChecked = false;

  bool _submitAttempted = false;
  bool _submitting = false;
  bool _resending = false;
  String? _usernameTakenError;
  String? _submitError;

  bool _registered = false;
  String _registeredEmail = '';
  int _resendCooldown = 0;
  Timer? _cooldownTimer;

  @override
  void initState() {
    super.initState();
    for (final controller in [
      _usernameController,
      _emailController,
      _passwordController,
    ]) {
      controller.addListener(_onFieldChanged);
    }
  }

  void _onFieldChanged() {
    setState(() => _usernameTakenError = null);
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _birthDateController.dispose();
    _agbLinkRecognizer.dispose();
    _datenschutzLinkRecognizer.dispose();
    _cooldownTimer?.cancel();
    super.dispose();
  }

  String? get _usernameError =>
      validateUsername(_usernameController.text) ?? _usernameTakenError;
  String? get _emailError => validateEmail(_emailController.text);
  String? get _passwordError => validatePassword(_passwordController.text);
  String? get _birthDateError => validateBirthDate(_birthDate);
  String? get _consentError => validateConsent(
    agb: _agbChecked,
    datenschutz: _datenschutzChecked,
  );

  bool get _isValid =>
      _usernameError == null &&
      _emailError == null &&
      _passwordError == null &&
      _birthDateError == null &&
      _consentError == null;

  Future<void> _pickBirthDate() async {
    final picked = await widget.pickBirthDate(context);
    if (picked == null) return;
    setState(() {
      _birthDate = picked;
      _birthDateController.text = Formatters.date(picked);
    });
  }

  Future<void> _submit() async {
    setState(() => _submitAttempted = true);
    if (!_isValid) return;

    setState(() {
      _submitting = true;
      _submitError = null;
    });

    final username = _usernameController.text;
    final email = _emailController.text;

    try {
      final taken = await ref
          .read(profileRepositoryProvider)
          .isUsernameTaken(username);
      if (!mounted) return;
      if (taken) {
        setState(() {
          _usernameTakenError = 'Nutzername ist vergeben';
          _submitting = false;
        });
        return;
      }

      await ref
          .read(authRepositoryProvider)
          .signUp(
            email: email,
            password: _passwordController.text,
            data: {'username': username},
          );
      if (!mounted) return;
      setState(() {
        _submitting = false;
        _registered = true;
        _registeredEmail = email;
      });
    } on AppException catch (error) {
      if (!mounted) return;
      setState(() {
        _submitting = false;
        _submitError = error.message;
      });
    }
  }

  Future<void> _resend() async {
    setState(() => _resending = true);
    try {
      await ref
          .read(authRepositoryProvider)
          .resendConfirmation(_registeredEmail);
    } on AppException catch (_) {
      // Fehlgeschlagenes erneutes Senden blockiert den Cooldown nicht --
      // Nutzer kann es in 60s nochmal versuchen.
    }
    if (!mounted) return;
    setState(() => _resending = false);
    _startCooldown();
  }

  void _startCooldown() {
    setState(() => _resendCooldown = 60);
    _cooldownTimer?.cancel();
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendCooldown <= 1) {
        timer.cancel();
        setState(() => _resendCooldown = 0);
      } else {
        setState(() => _resendCooldown--);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registrieren')),
      body: SafeArea(
        child: _registered ? _buildConfirmEmail() : _buildForm(),
      ),
    );
  }

  Widget _buildForm() {
    final showErrors = _submitAttempted;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AsmSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AsmTextField(
            controller: _usernameController,
            label: 'Nutzername',
            errorText: showErrors ? _usernameError : null,
          ),
          const SizedBox(height: AsmSpacing.md),
          AsmTextField(
            controller: _emailController,
            label: 'E-Mail',
            errorText: showErrors ? _emailError : null,
          ),
          const SizedBox(height: AsmSpacing.md),
          AsmTextField(
            controller: _passwordController,
            label: 'Passwort',
            obscureText: true,
            errorText: showErrors ? _passwordError : null,
          ),
          const SizedBox(height: AsmSpacing.xs),
          PasswordStrengthBar(password: _passwordController.text),
          const SizedBox(height: AsmSpacing.md),
          AsmTextField(
            controller: _birthDateController,
            label: 'Geburtsdatum',
            readOnly: true,
            onTap: _pickBirthDate,
            errorText: showErrors ? _birthDateError : null,
          ),
          const SizedBox(height: AsmSpacing.lg),
          AsmCheckbox(
            key: const Key('agb_checkbox'),
            value: _agbChecked,
            onChanged: (v) => setState(() => _agbChecked = v),
            label: Text.rich(
              TextSpan(
                children: [
                  const TextSpan(text: 'Ich akzeptiere die '),
                  TextSpan(
                    text: 'AGB',
                    style: const TextStyle(color: AsmColors.brandBright),
                    recognizer: _agbLinkRecognizer,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AsmSpacing.sm),
          AsmCheckbox(
            key: const Key('datenschutz_checkbox'),
            value: _datenschutzChecked,
            onChanged: (v) => setState(() => _datenschutzChecked = v),
            label: Text.rich(
              TextSpan(
                children: [
                  const TextSpan(text: 'Ich habe die '),
                  TextSpan(
                    text: 'Datenschutzerklärung',
                    style: const TextStyle(color: AsmColors.brandBright),
                    recognizer: _datenschutzLinkRecognizer,
                  ),
                  const TextSpan(text: ' gelesen'),
                ],
              ),
            ),
          ),
          if (showErrors && _consentError != null) ...[
            const SizedBox(height: AsmSpacing.xxs),
            Padding(
              padding: const EdgeInsets.only(left: AsmSpacing.huge),
              child: Text(
                _consentError!,
                style: AsmTextStyles.bodyS.copyWith(
                  color: AsmColors.dangerText,
                ),
              ),
            ),
          ],
          const SizedBox(height: AsmSpacing.xl),
          if (_submitError != null) ...[
            Container(
              padding: const EdgeInsets.all(AsmSpacing.sm),
              decoration: BoxDecoration(
                color: AsmColors.surface,
                borderRadius: BorderRadius.circular(AsmRadius.md),
                border: Border.all(color: AsmColors.dangerText),
              ),
              child: Text(
                _submitError!,
                style: AsmTextStyles.bodyM.copyWith(
                  color: AsmColors.dangerText,
                ),
              ),
            ),
            const SizedBox(height: AsmSpacing.md),
          ],
          AsmButton(
            label: 'Registrieren',
            isLoading: _submitting,
            onPressed: _isValid && !_submitting ? _submit : null,
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmEmail() {
    final canResend = _resendCooldown == 0;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 320),
        child: Padding(
          padding: const EdgeInsets.all(AsmSpacing.md),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Bestätige deine E-Mail',
                style: AsmTextStyles.titleL,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AsmSpacing.sm),
              Text(
                'Wir haben eine Bestätigungs-E-Mail an $_registeredEmail '
                'geschickt. Bitte klicke auf den Link darin, um dein Konto '
                'zu aktivieren.',
                style: AsmTextStyles.bodyM.copyWith(
                  color: AsmColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AsmSpacing.xl),
              AsmButton(
                label: canResend
                    ? 'Erneut senden'
                    : 'Erneut senden in ${_resendCooldown}s',
                variant: AsmButtonVariant.secondary,
                isLoading: _resending,
                onPressed: canResend ? _resend : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
