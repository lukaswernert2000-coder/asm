# ASM · Design-System "Tactical Olive"

**Für Sonnet:** Dieses Dokument ist verbindlich. Erfinde keine Farben, Abstände oder
Schriftgrößen dazu. Alles, was in der App vorkommt, muss aus den hier definierten
Tokens gebaut sein. Wenn du etwas brauchst, das hier fehlt, füge es in
`lib/core/theme/` als benannten Token hinzu – niemals als Magic Number im Widget.

---

## 1. Design-Prinzipien

1. **Dark-first, nicht Dark-Mode.** Die App ist dunkel, weil das zum Sport passt (Wald,
   Nacht, Ausrüstung) und weil es Fotos von schwarzem/oliv Gear besser aussehen lässt.
   Kein Light-Theme im MVP. Das ist eine bewusste Markenentscheidung, kein Weglassen.
2. **Das Foto ist der Held.** Jede Fläche im Feed dient dem Produktbild. Chrome ist ruhig,
   Farbe wird sparsam eingesetzt.
3. **Kanten statt Schatten.** Auf dunklem Grund funktionieren Schatten nicht. Tiefe entsteht
   über Flächenhelligkeit (`surface` → `surfaceRaised`) und 1-px-Borders.
4. **Olive ist Akzent, nicht Fläche.** Die Brand-Farbe markiert Aktionen und Auswahl.
   Großflächiges Olive wirkt schnell schlammig.
5. **Ein Primäraktion pro Screen.** Der gefüllte Olive-Button kommt genau einmal vor.
6. **Nichts blinkt, nichts hüpft.** Bewegung ist funktional: 150–250 ms, `easeOutCubic`.

---

## 2. Farb-Tokens

### 2.1 Vorgegebene Palette (unverändert übernommen)

```
Core       #171A18   #222622   #2B302B
Brand      #68745A   #7D8B6A
Neutral    #E8EAE5   #A8ADA4
Status     #5F8A62   #B49A62   #A85F59
```

### 2.2 Vollständige Token-Tabelle

| Token | Hex | Verwendung |
|---|---|---|
| `bg` | `#171A18` | App-Hintergrund, Scaffold |
| `surface` | `#222622` | Karten, Bottom-Sheets, Eingabefelder |
| `surfaceRaised` | `#2B302B` | Hervorgehobene Karten, Chips, Menüs, gedrückte Zustände |
| `border` | `#3A403A` | 1-px-Rahmen, Trennlinien *(abgeleitet)* |
| `brand` | `#68745A` | Füllflächen, inaktive Auswahl, Rahmen — **nicht für Fließtext** |
| `brandBright` | `#7D8B6A` | Primärbutton, aktive Icons, Links, Fokus-Ring |
| `brandHi` | `#93A17E` | Hover/Fokus-Zustand, Fortschritt *(abgeleitet)* |
| `brandDim` | `#566047` | Gedrückter Primärbutton *(abgeleitet)* |
| `onBrand` | `#171A18` | Text/Icon auf `brandBright`-Fläche |
| `textPrimary` | `#E8EAE5` | Überschriften, Fließtext |
| `textSecondary` | `#A8ADA4` | Sekundärtext, Metadaten, Platzhalter |
| `textTertiary` | `#7A8078` | Deaktiviert, Hilfetext *(abgeleitet)* |
| `success` | `#5F8A62` | Füllung/Icon "Neu", "Verfügbar" |
| `successText` | `#7FA882` | Erfolgs-**Text** auf dunklem Grund *(abgeleitet)* |
| `warning` | `#B49A62` | Füllung/Icon/Text "Leichte Defekte", "Reserviert" |
| `danger` | `#A85F59` | Füllung/Icon "Defekt", Löschen |
| `dangerText` | `#C97F78` | Fehler-**Text** auf dunklem Grund *(abgeleitet)* |
| `scrim` | `#000000` @ 60 % | Overlay hinter Dialogen, Galerie-Hintergrund |
| `shimmerBase` | `#222622` | Ladeskelett Grundfläche |
| `shimmerHi` | `#2B302B` | Ladeskelett Highlight |

### 2.3 Kontrast-Prüfung (WCAG 2.1, gegen `bg` `#171A18`)

