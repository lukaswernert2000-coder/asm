import 'package:asm/core/router/routes.dart';
import 'package:asm/features/auth/presentation/auth_controller.dart';
import 'package:asm/features/moderation/domain/report_reason.dart';
import 'package:asm/features/moderation/presentation/moderation_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Melden/Blockieren, urspruenglich privat in PublicProfileScreen (Task 2.5)
/// gebaut, jetzt geteilt fuer Task 5.1s Overflow-Menue auf der Detailseite.

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
  final result = await showDialog<({ReportReason reason, String details})>(
    context: context,
    builder: (context) => ReportDialog(username: username),
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
    const SnackBar(content: Text('Danke. Wir prüfen die Meldung.')),
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
  if (!context.mounted) return;
  ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text('$username blockiert')));
}

class ReportDialog extends StatefulWidget {
  const ReportDialog({required this.username, super.key});

  final String username;

  @override
  State<ReportDialog> createState() => _ReportDialogState();
}

class _ReportDialogState extends State<ReportDialog> {
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
    return AlertDialog(
      title: Text('${widget.username} melden'),
      content: SizedBox(
        width: double.maxFinite,
        // SingleChildScrollView statt ListView: baut alle neun Grund-Zeilen
        // sofort (kein Sliver-Cache-Extent, der nicht sichtbare Zeilen erst
        // nach Scrollen erzeugt) -- bei nur neun kurzen Zeilen unnoetig,
        // und ein `find.text` in Tests faende sonst weiter unten stehende
        // Gruende wie "Spam" nicht, ohne vorher zu scrollen.
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
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
                        ),
                      )
                      .toList(),
                ),
              ),
              TextField(
                controller: _detailsController,
                decoration: const InputDecoration(
                  hintText: 'Details (optional)',
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Abbrechen'),
        ),
        TextButton(
          onPressed: _selected == null
              ? null
              : () => Navigator.of(context).pop((
                  reason: _selected!,
                  details: _detailsController.text,
                )),
          child: const Text('Melden bestätigen'),
        ),
      ],
    );
  }
}
