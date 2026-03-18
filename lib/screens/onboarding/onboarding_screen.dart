import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_strings.dart';
import '../../core/extensions/context_extensions.dart';
import '../../widgets/platform_button.dart';
import '../../router/app_router.dart';

class _OnboardingSlide {
  final IconData icon;
  final String title;
  final String subtitle;
  const _OnboardingSlide({
    required this.icon,
    required this.title,
    required this.subtitle,
  });
}

const _slides = [
  _OnboardingSlide(
    icon: Icons.storefront_outlined,
    title: 'Buy & Sell\nUsed Items —',
    subtitle: 'Browse listings near you',
  ),
  _OnboardingSlide(
    icon: Icons.add_photo_alternate_outlined,
    title: 'List in Under\na Minute —',
    subtitle: 'Photo, price, done.',
  ),
  _OnboardingSlide(
    icon: Icons.chat_outlined,
    title: 'Connect on\nWhatsApp —',
    subtitle: 'Direct contact, no middleman.',
  ),
];

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  final _pageController = PageController();
  int _currentPage = 0;
  Timer? _timer;
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );
    _slideAnim =
        Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
    );
    _animController.forward();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (_currentPage < _slides.length - 1) {
        _goToPage(_currentPage + 1);
      } else {
        _timer?.cancel();
      }
    });
  }

  void _goToPage(int page) {
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _finish() async {
    _timer?.cancel();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.prefOnboardingSeen, true);
    if (mounted) context.go(AppRoutes.login);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;

    return Scaffold(
      backgroundColor: context.backgroundColor,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: SlideTransition(
            position: _slideAnim,
            child: Column(
              children: [
                // ── Skip ──────────────────────────────────────────────────
                Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(0, 12, 16, 0),
                    child: TextButton(
                      onPressed: _finish,
                      child: Text(
                        AppStrings.onboardingSkip,
                        style: AppTextStyles.labelLarge(
                          color: context.textSecondaryColor,
                        ),
                      ),
                    ),
                  ),
                ),

                // ── Slides ─────────────────────────────────────────────────
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (page) =>
                        setState(() => _currentPage = page),
                    itemCount: _slides.length,
                    itemBuilder: (context, index) =>
                        _SlideContent(slide: _slides[index]),
                  ),
                ),

                // ── Dots + CTA ─────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                  child: Column(
                    children: [
                      // Dots
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          _slides.length,
                          (i) => _Dot(isActive: i == _currentPage),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // CTA — only on last slide
                      AnimatedOpacity(
                        opacity: _currentPage == _slides.length - 1 ? 1 : 0,
                        duration: const Duration(milliseconds: 300),
                        child: PlatformButton(
                          label: AppStrings.onboardingGetStarted,
                          onPressed: _currentPage == _slides.length - 1
                              ? _finish
                              : null,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SlideContent extends StatelessWidget {
  final _OnboardingSlide slide;
  const _SlideContent({required this.slide});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: context.primaryTintColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              slide.icon,
              size: 36,
              color: context.primaryColor,
            ),
          ),
          const SizedBox(height: 32),
          Text(
            slide.title,
            style: AppTextStyles.displayLarge(color: context.textPrimaryColor),
          ),
          const SizedBox(height: 12),
          Text(
            slide.subtitle,
            style: AppTextStyles.bodyLarge(color: context.textSecondaryColor),
          ),
        ],
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  final bool isActive;
  const _Dot({required this.isActive});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: isActive ? 20 : 6,
      height: 6,
      decoration: BoxDecoration(
        color: isActive
            ? context.primaryColor
            : context.dividerColor,
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }
}
