import 'package:asm/core/theme/asm_colors.dart';
import 'package:asm/core/theme/asm_spacing.dart';
import 'package:asm/core/theme/asm_text_styles.dart';
import 'package:asm/core/widgets/asm_button.dart';
import 'package:asm/core/widgets/asm_chip.dart';
import 'package:asm/core/widgets/asm_empty_state.dart';
import 'package:asm/core/widgets/asm_error_view.dart';
import 'package:asm/core/widgets/asm_network_image.dart';
import 'package:asm/core/widgets/asm_skeleton.dart';
import 'package:asm/core/widgets/asm_text_field.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Debug-Widget-Katalog. Zeigt alle Kern-Widgets in allen Zustaenden
/// untereinander. Nur ueber `if (kDebugMode)` erreichbar (Task 0.5, Schritt 6).
class GalleryScreen extends StatelessWidget {
  const GalleryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Widget-Katalog')),
      body: ListView(
        padding: const EdgeInsets.all(AsmSpacing.md),
        children: [
          const _Section(
            title: 'AsmButton',
            children: [
              AsmButton(label: 'Primary', onPressed: _noop),
              SizedBox(height: AsmSpacing.sm),
              AsmButton(
                label: 'Secondary',
                variant: AsmButtonVariant.secondary,
                onPressed: _noop,
              ),
              SizedBox(height: AsmSpacing.sm),
              AsmButton(
                label: 'Ghost',
                variant: AsmButtonVariant.ghost,
                onPressed: _noop,
              ),
              SizedBox(height: AsmSpacing.sm),
              AsmButton(
                label: 'Danger',
                variant: AsmButtonVariant.danger,
                onPressed: _noop,
              ),
              SizedBox(height: AsmSpacing.sm),
              AsmButton(label: 'Deaktiviert'),
              SizedBox(height: AsmSpacing.sm),
              AsmButton(label: 'Laedt', isLoading: true),
              SizedBox(height: AsmSpacing.sm),
              AsmButton(
                label: 'Mit Icon',
                icon: LucideIcons.plus,
                onPressed: _noop,
              ),
            ],
          ),
          _Section(
            title: 'AsmTextField',
            children: [
              AsmTextField(
                controller: TextEditingController(),
                label: 'Standard',
              ),
              const SizedBox(height: AsmSpacing.md),
              AsmTextField(
                controller: TextEditingController(),
                label: 'Mit Fehler',
                errorText: 'Pflichtfeld',
              ),
              const SizedBox(height: AsmSpacing.md),
              AsmTextField(
                controller: TextEditingController(text: 'Inserat-Titel'),
                label: 'Mit Zeichenzaehler',
                maxLength: 80,
              ),
            ],
          ),
          const _Section(
            title: 'AsmChip',
            children: [
              Wrap(
                spacing: AsmSpacing.xs,
                runSpacing: AsmSpacing.xs,
                children: [
                  AsmChip(label: 'Inaktiv', selected: false),
                  AsmChip(label: 'Aktiv', selected: true),
                  AsmChip(
                    label: 'Mit Icon',
                    selected: false,
                    icon: LucideIcons.filter,
                  ),
                ],
              ),
            ],
          ),
          const _Section(
            title: 'AsmEmptyState',
            children: [
              SizedBox(
                height: 260,
                child: AsmEmptyState(
                  icon: LucideIcons.search,
                  title: 'Nichts gefunden',
                  message: 'Versuch andere Filter oder eine andere Kategorie.',
                  action: AsmButton(
                    label: 'Filter zuruecksetzen',
                    variant: AsmButtonVariant.secondary,
                    onPressed: _noop,
                  ),
                ),
              ),
            ],
          ),
          const _Section(
            title: 'AsmSkeleton.listingGrid',
            children: [
              SizedBox(
                height: 360,
                child: IgnorePointer(child: AsmSkeleton.listingGrid()),
              ),
            ],
          ),
          const _Section(
            title: 'AsmSkeleton.listingList',
            children: [
              SizedBox(
                height: 360,
                child: IgnorePointer(child: AsmSkeleton.listingList()),
              ),
            ],
          ),
          const _Section(
            title: 'AsmSkeleton.detail',
            children: [
              SizedBox(
                height: 400,
                child: IgnorePointer(child: AsmSkeleton.detail()),
              ),
            ],
          ),
          const _Section(
            title: 'AsmErrorView',
            children: [
              SizedBox(
                height: 260,
                child: AsmErrorView(
                  message: 'Keine Verbindung',
                  onRetry: _noop,
                ),
              ),
            ],
          ),
          _Section(
            title: 'AsmNetworkImage',
            children: [
              Row(
                children: [
                  const Expanded(
                    child: AspectRatio(
                      aspectRatio: 4 / 3,
                      child: AsmNetworkImage(path: null),
                    ),
                  ),
                  const SizedBox(width: AsmSpacing.sm),
                  Expanded(
                    child: AsmNetworkImage(
                      path: 'https://picsum.photos/400/300',
                      aspectRatio: 4 / 3,
                      radius: BorderRadius.circular(12),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  static void _noop() {}
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AsmSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AsmTextStyles.titleM.copyWith(color: AsmColors.brandBright),
          ),
          const SizedBox(height: AsmSpacing.sm),
          ...children,
        ],
      ),
    );
  }
}
