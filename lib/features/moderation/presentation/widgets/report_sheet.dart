import 'package:asm/core/router/routes.dart';
import 'package:asm/core/theme/asm_colors.dart';
import 'package:asm/core/theme/asm_spacing.dart';
import 'package:asm/core/theme/asm_text_styles.dart';
import 'package:asm/core/widgets/asm_button.dart';
import 'package:asm/features/auth/presentation/auth_controller.dart';
import 'package:asm/features/moderation/domain/report_reason.dart';
import 'package:asm/features/moderation/presentation/moderation_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Melden/Blockieren, urspruenglich privat in PublicProfileScreen (Task 2.5)
/// gebaut, jetzt geteilt fuer Task 5.1s Overflow-Menue auf der Detailseite
/// und Task 6.2s Chat-Detailseite. Das Melde-Sheet selbst (9 feste Gruende +
/// Freitext) ist Task 7.1 -- Task 2.5 legte dafuer schon `ReportReason` an.

bool _requireLogin(BuildContext context, WidgetRef ref, String redirectPath) {
  if (ref.read(isLoggedInProvider)) return true;
  context.go('${AsmRoutes.login}?from=$redirectPath');
  return false;
}

Future<void> showReportUserFlow(
  BuildContext context,
  WidgetRef ref, {
  required String userId,
  required String username,
  required String loginRedirectPath,
}) async {
  if (!_requireLogin(context, ref, loginRedirectPath)) return;
  final result =
      await showModalBottomSheet<({ReportReason reason, String details})>(
        context: context,
        isScrollControlled: true,
        useRootNavigator: true,
        backgroundColor: AsmColors.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AsmRadius.lg),
          ),
        ),
        builder: (context) => ReportSheet(username: username),
      );
  if (result == null) return;
  if (!context.mounted) return;
  await ref
      .read(moderationRepositoryProvider)
      .reportUser(
        userId,
        result.reason,
        details: result.details.isEmpty ? null : result.details,
      );
  if (!context.mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text('Danke. Wir prüfen die Meldung innerhalb von 24 Stunden.'),
    ),
  );
}

Future<void> showBlockUserFlow(
  BuildContext context,
  WidgetRef ref, {
  required String userId,
  required String username,
  required String loginRedirectPath,
}) async {
  if (!_requireLogin(context, ref, loginRedirectPath)) return;
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('$username blockieren?'),
      content: const Text(
        'Ihr könnt euch danach nicht mehr gegenseitig kontaktieren.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Abbrechen'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Blockieren bestätigen'),
        ),
      ],
    ),
  );
  if (confirmed != true) return;
  if (!context.mounted) return;
  await ref.read(moderationRepositoryProvider).blockUser(userId);
  // Eine schon offene Chat-Detailseite mit dieser Person soll das
  // Eingabefeld sofort sperren, und eine schon offene "Blockierte
  // Nutzer"-Liste die neue Blockierung zeigen -- beides ohne dass der
  // jeweilige Screen dafuer neu geoeffnet werden muss.
  ref
    ..invalidate(isBlockedByMeProvider(userId))
    ..invalidate(blockedUserIdsProvider);
  if (!context.mounted) return;
  ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text('$username blockiert')));
}

class ReportSheet extends StatefulWidget {
  const ReportSheet({required this.username, super.key});

  final String username;

  @override
  State<ReportSheet> createState() => _ReportSheetState();
}

class _ReportSheetState extends State<ReportSheet> {
  ReportReason? _selected;
  final _detailsController = TextEditingController();

  static const Map<ReportReason, String> _labels = {
    ReportReason.verbotenerArtikel: 'Verbotener Artikel',
    ReportReason.keinFKennzeichen: 'Kein F-Kennzeichen',
    ReportReason.vollautomat: 'Vollautomatik',
    ReportReason.keinBesitznachweis: 'Kein Besitznachweis',
    ReportReason.betrugsverdacht: 'Betrugsverdacht',
    ReportReason.falscheKategorie: 'Falsche Kategorie',
    ReportReason.beleidigung: 'Beleidigung',
    ReportReason.spam: 'Spam',
    ReportReason.sonstiges: 'Sonstiges',
  };

  @override
  void dispose() {
    _detailsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      // Ohne festen Hoehen-Anteil bekommt die `Expanded`-Scrollflaeche unten
      // keine begrenzte Hoehe und wuchs in einem Test bereits ueber den
      // sichtbaren Viewport hinaus -- "Melden bestaetigen" lag dann
      // ausserhalb des Hit-Test-Bereichs. Gleiches Muster wie FilterSheet.
      heightFactor: 0.85,
      alignment: Alignment.bottomCenter,
      child: Padding(
        // Hebt das Sheet ueber die Tastatur, sobald das Freitext-Feld
        // fokussiert ist -- zusammen mit `isScrollControlled: true` am
        // Aufrufer.
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SafeArea(
          top: false,
          child: Column(
            children: [
              Expanded(
                // SingleChildScrollView statt ListView: baut alle neun
                // Grund-Zeilen sofort (kein Sliver-Cache-Extent, der nicht
                // sichtbare Zeilen erst nach Scrollen erzeugt) -- bei nur
                // neun kurzen Zeilen unnoetig, und ein `find.text` in Tests
                // faende sonst weiter unten stehende Gruende wie "Spam"
                // nicht, ohne vorher zu scrollen.
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AsmSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${widget.username} melden',
                        style: AsmTextStyles.titleL,
                      ),
                      const SizedBox(height: AsmSpacing.sm),
                      RadioGroup<ReportReason>(
                        groupValue: _selected,
                        onChanged: (value) => setState(() => _selected = value),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: _labels.entries
                              .map(
                                (entry) => RadioListTile<ReportReason>(
                                  title: Text(entry.value),
                                  value: entry.key,
                                  contentPadding: EdgeInsets.zero,
                                ),
                              )
                              .toList(),
                        ),
                      ),
                      const SizedBox(height: AsmSpacing.xs),
                      TextField(
                        controller: _detailsController,
                        decoration: const InputDecoration(
                          hintText: 'Details (optional)',
                        ),
                        maxLines: 3,
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AsmSpacing.md,
                  AsmSpacing.sm,
                  AsmSpacing.md,
                  AsmSpacing.md,
                ),
                child: Column(
                  children: [
                    AsmButton(
                      label: 'Melden bestätigen',
                      onPressed: _selected == null
                          ? null
                          : () => Navigator.of(context).pop((
                              reason: _selected!,
                              details: _detailsController.text,
                            )),
                    ),
                    const SizedBox(height: AsmSpacing.sm),
                    AsmButton(
                      label: 'Abbrechen',
                      variant: AsmButtonVariant.ghost,
                      onPressed: () => Navigator.of(context).pop(),
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