| Farbe | Ratio | AA Fließtext (4,5:1) | AA groß / UI (3:1) |
|---|---|---|---|
| `#E8EAE5` textPrimary | **14,3:1** | ✅ | ✅ |
| `#A8ADA4` textSecondary | **7,6:1** | ✅ | ✅ |
| `#7A8078` textTertiary | **4,6:1** | ✅ (knapp) | ✅ |
| `#93A17E` brandHi | **6,3:1** | ✅ | ✅ |
| `#7D8B6A` brandBright | **4,8:1** | ✅ | ✅ |
| `#68745A` brand | **3,5:1** | ❌ | ✅ |
| `#5F8A62` success | **4,4:1** | ❌ (knapp) | ✅ |
| `#7FA882` successText | **6,5:1** | ✅ | ✅ |
| `#B49A62` warning | **6,4:1** | ✅ | ✅ |
| `#A85F59` danger | **3,7:1** | ❌ | ✅ |
| `#C97F78` dangerText | **5,6:1** | ✅ | ✅ |
| `#171A18` auf `#7D8B6A` | **4,8:1** | ✅ | ✅ |

**Verbindliche Regeln daraus:**
- `brand`, `success` und `danger` **nie** für Text unter 18 pt verwenden. Nur für
  Füllflächen, Rahmen, Icons und Badge-Hintergründe.
- Für farbigen Text immer die `*Text`-Varianten nehmen: `successText`, `dangerText`,
  `warning`, `brandBright`.
- Fehlermeldungen unter Eingabefeldern: `dangerText`, 13 pt.
- Primärbutton: Fläche `brandBright`, Label `onBrand` (dunkel). Nicht weiß.

---

## 3. Typografie

**Zwei Familien, beide SIL OFL (kostenlos, kommerziell nutzbar), als Assets gebündelt.**

> ⚠️ **Kein `google_fonts`-Paket mit Runtime-Download verwenden.** Das lädt Schriften von
> Google-Servern und überträgt dabei IP-Adressen der Nutzer – ein DSGVO-Problem, das schon
> mehrfach abgemahnt wurde. Schriftdateien in `assets/fonts/` legen und in `pubspec.yaml`
> deklarieren.

| Familie | Rolle | Gewichte |
|---|---|---|
| **Inter** | Alle UI-Texte, Fließtext, Zahlen | 400, 500, 600, 700 |
| **Barlow Condensed** | Display, Sektionsüberschriften, Logo-Wortmarke | 600, 700 |

### 3.1 Typenskala

| Style | Familie / Gewicht | Größe / Zeilenhöhe | Letter-Spacing | Verwendung |
|---|---|---|---|---|
| `displayL` | Barlow Condensed 700 | 34 / 38 | +0,5 | Onboarding-Headlines, Uppercase |
| `displayM` | Barlow Condensed 700 | 26 / 30 | +0,5 | Sektionstitel, Uppercase |
| `titleL` | Inter 600 | 22 / 28 | 0 | Screen-Titel |
| `titleM` | Inter 600 | 17 / 22 | 0 | Inseratstitel Detailseite, Dialogtitel |
| `titleS` | Inter 600 | 15 / 20 | 0 | Kartentitel, Listenzeilen |
| `bodyL` | Inter 400 | 16 / 24 | 0 | Beschreibungstext |
| `bodyM` | Inter 400 | 14 / 20 | 0 | Standardtext, Chat-Nachrichten |
| `bodyS` | Inter 400 | 13 / 18 | 0 | Metadaten, Zeitstempel, Hilfetext |
| `label` | Inter 500 | 12 / 16 | +0,4 | Badges, Chips, Tabs, Uppercase |
| `price` | Inter 700 | 20 / 24 | 0, `FontFeature.tabularFigures()` | Preisanzeige |
| `priceS` | Inter 700 | 16 / 20 | 0, tabular | Preis in der Feed-Karte |

**Regeln:**
- Maximal 3 Textstile pro Screen-Bereich.
- Uppercase nur bei `displayL`, `displayM` und `label`. Niemals bei Fließtext.
- Preise immer mit `tabularFigures`, damit Zahlen in Listen nicht springen.
- Deutsche Preisformatierung über `intl`: `NumberFormat.currency(locale: 'de_DE', symbol: '€')`
  → `1.250,00 €`.

---

## 4. Abstände, Radien, Bewegung

### 4.1 Spacing (4-pt-Raster)

