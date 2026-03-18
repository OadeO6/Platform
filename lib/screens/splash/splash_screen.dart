import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/constants/app_constants.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/items_provider.dart';
import '../../router/app_router.dart';

/// Splash screen — shown on app launch.
/// Checks auth state and onboarding status, then redirects accordingly.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.88, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    _controller.forward();
    Future.delayed(const Duration(milliseconds: 1800), _navigate);
  }

  Future<void> _navigate() async {
    if (!mounted) return;

    final authState = ref.read(authStateProvider);
    final isAuthenticated = authState.value != null;

    if (isAuthenticated) {
      // Quietly update location in background — don't block navigation
      _updateLocationIfNeeded();
      if (mounted) context.go(AppRoutes.home);
    } else {
      final prefs = await SharedPreferences.getInstance();
      final onboardingSeen =
          prefs.getBool(AppConstants.prefOnboardingSeen) ?? false;
      if (!mounted) return;
      context.go(onboardingSeen ? AppRoutes.login : AppRoutes.onboarding);
    }
  }

  /// Detects location and saves city to user profile if not already set.
  Future<void> _updateLocationIfNeeded() async {
    try {
      final userId = ref.read(currentUserIdProvider);
      if (userId == null) {
        debugPrint('[Location] No userId — skipping');
        return;
      }

      final user = ref.read(currentUserValueProvider);
      if (user?.city != null && user!.city!.isNotEmpty) {
        debugPrint('[Location] City already set: ${user.city} — skipping');
        return;
      }

      debugPrint('[Location] Detecting location...');
      final locationService = ref.read(locationServiceProvider);
      final result = await locationService.getCurrentLocation();

      debugPrint('[Location] Result: city=${result.city}, area=${result.area}, hasLocation=${result.hasLocation}');

      if (!mounted) return;
      if (!result.hasLocation) {
        debugPrint('[Location] No location found — skipping save');
        return;
      }

      debugPrint('[Location] Saving city=${result.city} to user $userId');
      await ref.read(userProfileNotifierProvider.notifier).updateLocation(
            userId,
            city: result.city!,
            area: result.area ?? '',
            latitude: result.latitude ?? 0,
            longitude: result.longitude ?? 0,
          );
      debugPrint('[Location] Saved successfully');
    } catch (e) {
      debugPrint('[Location] Error: $e');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.darkBackground : AppColors.primary;
    const textColor = Colors.white;

    return Scaffold(
      backgroundColor: bgColor,
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) => Opacity(
            opacity: _fadeAnimation.value,
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: child,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Platform',
                style: AppTextStyles.displayLarge(color: textColor).copyWith(
                  fontSize: 52,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Buy and sell, simply.',
                style: AppTextStyles.bodyMedium(
                    color: textColor.withOpacity(0.7)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
