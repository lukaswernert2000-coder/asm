// Liest assets/legal/*.md und rendert jede Datei nach website/*.html, im
// selben Seiten-Rahmen wie index.html und account-loeschen.html. Aufruf:
// dart run tool/gen_website.dart
//
// Bewusst kein package:markdown — der App-pubspec fehlt die Dependency, und
// der Rechtstext-Dialekt hier (Überschriften, Absätze, straffe Listen,
// Zitate, **fett**, `code`, [Links](url), ---) ist klein genug für einen
// eigenen, ~100-Zeilen-Konverter ohne neue Abhängigkeit.
import 'dart:io';

const draftMarkerPrefix = '<!-- ENTWURF';

String inlineFormat(String text) {
  final escaped = text
      .replaceAll('&', '&amp;')
      .replaceAll('<', '&lt;')
      .replaceAll('>', '&gt;');
  return escaped
      .replaceAllMapped(
        RegExp(r'\*\*(.+?)\*\*'),
        (m) => '<strong>${m[1]}</strong>',
      )
      .replaceAllMapped(RegExp('`(.+?)`'), (m) => '<code>${m[1]}</code>')
      .replaceAllMapped(
        // Kein `.+?` fuer den Linktext: Platzhalter wie "[FIRMENNAME]" ohne
        // folgendes (url) kommen im selben Absatz vor wie echte Links, und
        // ein nicht-gieriges `.+?` wuerde ueber sie hinweg zum naechsten
        // "](" zurueckbacktracken. `[^\[\]]+` kann das nicht.
        RegExp(r'\[([^\[\]]+)\]\(([^()]+)\)'),
        (m) => '<a href="${m[2]}">${m[1]}</a>',
      );
}

String renderMarkdown(String markdown) {
  final lines = markdown.replaceAll('.md)', '.html)').split('\n');
  final out = StringBuffer();
  var draftNotice = '';
  if (lines.isNotEmpty &&
      lines.first.trimLeft().startsWith(draftMarkerPrefix)) {
    final comment = lines.removeAt(0).trim();
    final text = comment.substring(4, comment.length - 3).trim();
    draftNotice = '<p class="draft-notice">⚠️ $text</p>';
  }

  var block = '';
  final listItems = <String>[];

  void flushParagraph() {
    if (block.isEmpty) return;
    out.writeln('<p>${inlineFormat(block)}</p>');
    block = '';
  }

  void flushQuote() {
    if (block.isEmpty) return;
    out.writeln('<blockquote>${inlineFormat(block)}</blockquote>');
    block = '';
  }

  void flushList() {
    if (listItems.isEmpty) return;
    out.writeln('<ul>');
    for (final item in listItems) {
      out.writeln('<li>$item</li>');
    }
    out.writeln('</ul>');
    listItems.clear();
  }

  var inQuote = false;
  void flushBlock() {
    if (inQuote) {
      flushQuote();
    } else {
      flushParagraph();
    }
    inQuote = false;
  }

  for (final raw in lines) {
    final line = raw.trim();
    if (line.isEmpty) {
      flushBlock();
      flushList();
    } else if (line.startsWith('### ')) {
      flushBlock();
      flushList();
      out.writeln('<h3>${inlineFormat(line.substring(4))}</h3>');
    } else if (line.startsWith('## ')) {
      flushBlock();
      flushList();
      out.writeln('<h2>${inlineFormat(line.substring(3))}</h2>');
    } else if (line.startsWith('# ')) {
      flushBlock();
      flushList();
      out.writeln('<h1>${inlineFormat(line.substring(2))}</h1>');
    } else if (line == '---') {
      flushBlock();
      flushList();
      out.writeln('<hr>');
    } else if (line.startsWith('- ')) {
      flushBlock();
      listItems.add(inlineFormat(line.substring(2)));
    } else if (line.startsWith('> ')) {
      flushList();
      inQuote = true;
      block = block.isEmpty ? line.substring(2) : '$block ${line.substring(2)}';
    } else if (listItems.isNotEmpty && !inQuote) {
      listItems[listItems.length - 1] += ' ${inlineFormat(line)}';
    } else {
      block = block.isEmpty ? line : '$block $line';
    }
  }
  flushBlock();
  flushList();

  return draftNotice + out.toString();
}

String page(String title, String bodyHtml) =>
    '''
<!doctype html>
<html lang="de">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>$title · ASM</title>
<link rel="stylesheet" href="style.css">
</head>
<body>
<header class="site-header">
  <a class="wordmark" href="index.html">ASM</a>
  <nav>
    <a href="datenschutz.html">Datenschutz</a>
    <a href="impressum.html">Impressum</a>
    <a href="agb.html">AGB</a>
    <a href="nutzungsbedingungen.html">Nutzungsbedingungen</a>
  </nav>
</header>
<main class="legal">
$bodyHtml
</main>
<footer class="site-footer">
  <p>© 2026 ASM · <a href="mailto:support@asm-app.de">support@asm-app.de</a></p>
</footer>
</body>
</html>
''';

void main() {
  final sourceDir = Directory('assets/legal');
  final outDir = Directory('website')..createSync(recursive: true);
  final titles = {
    'impressum': 'Impressum',
    'datenschutz': 'Datenschutzerklärung',
    'agb': 'AGB',
    'nutzungsbedingungen': 'Nutzungsbedingungen',
  };

  for (final entry in sourceDir.listSync().whereType<File>()) {
    if (!entry.path.endsWith('.md')) continue;
    final name = entry.uri.pathSegments.last.replaceAll('.md', '');
    final title = titles[name] ?? name;
    final html = page(title, renderMarkdown(entry.readAsStringSync()));
    File('${outDir.path}/$name.html').writeAsStringSync(html);
    stdout.writeln('website/$name.html geschrieben');
  }
}