```
xxs 4 · xs 8 · sm 12 · md 16 · lg 20 · xl 24 · xxl 32 · xxxl 40 · huge 48
```

- Screen-Rand: `md` (16)
- Abstand zwischen Karten in Listen: `sm` (12)
- Innenabstand Karte: `sm` (12), bei Detailflächen `md` (16)
- Abstand zwischen Formularfeldern: `md` (16)
- Abstand zwischen Sektionen: `xl` (24)

### 4.2 Radien

```
sm 8   (Chips, Badges, kleine Buttons)
md 12  (Eingabefelder, Buttons, Bilder in Karten)
lg 16  (Karten, Bottom-Sheets oben)
xl 24  (Modale, große Bildflächen)
full 999 (Avatare, Pill-Filter)
```

### 4.3 Elevation

Keine `BoxShadow` auf dunklem Grund. Stattdessen:

| Ebene | Fläche | Border |
|---|---|---|
| 0 – Hintergrund | `bg` | – |
| 1 – Karte | `surface` | `border` 1 px |
| 2 – Sheet, Menü, Dialog | `surfaceRaised` | `border` 1 px |
| 3 – Overlay | `scrim` + Ebene 2 darüber | – |

Ausnahme: Der Floating Action Button darf einen weichen Schatten haben
(`Color(0x66000000)`, blur 8, offset 0/2), damit er sich vom Feed löst.

### 4.4 Bewegung

| Zweck | Dauer | Kurve |
|---|---|---|
| Zustandswechsel (Farbe, Opacity) | 150 ms | `Curves.easeOut` |
| Ein-/Ausblenden, Sheets | 250 ms | `Curves.easeOutCubic` |
| Seitenwechsel | 300 ms | `Curves.easeInOutCubic` |
| Ladeskelett-Shimmer | 1200 ms Loop | `Curves.linear` |

**Hero-Animation** vom Feed-Bild zur Detailseite: `Hero(tag: 'listing-image-$listingId')`.
Sonst keine Seiten-Custom-Transitions.

---

## 5. Komponenten-Spezifikationen

Alle Komponenten liegen unter `lib/core/widgets/`. Jede ist ein `StatelessWidget` ohne
eigene Datenbeschaffung – Daten kommen ausschließlich über Konstruktor-Parameter.

### 5.1 `AsmButton`

| Variante | Fläche | Label | Border | Höhe |
|---|---|---|---|---|
| `primary` | `brandBright` | `onBrand` | – | 52 |
| `secondary` | `surfaceRaised` | `textPrimary` | `border` 1 px | 52 |
| `ghost` | transparent | `brandBright` | – | 44 |
| `danger` | transparent | `dangerText` | `dangerText` 1 px | 52 |

- Radius `md` (12), horizontales Padding `lg` (20)
- Gedrückt: Fläche → `brandDim` (primary) bzw. `surface` (secondary), 150 ms
- Deaktiviert: 38 % Opacity, kein Ripple
- Ladezustand: Label wird durch 18-px-`CircularProgressIndicator` in `onBrand` ersetzt,
  Breite bleibt konstant (kein Springen)
- Volle Breite als Default; `AsmButton.compact` für Inline-Nutzung

### 5.2 `AsmTextField`

- Fläche `surface`, Border `border` 1 px, Radius `md`
- Fokus: Border `brandBright` 1,5 px, kein Glow
- Fehler: Border `dangerText` 1,5 px + Fehlertext `bodyS`/`dangerText` darunter, 4 px Abstand
- Label als `label`-Style über dem Feld (kein Floating Label – bleibt bei Textskalierung stabil)
- Zeichenzähler rechts unter dem Feld bei `maxLength`, `bodyS`/`textTertiary`

### 5.3 `AsmChip` (Filter, Zustand, Attribute)

- Inaktiv: `surfaceRaised`, Text `textSecondary`, Border `border`
- Aktiv: `brand`-Fläche @ 22 % Opacity, Border `brandBright`, Text `brandBright`
- Höhe 34, Radius `full`, Padding horizontal `sm`
- Optionales Leading-Icon 16 px

### 5.4 `ListingCard` (Feed-Karte) — die wichtigste Komponente

