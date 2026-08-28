import 'package:asm/core/router/routes.dart';
import 'package:asm/core/theme/asm_colors.dart';
import 'package:asm/core/theme/asm_spacing.dart';
import 'package:asm/core/theme/asm_text_styles.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Navigations-Geruest mit BottomNav. Siehe 01-DESIGN-SYSTEM.md Abschnitt 5.9.
///
/// Der mittlere Eintrag ist kein Branch, sondern pusht `/create` als
/// Vollbild-Route ausserhalb der Shell. Er nutzt Scaffolds eigenen
/// `floatingActionButton` + `centerDocked` statt eines selbstgebauten
/// Stack/Positioned-Aufbaus - letzterer rendert zwar korrekt, aber Scaffold
/// reicht Touch-Events dafuer nicht zuverlaessig durch (siehe DECISIONS.md).
///
/// Der Gast-Check aus 5.9 ("bei Gast oeffnet er das Login-Sheet") ist noch
/// nicht umsetzbar — Auth kommt erst in M1, siehe DECISIONS.md.
class AsmShell extends StatelessWidget {
  const AsmShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          navigationShell,
          if (kDebugMode)
            Positioned(
              top: MediaQuery.paddingOf(context).top + AsmSpacing.sm,
              right: AsmSpacing.sm,
              child: _DebugGalleryButton(
                onTap: () => context.push(AsmRoutes.debugGallery),
              ),
            ),
        ],
      ),
      floatingActionButton: _CreateNavItem(
        onTap: () => context.push(AsmRoutes.create),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _BottomNav(
        currentIndex: navigationShell.currentIndex,
        onBranchTap: (index) => navigationShell.goBranch(
          index,
          initialLocation: index == navigationShell.currentIndex,
        ),
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  const _BottomNav({required this.currentIndex, required this.onBranchTap});

  final int currentIndex;
  final ValueChanged<int> onBranchTap;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AsmColors.bg,
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            children: [
              _NavItem(
                icon: LucideIcons.house,
                label: 'Start',
                active: currentIndex == 0,
                onTap: () => onBranchTap(0),
              ),
              _NavItem(
                icon: LucideIcons.search,
                label: 'Suchen',
                active: currentIndex == 1,
                onTap: () => onBranchTap(1),
              ),
              const Expanded(child: SizedBox.shrink()),
              _NavItem(
                icon: LucideIcons.messageSquare,
                label: 'Chats',
                active: currentIndex == 2,
                onTap: () => onBranchTap(2),
              ),
              _NavItem(
                icon: LucideIcons.user,
                label: 'Profil',
                active: currentIndex == 3,
                onTap: () => onBranchTap(3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = active ? AsmColors.brandBright : AsmColors.textSecondary;
    return Expanded(
      child: Semantics(
        label: label,
        button: true,
        selected: active,
        child: InkWell(
          onTap: onTap,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color),
              const SizedBox(height: AsmSpacing.xxs),
              Text(label, style: AsmTextStyles.label.copyWith(color: color)),
            ],
          ),
        ),
      ),
    );
  }
}

class _DebugGalleryButton extends StatelessWidget {
  const _DebugGalleryButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(LucideIcons.wrench, color: AsmColors.textTertiary),
      tooltip: 'Widget-Katalog',
      onPressed: onTap,
    );
  }
}

class _CreateNavItem extends StatelessWidget {
  const _CreateNavItem({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Inserat aufgeben',
      button: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AsmRadius.full),
        child: Container(
          width: 56,
          height: 56,
          decoration: const BoxDecoration(
            color: AsmColors.brandBright,
            shape: BoxShape.circle,
            // FAB-Ausnahme von 4.3: als einziges Element darf es einen
            // weichen Schatten haben, damit es sich vom Feed loest.
            boxShadow: [
              BoxShadow(
                color: Color(0x66000000),
                blurRadius: 16,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(LucideIcons.plus, color: AsmColors.onBrand),
        ),
      ),
    );
  }
}
