import 'package:asm/core/router/routes.dart';
import 'package:asm/core/theme/asm_colors.dart';
import 'package:asm/core/theme/asm_spacing.dart';
import 'package:asm/core/theme/asm_text_styles.dart';
import 'package:asm/features/onboarding/presentation/onboarding_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class _OnboardingPage {
  const _OnboardingPage(this.title, this.description);

  final String title;
  final String description;
}

const _pages = [
  _OnboardingPage(
    'Gear finden, das wirklich passt.',
    'Kategorien vom S-AEG bis zum Plattenträger.',
  ),
  _OnboardingPage(
    'Sicher handeln.',
    'F-Kennzeichen-Pflicht, Besitznachweis, 18+-Regel.',
  ),
  _OnboardingPage('Direkt verhandeln.', 'Chat mit dem Verkäufer.'),
];

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _controller = PageController();
  int _page = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    await markOnboardingSeen(ref);
    if (!mounted) return;
    context.go(AsmRoutes.welcome);
  }

  @override
  Widget build(BuildContext context) {
    final isLastPage = _page == _pages.length - 1;

    return Scaffold(
      backgroundColor: AsmColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(AsmSpacing.md),
                child: TextButton(
                  onPressed: _finish,
                  child: Text(isLastPage ? 'Fertig' : 'Überspringen'),
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _pages.length,
                onPageChanged: (page) => setState(() => _page = page),
                itemBuilder: (context, index) =>
                    _OnboardingPageContent(page: _pages[index]),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AsmSpacing.lg),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _pages.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: index == _page ? 20 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: index == _page
                          ? AsmColors.brandBright
                          : AsmColors.border,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPageContent extends StatelessWidget {
  const _OnboardingPageContent({required this.page});

  final _OnboardingPage page;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AsmSpacing.lg),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            page.title,
            style: AsmTextStyles.displayL,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AsmSpacing.sm),
          Text(
            page.description,
            style: AsmTextStyles.bodyL.copyWith(
              color: AsmColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
