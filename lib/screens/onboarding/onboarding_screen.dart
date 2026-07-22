import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../theme/flex_theme.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  final List<OnboardingData> _pages = [
    OnboardingData(
      title: 'Bienvenue sur Flex',
      subtitle: 'Le logement qui vous ressemble,\noù que vous alliez.',
      description:
          'Des chambres certifiées chez l\'habitant dans les villes secondaires d\'Afrique de l\'Ouest. Propre. Sûr. Accessible.',
      illustration: FlexIllustration.welcome,
      accentColor: FlexColors.primary500,
    ),
    OnboardingData(
      title: 'La Confiance,\nIndustrialisée',
      subtitle: 'Chaque logement est audité\nphysiquement par nos agents.',
      description:
          'Serrure vérifiée, literie contrôlée, identité du propriétaire confirmée. Le badge Flex Certifié, c\'est votre garantie.',
      illustration: FlexIllustration.certified,
      accentColor: FlexColors.certified,
    ),
    OnboardingData(
      title: 'Payez en\nMobile Money',
      subtitle: 'MTN MoMo, Moov Money, Wave.\nRapide et sécurisé.',
      description:
          'Réservez en quelques secondes avec votre mobile money habituel. Confirmation instantanée, même avec une connexion lente.',
      illustration: FlexIllustration.payment,
      accentColor: FlexColors.info,
    ),
    OnboardingData(
      title: 'Vous êtes\nChez Vous',
      subtitle: 'Parakou, Natitingou, Abomey...\nPartout au Bénin et au-delà.',
      description:
          'Que vous soyez agent de santé, commerçant ou enseignant en déplacement, Flex vous trouve un toit de confiance.',
      illustration: FlexIllustration.home,
      accentColor: FlexColors.primary500,
    ),
  ];

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _finishOnboarding();
    }
  }

  Future<void> _finishOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_done', true);
    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/auth');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final page = _pages[_currentPage];

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Logo
                  Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: FlexColors.primary500,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Center(
                          child: Text(
                            'F',
                            style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w700,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Flex',
                        style: FlexTextStyles.h3.copyWith(
                          color: isDark ? FlexColors.neutral0 : FlexColors.neutral800,
                        ),
                      ),
                    ],
                  ),
                  if (_currentPage < _pages.length - 1)
                    TextButton(
                      onPressed: _finishOnboarding,
                      child: Text(
                        'Ignorer',
                        style: FlexTextStyles.label.copyWith(
                          color: FlexColors.neutral400,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Pages
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _pages.length,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemBuilder: (context, i) => _OnboardingPage(data: _pages[i]),
              ),
            ),

            // Bottom controls
            Padding(
              padding: const EdgeInsets.all(FlexSpacing.lg),
              child: Column(
                children: [
                  // Indicator
                  AnimatedSmoothIndicator(
                    activeIndex: _currentPage,
                    count: _pages.length,
                    effect: ExpandingDotsEffect(
                      activeDotColor: page.accentColor,
                      dotColor: isDark ? FlexColors.neutral700 : FlexColors.neutral200,
                      dotHeight: 8,
                      dotWidth: 8,
                      expansionFactor: 3,
                    ),
                  ),
                  const SizedBox(height: FlexSpacing.lg),

                  // CTA Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _nextPage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: page.accentColor,
                      ),
                      child: Text(
                        _currentPage == _pages.length - 1
                            ? 'Commencer'
                            : 'Suivant',
                      ),
                    ),
                  ),

                  if (_currentPage == _pages.length - 1) ...[
                    const SizedBox(height: FlexSpacing.sm),
                    TextButton(
                      onPressed: _finishOnboarding,
                      child: Text(
                        'J\'ai déjà un compte',
                        style: FlexTextStyles.label.copyWith(
                          color: FlexColors.neutral500,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

// ─────────────────────────────────────────────
//  Onboarding Page Widget
// ─────────────────────────────────────────────

class _OnboardingPage extends StatelessWidget {
  final OnboardingData data;
  const _OnboardingPage({required this.data});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: FlexSpacing.xl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Illustration
          Container(
            width: double.infinity,
            height: 260,
            decoration: BoxDecoration(
              color: data.accentColor.withOpacity(isDark ? 0.1 : 0.06),
              borderRadius: BorderRadius.circular(FlexRadius.xl),
            ),
            child: _buildIllustration(data.illustration, data.accentColor),
          ),
          const SizedBox(height: FlexSpacing.xl),

          // Title
          Text(
            data.title,
            style: FlexTextStyles.h1.copyWith(
              color: isDark ? FlexColors.neutral0 : FlexColors.neutral800,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: FlexSpacing.md),

          // Subtitle
          Text(
            data.subtitle,
            style: FlexTextStyles.h3.copyWith(
              color: data.accentColor,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: FlexSpacing.md),

          // Description
          Text(
            data.description,
            style: FlexTextStyles.body.copyWith(
              color: isDark ? FlexColors.neutral400 : FlexColors.neutral500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildIllustration(FlexIllustration type, Color color) {
    // Placeholder geometric illustrations
    switch (type) {
      case FlexIllustration.welcome:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.home_rounded, size: 80, color: color),
              const SizedBox(height: 12),
              Icon(Icons.location_on_rounded, size: 40, color: color.withOpacity(0.5)),
            ],
          ),
        );
      case FlexIllustration.certified:
        return Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              Icon(Icons.shield_rounded, size: 100, color: color.withOpacity(0.2)),
              Icon(Icons.verified_rounded, size: 60, color: color),
            ],
          ),
        );
      case FlexIllustration.payment:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.phone_android_rounded, size: 70, color: color),
              const SizedBox(height: 8),
              Icon(Icons.payments_rounded, size: 40, color: color.withOpacity(0.6)),
            ],
          ),
        );
      case FlexIllustration.home:
        return Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.pin_drop_rounded, size: 50, color: color.withOpacity(0.5)),
              const SizedBox(width: 8),
              Icon(Icons.house_rounded, size: 80, color: color),
              const SizedBox(width: 8),
              Icon(Icons.pin_drop_rounded, size: 50, color: color.withOpacity(0.5)),
            ],
          ),
        );
    }
  }
}

// ─────────────────────────────────────────────
//  Data classes
// ─────────────────────────────────────────────

enum FlexIllustration { welcome, certified, payment, home }

class OnboardingData {
  final String title;
  final String subtitle;
  final String description;
  final FlexIllustration illustration;
  final Color accentColor;

  OnboardingData({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.illustration,
    required this.accentColor,
  });
}
