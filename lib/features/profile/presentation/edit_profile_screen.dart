import 'dart:typed_data';

import 'package:asm/core/config/app_config.dart';
import 'package:asm/core/theme/asm_colors.dart';
import 'package:asm/core/theme/asm_spacing.dart';
import 'package:asm/core/theme/asm_text_styles.dart';
import 'package:asm/core/utils/plz_lookup.dart';
import 'package:asm/core/widgets/asm_button.dart';
import 'package:asm/core/widgets/asm_checkbox.dart';
import 'package:asm/core/widgets/asm_error_view.dart';
import 'package:asm/core/widgets/asm_network_image.dart';
import 'package:asm/core/widgets/asm_skeleton.dart';
import 'package:asm/core/widgets/asm_text_field.dart';
import 'package:asm/features/profile/domain/avatar_url.dart';
import 'package:asm/features/profile/domain/profile.dart';
import 'package:asm/features/profile/domain/profile_update_payload.dart';
import 'package:asm/features/profile/presentation/profile_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

Future<Uint8List?> _defaultPickAvatar() async {
  final file = await ImagePicker().pickImage(
    source: ImageSource.gallery,
    maxWidth: 512,
    maxHeight: 512,
    imageQuality: 85,
  );
  return file?.readAsBytes();
}

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({
    this.pickAvatar = _defaultPickAvatar,
    this.resolvePlz = PlzLookup.resolve,
    super.key,
  });

  /// Seam statt `image_picker` direkt aufzurufen -- der echte Plugin-Kanal
  /// ist in Widget-Tests ohne Platform-Mock nicht verfuegbar. Liefert schon
  /// komprimierte Bytes (`maxWidth/maxHeight: 512`, siehe Task-2.5-Vorgabe).
  final Future<Uint8List?> Function() pickAvatar;

  /// Seam statt `PlzLookup.resolve` direkt aufzurufen -- das laedt echt
  /// `assets/data/plz.json` (425 KB) per `rootBundle`, was innerhalb von
  /// `testWidgets` an der FakeAsync-Zone der Testbindung haengen bleibt
  /// (ein einfacher `test()` wie in plz_lookup_test.dart ist davon nicht
  /// betroffen, `testWidgets()` schon).
  final Future<({String city, double lat, double lng})?> Function(String plz)
  resolvePlz;

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _displayNameController = TextEditingController();
  final _bioController = TextEditingController();
  final _plzController = TextEditingController();
  final _commercialNameController = TextEditingController();
  final _commercialAddressController = TextEditingController();

  bool _prefilled = false;
  bool _isCommercial = false;
  bool _submitAttempted = false;
  bool _saving = false;
  Uint8List? _newAvatarBytes;
  String? _existingAvatarPath;
  String? _resolvedCity;
  double? _resolvedLat;
  double? _resolvedLng;
  String? _plzError;
  int _plzRequestId = 0;

  @override
  void initState() {
    super.initState();
    _plzController.addListener(_onPlzChanged);
  }

  void _onPlzChanged() => _resolvePlz(_plzController.text.trim());

  @override
  void dispose() {
    _displayNameController.dispose();
    _bioController.dispose();
    _plzController.dispose();
    _commercialNameController.dispose();
    _commercialAddressController.dispose();
    super.dispose();
  }

  void _prefill(Profile profile) {
    _displayNameController.text = profile.displayName ?? '';
    _bioController.text = profile.bio ?? '';
    _plzController.text = profile.postalCode ?? '';
    _isCommercial = profile.isCommercial;
    _commercialNameController.text = profile.commercialName ?? '';
    _existingAvatarPath = profile.avatarPath;
    // Loest ueber den _plzController-Listener aus (Text-Zuweisung feuert ihn
    // auch programmatisch) -- reproduziert lat/lng deterministisch aus
    // derselben PLZ, ohne dass die Spalten selbst lesbar sein muessten
    // (kein Select-Grant, siehe profile_repository.dart).
  }

  Future<void> _resolvePlz(String plz) async {
    final requestId = ++_plzRequestId;
    if (plz.length != 5) {
      setState(() {
        _resolvedCity = null;
        _resolvedLat = null;
        _resolvedLng = null;
        _plzError = null;
      });
      return;
    }
    final result = await widget.resolvePlz(plz);
    if (!mounted || requestId != _plzRequestId) return;
    setState(() {
      if (result == null) {
        _resolvedCity = null;
        _resolvedLat = null;
        _resolvedLng = null;
        _plzError = 'Unbekannte Postleitzahl';
      } else {
        _resolvedCity = result.city;
        _resolvedLat = result.lat;
        _resolvedLng = result.lng;
        _plzError = null;
      }
    });
  }

  Future<void> _pickAvatar() async {
    final bytes = await widget.pickAvatar();
    if (bytes == null) return;
    setState(() => _newAvatarBytes = bytes);
  }

  String? get _commercialNameError =>
      _isCommercial && _commercialNameController.text.trim().isEmpty
      ? 'Pflichtfeld für gewerbliche Verkäufer'
      : null;

  String? get _commercialAddressError =>
      _isCommercial && _commercialAddressController.text.trim().isEmpty
      ? 'Pflichtfeld für gewerbliche Verkäufer'
      : null;

  bool get _isValid =>
      _resolvedCity != null &&
      _commercialNameError == null &&
      _commercialAddressError == null;

  Future<void> _save(String userId) async {
    setState(() => _submitAttempted = true);
    if (!_isValid) return;

    setState(() => _saving = true);
    try {
      String? avatarPath;
      final bytes = _newAvatarBytes;
      if (bytes != null) {
        avatarPath = await ref
            .read(profileRepositoryProvider)
            .uploadAvatar(userId, bytes);
      }
      final payload = buildProfileUpdatePayload(
        displayName: _displayNameController.text.trim(),
        bio: _bioController.text.trim(),
        postalCode: _plzController.text.trim(),
        city: _resolvedCity!,
        lat: _resolvedLat!,
        lng: _resolvedLng!,
        isCommercial: _isCommercial,
        commercialName: _commercialNameController.text.trim(),
        commercialAddressInput: _commercialAddressController.text.trim(),
        avatarPath: avatarPath,
      );
      await ref.read(profileRepositoryProvider).update(userId, payload);
      ref.invalidate(currentProfileProvider);
      if (!mounted) return;
      Navigator.of(context).pop();
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(currentProfileProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Profil bearbeiten')),
      body: profileAsync.when(
        loading: () => const Padding(
          padding: EdgeInsets.all(AsmSpacing.md),
          child: AsmSkeleton.detail(),
        ),
        error: (error, stackTrace) => AsmErrorView(
          message: 'Profil konnte nicht geladen werden',
          onRetry: () => ref.invalidate(currentProfileProvider),
        ),
        data: (profile) {
          if (profile == null) {
            return const AsmErrorView(
              message: 'Nicht angemeldet',
              onRetry: _noop,
            );
          }
          if (!_prefilled) {
            _prefilled = true;
            _prefill(profile);
          }
          return _buildForm(profile.id);
        },
      ),
    );
  }

  Widget _buildForm(String userId) {
    final showErrors = _submitAttempted;
    final avatarUrlValue =
        _existingAvatarPath == null || _newAvatarBytes != null
        ? null
        : avatarUrl(
            supabaseUrl: AppConfig.supabaseUrl,
            path: _existingAvatarPath,
          );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AsmSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(AsmRadius.full),
                  child: SizedBox(
                    width: 88,
                    height: 88,
                    child: _newAvatarBytes != null
                        ? Image.memory(_newAvatarBytes!, fit: BoxFit.cover)
                        : AsmNetworkImage(path: avatarUrlValue),
                  ),
                ),
                const SizedBox(height: AsmSpacing.xs),
                AsmButton(
                  label: 'Bild ändern',
                  variant: AsmButtonVariant.ghost,
                  onPressed: _pickAvatar,
                ),
              ],
            ),
          ),
          const SizedBox(height: AsmSpacing.md),
          AsmTextField(
            controller: _displayNameController,
            label: 'Anzeigename',
            maxLength: 40,
          ),
          const SizedBox(height: AsmSpacing.md),
          AsmTextField(
            controller: _bioController,
            label: 'Bio',
            maxLength: 500,
            maxLines: 4,
          ),
          const SizedBox(height: AsmSpacing.md),
          AsmTextField(
            controller: _plzController,
            label: 'Postleitzahl',
            maxLength: 5,
            errorText: showErrors ? _plzError : null,
          ),
          if (_resolvedCity != null) ...[
            const SizedBox(height: AsmSpacing.xxs),
            Text(
              _resolvedCity!,
              style: AsmTextStyles.bodyS.copyWith(
                color: AsmColors.textSecondary,
              ),
            ),
          ],
          const SizedBox(height: AsmSpacing.lg),
          AsmCheckbox(
            value: _isCommercial,
            onChanged: (value) => setState(() => _isCommercial = value),
            label: const Text('Ich verkaufe gewerblich'),
          ),
          if (_isCommercial) ...[
            const SizedBox(height: AsmSpacing.md),
            AsmTextField(
              controller: _commercialNameController,
              label: 'Firmenname',
              errorText: showErrors ? _commercialNameError : null,
            ),
            const SizedBox(height: AsmSpacing.md),
            AsmTextField(
              controller: _commercialAddressController,
              label: 'Geschäftsadresse',
              errorText: showErrors ? _commercialAddressError : null,
            ),
            const SizedBox(height: AsmSpacing.xxs),
            Text(
              'Wird nicht öffentlich angezeigt, aber gespeichert.',
              style: AsmTextStyles.bodyS.copyWith(
                color: AsmColors.textTertiary,
              ),
            ),
          ],
          const SizedBox(height: AsmSpacing.xl),
          AsmButton(
            label: 'Speichern',
            isLoading: _saving,
            onPressed: _saving ? null : () => _save(userId),
          ),
        ],
      ),
    );
  }
}

void _noop() {}
