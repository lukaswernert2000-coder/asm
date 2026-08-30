import 'package:asm/core/theme/asm_colors.dart';
import 'package:asm/core/theme/asm_spacing.dart';
import 'package:asm/core/theme/asm_text_styles.dart';
import 'package:asm/features/listings/presentation/create_listing_providers.dart';
import 'package:asm/features/listings/presentation/widgets/create_listing/category_step.dart';
import 'package:asm/features/listings/presentation/widgets/create_listing/details_step.dart';
import 'package:asm/features/listings/presentation/widgets/create_listing/photos_step.dart';
import 'package:asm/features/listings/presentation/widgets/create_listing/shipping_step.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

const stepTitles = ['Kategorie', 'Fotos', 'Details', 'Versand & Ort'];

/// 4-Schritte-Erstellen-Flow (Task 4.2). Der Fortschritt liegt in
/// [createListingDraftProvider] (lokal persistiert), jeder Schritt-Screen
/// validiert sich selbst und ruft seinen `onNext`-Callback, um
/// weiterzublaettern.
class CreateListingScreen extends ConsumerWidget {
  const CreateListingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final draft = ref.watch(createListingDraftProvider);
    final step = draft.step.clamp(0, stepTitles.length - 1);

    return Scaffold(
      backgroundColor: AsmColors.bg,
      appBar: AppBar(
        backgroundColor: AsmColors.bg,
        leading: IconButton(
          key: const Key('createListingBack'),
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => _goToStep(ref, step - 1, context: context),
        ),
        title: Text(stepTitles[step], style: AsmTextStyles.titleM),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AsmSpacing.md,
              vertical: AsmSpacing.sm,
            ),
            child: _StepIndicator(step: step),
          ),
          Expanded(
            child: switch (step) {
              0 => CategoryStep(
                key: const Key('createListingStep0'),
                onNext: () => _goToStep(ref, 1, context: context),
              ),
              1 => PhotosStep(
                key: const Key('createListingStep1'),
                onNext: () => _goToStep(ref, 2, context: context),
              ),
              2 => DetailsStep(
                key: const Key('createListingStep2'),
                onNext: () => _goToStep(ref, 3, context: context),
              ),
              _ => const ShippingStep(key: Key('createListingStep3')),
            },
          ),
        ],
      ),
    );
  }

  Future<void> _goToStep(
    WidgetRef ref,
    int step, {
    required BuildContext context,
  }) async {
    if (step < 0) {
      await Navigator.of(context).maybePop();
      return;
    }
    await updateCreateListingDraft(ref, (d) => d.copyWith(step: step));
  }
}

class _StepIndicator extends StatelessWidget {
  const _StepIndicator({required this.step});

  final int step;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < stepTitles.length; i++) ...[
          if (i > 0) const SizedBox(width: AsmSpacing.xs),
          Expanded(
            child: Container(
              height: 4,
              decoration: BoxDecoration(
                color: i <= step ? AsmColors.brandBright : AsmColors.border,
                borderRadius: BorderRadius.circular(AsmRadius.full),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