```
┌──────────────────────────────────────┐
│  [Bild 4:3, Radius md]        [♡]    │  ← Favoriten-Toggle oben rechts,
│  [Badge unten links: Zustand]        │    40×40 Tap-Ziel, Scrim-Kreis
├──────────────────────────────────────┤
│  Titel, titleS, max 2 Zeilen         │
│  349,00 €  VB          [Versand]     │  ← price + Chips rechts
│  76133 Karlsruhe · 12 km · vor 2 Std │  ← bodyS / textSecondary
└──────────────────────────────────────┘
```

- Karte: `surface`, Border `border`, Radius `lg`, Padding `sm`
- Bild: `AspectRatio(4/3)`, `cached_network_image`, Platzhalter = Shimmer, Fehler = Icon
- Zustands-Badge: `label`, Hintergrund je nach Zustand (`success`/`warning`/`danger`/`surfaceRaised`),
  Textfarbe `onBrand` bei farbigem Grund
- Status-Overlay bei `reserved`/`sold`: diagonales Band bzw. Scrim @ 55 % mit
  `displayM`-Text "VERKAUFT" / "RESERVIERT"
- Bei über 0,5 J: kleines Fünfeck-Badge mit "F" unten rechts im Bild
- Tap-Ziel der ganzen Karte, Favoriten-Herz mit eigenem `GestureDetector` und
  `Semantics(label: 'Zu Favoriten hinzufügen')`

**Zwei Layouts:** `ListingCard.grid` (2 Spalten, Standard im Feed) und
`ListingCard.list` (Bild links 112×112, Text rechts) für Favoriten und Suchergebnisse.
Umschaltbar über ein Icon in der AppBar, Auswahl in `shared_preferences` merken.

### 5.5 `CategoryTile`

- Quadratisch, `surface`, Border `border`, Radius `lg`
- Icon 32 px `brandBright` zentriert oben, Name `titleS` darunter, Anzahl `bodyS`/`textSecondary`
- Grid 3 Spalten auf Phone, 4 auf Tablet
- Gedrückt: Fläche `surfaceRaised`, Skalierung 0,97

### 5.6 `ChatBubble`

| | Eigene Nachricht | Fremde Nachricht |
|---|---|---|
| Ausrichtung | rechts | links |
| Fläche | `brand` | `surfaceRaised` |
| Text | `textPrimary` | `textPrimary` |
| Radius | 16, unten rechts 4 | 16, unten links 4 |

- Max. Breite 78 % der Bildschirmbreite
- Zeitstempel `bodyS`/`textSecondary` in der Bubble unten rechts
- Gelesen-Haken (zwei Häkchen, `brandHi`) nur bei eigenen Nachrichten
- Erste Nachricht einer Konversation zeigt darüber eine `ListingChip`-Karte
  (Miniatur + Titel + Preis), tappbar zur Detailseite

### 5.7 `AsmEmptyState`

Icon 48 px `textTertiary`, Titel `titleM`, Beschreibung `bodyM`/`textSecondary`,
optionaler `AsmButton.secondary`. Zentriert, max. Breite 320.

Pflicht-Einsatzorte: leerer Feed, leere Suche, leere Favoriten, leere Chatliste,
leere eigene Inserate, Offline-Fehler, 404-Inserat.

### 5.8 `AsmSkeleton`

Shimmer zwischen `shimmerBase` und `shimmerHi`. Es gibt genau drei Skelett-Layouts:
`AsmSkeleton.listingGrid`, `AsmSkeleton.listingList`, `AsmSkeleton.detail`.
**Keine `CircularProgressIndicator` als Ganzseiten-Ladeanzeige.**

### 5.9 Navigation

**Bottom Navigation, 5 Einträge, Höhe 64 + SafeArea:**

| Icon | Label | Route |
|---|---|---|
| Home | Start | `/` |
| Search | Suchen | `/search` |
| Plus (FAB-Stil, `brandBright`-Kreis) | – | `/create` |
| MessageSquare | Chats | `/chats` |
| User | Profil | `/profile` |

- Aktiv: Icon + Label `brandBright`; inaktiv `textSecondary`
- Ungelesene Chats: roter Punkt (`danger`) mit Zahl am Chat-Icon
- Der mittlere Eintrag ist ein erhöhter Kreis (56 px) und öffnet direkt die
  Inserat-Erstellung; bei Gast öffnet er stattdessen das Login-Sheet

---

## 6. Ikonografie

