import 'dart:async';

import 'package:asm/core/router/routes.dart';
import 'package:asm/core/theme/asm_colors.dart';
import 'package:asm/core/theme/asm_spacing.dart';
import 'package:asm/core/theme/asm_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:go_router/go_router.dart';

const _titles = {
  'impressum': 'Impressum',
  'datenschutz': 'Datenschutzerklärung',
  'agb': 'AGB',
  'nutzungsbedingungen': 'Nutzungsbedingungen',
};

const _draftMarkerPrefix = '<!-- ENTWURF';

Future<String> _defaultLoadMarkdown(String page) =>
    rootBundle.loadString('assets/legal/$page.md');

/// Zeigt einen der vier Rechtstexte aus `assets/legal/*.md` (Task 7.2) --
/// dieselbe Quelle wie `tool/gen_website.dart` fuer die Website, damit
/// App-Text und Website-Text identisch bleiben. Ein `[Text](andere.md)`-Link
/// im Markdown navigiert per `onTapLink` zur passenden `LegalScreen`
/// innerhalb der App, statt einen externen Browser zu oeffnen.
class LegalScreen extends StatefulWidget {
  const LegalScreen({
    required this.page,
    this.loadMarkdown = _defaultLoadMarkdown,
    super.key,
  });

  final String page;

  /// Seam statt `rootBundle.loadString` direkt aufzurufen -- echtes
  /// Asset-Laden haengt in `testWidgets` an der FakeAsync-Zone (gleiches
  /// Muster wie `PlzLookup`/`EditProfileScreen`).
  final Future<String> Function(String page) loadMarkdown;

  @override
  State<LegalScreen> createState() => _LegalScreenState();
}

class _LegalScreenState extends State<LegalScreen> {
  late final Future<String> _markdown = widget.loadMarkdown(widget.page);

  void _onTapLink(String text, String? href, String title) {
    if (href == null || !href.endsWith('.md')) return;
    final page = href.substring(0, href.length - '.md'.length);
    unawaited(context.push(AsmRoutes.legal(page)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_titles[widget.page] ?? widget.page)),
      body: FutureBuilder<String>(
        future: _markdown,
        builder: (context, snapshot) {
          final raw = snapshot.data;
          if (raw == null) return const SizedBox.shrink();

          var body = raw;
          String? draftNotice;
          if (body.startsWith(_draftMarkerPrefix)) {
            final end = body.indexOf('\n');
            final comment = (end == -1 ? body : body.substring(0, end)).trim();
            draftNotice = comment.substring(4, comment.length - 3).trim();
            body = end == -1 ? '' : body.substring(end + 1);
          }

          final styleSheet =
              MarkdownStyleSheet.fromTheme(
                Theme.of(context),
              ).copyWith(
                a: const TextStyle(
                  color: AsmColors.brandBright,
                  decoration: TextDecoration.underline,
                ),
                h1: AsmTextStyles.titleL,
              );

          return Column(
            children: [
              if (draftNotice != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AsmSpacing.sm),
                  color: AsmColors.warning.withValues(alpha: 0.16),
                  child: Text(
                    draftNotice,
                    style: AsmTextStyles.bodyS.copyWith(
                      color: AsmColors.warning,
                    ),
                  ),
                ),
              Expanded(
                child: Markdown(
                  data: body,
                  styleSheet: styleSheet,
                  onTapLink: _onTapLink,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