**Basis:** `lucide_icons_flutter` – dünne Linien (2 px), passt zum technischen Charakter.
Größen: 20 (inline), 24 (Standard), 32 (Kategorie-Kachel), 48 (Empty State).

**Kategorie-Icons** – zwölf davon gibt es nicht als Standard-Icon und müssen als SVG
gezeichnet werden (`assets/icons/categories/*.svg`, 24×24, `stroke-width: 1.75`,
`currentColor`, kein Fill):

| Kategorie | Icon-Motiv |
|---|---|
| ASGs bis 0,5 J | Gewehrsilhouette mit kleinem "0,5"-Label |
| Gewehre & MPs | Sturmgewehr-Seitenansicht, reduziert auf 6 Linien |
| Pistolen | Pistolen-Seitenansicht |
| Ersatzteile & Tuning | Zahnrad mit Kolben |
| Zubehör | Magazin + Red-Dot-Kreis |
| Ausrüstung | Plattenträger-Umriss |
| Bekleidung | Combat-Shirt-Umriss |
| Sonstiges | Drei Punkte im Kreis |

Zusätzlich als Marker-Icon: **F-im-Fünfeck** (`assets/icons/f-marking.svg`) –
gleichseitiges Fünfeck, Spitze oben, mit "F" zentriert. Wird als Badge auf Bildern und
in der Attributliste verwendet.

---

## 7. Logo und App-Icon

Es gibt noch kein Logo. Empfehlung, umsetzbar als SVG:

### 7.1 Konzept "Chevron-A" (empfohlen)

Ein nach oben zeigender Winkel (Rangabzeichen-Chevron), dessen Spitze als Querbalken-loses
"A" lesbar ist. Darüber ein kleiner ausgefüllter Kreis – die BB. Reduziert, funktioniert
bei 16 px genauso wie auf einem Banner, und es sieht nicht nach Waffe aus (wichtig für
den App-Store-Review).

```
        ●            ← BB, r = 5,  brandBright
       ╱ ╲
      ╱   ╲          ← Chevron, stroke 14, brandBright, linecap square
     ╱     ╲
```

- **Wortmarke:** `ASM` in Barlow Condensed 700, Uppercase, Letter-Spacing +2,
  `textPrimary`; darunter optional `AIRSOFT MARKETPLACE` in 10 pt, +3 Spacing, `textSecondary`
- **Lockup:** Chevron links, Wortmarke rechts, Abstand = halbe Chevron-Breite

### 7.2 Alternativen (falls Konzept A nicht gefällt)

- **"Reticle-A"**: Fadenkreuz-Kreis, im Zentrum ein A. Wirkt taktischer, aber näher an "Zielen".
- **"Tag"**: Preisschild-Silhouette schräg, mit stenciled ASM. Betont "Marktplatz", weniger "Airsoft".

### 7.3 Asset-Anforderungen

| Asset | Spezifikation |
|---|---|
| App-Icon Basis | 1024×1024 PNG, Hintergrund `#171A18`, Chevron `#7D8B6A`, 18 % Innenabstand |
| iOS | Kein Alpha-Kanal, kein transparenter Hintergrund, keine abgerundeten Ecken selbst zeichnen |
| Android Adaptive | `foreground` = Chevron auf transparent (66 % Safe Zone), `background` = `#171A18` |
| Splash | `#171A18` Vollfläche, Logo-Lockup zentriert, 40 % Bildschirmbreite. Via `flutter_native_splash` |
| Store-Screenshots | 6,7"-iPhone und 1080×1920-Android, 6 Stück, mit Textoverlay in Barlow Condensed |

Erzeugung im MVP über `flutter_launcher_icons` + `flutter_native_splash`
(beide als `dev_dependency`, per YAML konfiguriert).

---

## 8. Fertiger `theme.dart`

Diese Datei wird in **M0, Task 0.4** angelegt. Sie ist die einzige Quelle für Farben und
Textstile in der App.

**`lib/core/theme/asm_colors.dart`**

```dart
import 'package:flutter/material.dart';

/// Alle Farben der App. Keine Farbe darf ausserhalb dieser Klasse
/// als Literal im Code stehen.
abstract final class AsmColors {
  // Core
  static const bg            = Color(0xFF171A18);
  static const surface       = Color(0xFF222622);
  static const surfaceRaised = Color(0xFF2B302B);
  static const border        = Color(0xFF3A403A);

  // Brand
  static const brand       = Color(0xFF68745A);
  static const brandBright = Color(0xFF7D8B6A);
  static const brandHi     = Color(0xFF93A17E);
  static const brandDim    = Color(0xFF566047);
  static const onBrand     = Color(0xFF171A18);

  // Text
  static const textPrimary   = Color(0xFFE8EAE5);
  static const textSecondary = Color(0xFFA8ADA4);
  static const textTertiary  = Color(0xFF7A8078);

  // Status – Flaechen/Icons
  static const success = Color(0xFF5F8A62);
  static const warning = Color(0xFFB49A62);
  static const danger  = Color(0xFFA85F59);

  // Status – Text (kontraststark genug fuer Fliesstext)
  static const successText = Color(0xFF7FA882);
  static const warningText = Color(0xFFB49A62);
  static const dangerText  = Color(0xFFC97F78);

  // Sonstiges
  static const scrim       = Color(0x99000000);
  static const shimmerBase = Color(0xFF222622);
  static const shimmerHi   = Color(0xFF2B302B);
}
```

**`lib/core/theme/asm_spacing.dart`**

```dart
abstract final class AsmSpacing {
  static const double xxs = 4;
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 20;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 40;
  static const double huge = 48;
}

abstract final class AsmRadius {
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double full = 999;
}

abstract final class AsmDuration {
  static const fast = Duration(milliseconds: 150);
  static const normal = Duration(milliseconds: 250);
  static const slow = Duration(milliseconds: 300);
}
```

**`lib/core/theme/asm_text_styles.dart`**

```dart
import 'dart:ui' show FontFeature;
import 'package:flutter/material.dart';
import 'asm_colors.dart';

abstract final class AsmTextStyles {
  static const _inter = 'Inter';
  static const _condensed = 'BarlowCondensed';

  static const displayL = TextStyle(
    fontFamily: _condensed, fontSize: 34, height: 38 / 34,
    fontWeight: FontWeight.w700, letterSpacing: 0.5,
    color: AsmColors.textPrimary,
  );
  static const displayM = TextStyle(
    fontFamily: _condensed, fontSize: 26, height: 30 / 26,
    fontWeight: FontWeight.w700, letterSpacing: 0.5,
    color: AsmColors.textPrimary,
  );
  static const titleL = TextStyle(
    fontFamily: _inter, fontSize: 22, height: 28 / 22,
    fontWeight: FontWeight.w600, color: AsmColors.textPrimary,
  );
  static const titleM = TextStyle(
    fontFamily: _inter, fontSize: 17, height: 22 / 17,
    fontWeight: FontWeight.w600, color: AsmColors.textPrimary,
  );
  static const titleS = TextStyle(
    fontFamily: _inter, fontSize: 15, height: 20 / 15,
    fontWeight: FontWeight.w600, color: AsmColors.textPrimary,
  );
  static const bodyL = TextStyle(
    fontFamily: _inter, fontSize: 16, height: 24 / 16,
    fontWeight: FontWeight.w400, color: AsmColors.textPrimary,
  );
  static const bodyM = TextStyle(
    fontFamily: _inter, fontSize: 14, height: 20 / 14,
    fontWeight: FontWeight.w400, color: AsmColors.textPrimary,
  );
  static const bodyS = TextStyle(
    fontFamily: _inter, fontSize: 13, height: 18 / 13,
    fontWeight: FontWeight.w400, color: AsmColors.textSecondary,
  );
  static const label = TextStyle(
    fontFamily: _inter, fontSize: 12, height: 16 / 12,
    fontWeight: FontWeight.w500, letterSpacing: 0.4,
    color: AsmColors.textSecondary,
  );
  static const price = TextStyle(
    fontFamily: _inter, fontSize: 20, height: 24 / 20,
    fontWeight: FontWeight.w700, color: AsmColors.textPrimary,
    fontFeatures: [FontFeature.tabularFigures()],
  );
  static const priceS = TextStyle(
    fontFamily: _inter, fontSize: 16, height: 20 / 16,
    fontWeight: FontWeight.w700, color: AsmColors.textPrimary,
    fontFeatures: [FontFeature.tabularFigures()],
  );
}
```

**`lib/core/theme/asm_theme.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'asm_colors.dart';
import 'asm_spacing.dart';
import 'asm_text_styles.dart';

abstract final class AsmTheme {
  static ThemeData get dark {
    const scheme = ColorScheme.dark(
      brightness: Brightness.dark,
      primary: AsmColors.brandBright,
      onPrimary: AsmColors.onBrand,
      primaryContainer: AsmColors.brand,
      onPrimaryContainer: AsmColors.textPrimary,
      secondary: AsmColors.brand,
      onSecondary: AsmColors.textPrimary,
      surface: AsmColors.surface,
      onSurface: AsmColors.textPrimary,
      surfaceContainerHighest: AsmColors.surfaceRaised,
      onSurfaceVariant: AsmColors.textSecondary,
      error: AsmColors.dangerText,
      onError: AsmColors.onBrand,
      outline: AsmColors.border,
      outlineVariant: AsmColors.border,
      scrim: AsmColors.scrim,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: scheme,
      scaffoldBackgroundColor: AsmColors.bg,
      canvasColor: AsmColors.bg,
      splashFactory: InkSparkle.splashFactory,
      fontFamily: 'Inter',

      textTheme: const TextTheme(
        displayLarge: AsmTextStyles.displayL,
        displayMedium: AsmTextStyles.displayM,
        titleLarge: AsmTextStyles.titleL,
        titleMedium: AsmTextStyles.titleM,
        titleSmall: AsmTextStyles.titleS,
        bodyLarge: AsmTextStyles.bodyL,
        bodyMedium: AsmTextStyles.bodyM,
        bodySmall: AsmTextStyles.bodyS,
        labelMedium: AsmTextStyles.label,
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor: AsmColors.bg,
        foregroundColor: AsmColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: AsmTextStyles.titleL,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
      ),

      cardTheme: CardThemeData(
        color: AsmColors.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AsmRadius.lg),
          side: const BorderSide(color: AsmColors.border),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AsmColors.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AsmSpacing.md, vertical: AsmSpacing.sm,
        ),
        hintStyle: AsmTextStyles.bodyM.copyWith(color: AsmColors.textTertiary),
        errorStyle: AsmTextStyles.bodyS.copyWith(color: AsmColors.dangerText),
        border: _inputBorder(AsmColors.border),
        enabledBorder: _inputBorder(AsmColors.border),
        focusedBorder: _inputBorder(AsmColors.brandBright, width: 1.5),
        errorBorder: _inputBorder(AsmColors.dangerText, width: 1.5),
        focusedErrorBorder: _inputBorder(AsmColors.dangerText, width: 1.5),
      ),

      dividerTheme: const DividerThemeData(
        color: AsmColors.border, thickness: 1, space: 1,
      ),

      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AsmColors.surfaceRaised,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(AsmRadius.xl)),
        ),
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: AsmColors.surfaceRaised,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: AsmTextStyles.titleM,
        contentTextStyle: AsmTextStyles.bodyM,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AsmRadius.lg),
        ),
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: AsmColors.surfaceRaised,
        contentTextStyle: AsmTextStyles.bodyM,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AsmRadius.md),
        ),
      ),

      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AsmColors.brandBright,
        linearTrackColor: AsmColors.surfaceRaised,
      ),
    );
  }

  static OutlineInputBorder _inputBorder(Color color, {double width = 1}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(AsmRadius.md),
      borderSide: BorderSide(color: color, width: width),
    );
  }
}
```

---

## 9. Screen-Inventar

Damit klar ist, wie viel gebaut wird — 24 Screens im MVP:

| Bereich | Screens |
|---|---|
| Onboarding | Splash · Onboarding (3 Seiten) · Willkommen |
| Auth | Registrieren · Login · Passwort vergessen · E-Mail bestätigen · Altersabfrage |
| Feed | Start (Kategorien + Neueste) · Kategorie-Übersicht · Kategorie-Feed |
| Suche | Suche mit Verlauf · Suchergebnisse · Filter-Sheet |
| Inserat | Detailseite · Vollbild-Galerie · Erstellen (4 Schritte) · Bearbeiten |
| Chat | Chatliste · Chat-Detail |
| Profil | Eigenes Profil · Profil bearbeiten · Meine Inserate · Favoriten · Fremdprofil |
| System | Einstellungen · Rechtstexte (WebView/Markdown) · Melden-Sheet · Account löschen |
