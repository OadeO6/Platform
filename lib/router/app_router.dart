import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/app_constants.dart';
import '../providers/auth_provider.dart';
import '../screens/splash/splash_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/onboarding/onboarding_screen.dart';
import '../screens/home/main_shell.dart';
import '../screens/home/home_screen.dart';
import '../screens/saved/saved_screen.dart';
import '../screens/my_space/my_space_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/item_detail/item_detail_screen.dart';
import '../screens/create_item/create_item_screen.dart';
import '../screens/create_item/edit_item_screen.dart';
import '../screens/seller_listings/seller_listings_screen.dart';
import '../screens/notifications/notifications_screen.dart';
import '../screens/item_unavailable/item_unavailable_screen.dart';
import '../models/item_model.dart';
import '../services/notification_service.dart';

class AppRoutes {
  AppRoutes._();

  static const String splash          = '/';
  static const String login           = '/login';
  static const String onboarding      = '/onboarding';
  static const String home            = '/home';
  static const String itemDetail      = '/item/:id';
  static const String mySpace         = '/my-space';
  static const String createItem      = '/create-item';
  static const String editItem        = '/edit-item/:id';
  static const String saved           = '/saved';
  static const String profile         = '/profile';
  static const String notifications   = '/notifications';
  static const String itemUnavailable = '/unavailable';
  static const String sellerListings  = '/seller/:id/listings';

  static String itemDetailPath(String id) => '/item/$id';
  static String editItemPath(String id)   => '/edit-item/$id';
  static String sellerListingsPath(String id) => '/seller/$id/listings';
}

/// Cached onboarding flag — read once at startup, avoids async in redirect.
bool _onboardingSeen = false;

Future<void> initRouterPrefs() async {
  final prefs = await SharedPreferences.getInstance();
  _onboardingSeen = prefs.getBool(AppConstants.prefOnboardingSeen) ?? false;
}

final routerProvider = Provider<GoRouter>((ref) {
  final authNotifier = ValueNotifier<bool>(false);

  ref.listen(authStateProvider, (_, __) {
    authNotifier.value = !authNotifier.value;
  });

  final router = GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: false,
    refreshListenable: authNotifier,
    redirect: (context, state) {
      final authAsync = ref.read(authStateProvider);
      if (authAsync.isLoading) return null;

      final isAuthenticated = authAsync.value != null;
      final location = state.matchedLocation;

      // Consume pending deep-link from notification tap
      final pending = pendingNotificationRoute;
      if (pending != null && isAuthenticated) {
        pendingNotificationRoute = null;
        return pending;
      }

      final publicRoutes = [
        AppRoutes.splash,
        AppRoutes.login,
        AppRoutes.onboarding,
      ];
      final isPublic = publicRoutes.contains(location);

      if (isAuthenticated && isPublic && location != AppRoutes.splash) {
        return AppRoutes.home;
      }
      if (!isAuthenticated && !isPublic) {
        return _onboardingSeen ? AppRoutes.login : AppRoutes.onboarding;
      }
      return null;
    },
    routes: [
      // ── Public ─────────────────────────────────────────────────────────
      GoRoute(path: AppRoutes.splash,     builder: (_, __) => const SplashScreen()),
      GoRoute(path: AppRoutes.login,      builder: (_, __) => const LoginScreen()),
      GoRoute(path: AppRoutes.onboarding, builder: (_, __) => const OnboardingScreen()),

      // ── Shell (bottom nav) ──────────────────────────────────────────────
      ShellRoute(
        builder: (_, __, child) => MainShell(child: child),
        routes: [
          GoRoute(path: AppRoutes.home,    builder: (_, __) => const HomeScreen()),
          GoRoute(path: AppRoutes.saved,   builder: (_, __) => const SavedScreen()),
          GoRoute(path: AppRoutes.mySpace, builder: (_, __) => const MySpaceScreen()),
          GoRoute(path: AppRoutes.profile, builder: (_, __) => const ProfileScreen()),
        ],
      ),

      // ── Full-screen ─────────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.itemDetail,
        builder: (_, s) => ItemDetailScreen(itemId: s.pathParameters['id']!),
      ),
      GoRoute(
        path: AppRoutes.createItem,
        builder: (_, s) => CreateItemScreen(template: s.extra as ItemModel?),
      ),
      GoRoute(
        path: AppRoutes.editItem,
        builder: (_, s) => EditItemScreen(itemId: s.pathParameters['id']!),
      ),
      GoRoute(
        path: AppRoutes.sellerListings,
        builder: (_, s) =>
            SellerListingsScreen(sellerId: s.pathParameters['id']!),
      ),
      GoRoute(
        path: AppRoutes.notifications,
        builder: (_, __) => const NotificationsScreen(),
      ),
      GoRoute(
        path: AppRoutes.itemUnavailable,
        builder: (_, __) => const ItemUnavailableScreen(),
      ),
    ],
    errorBuilder: (_, __) => const _404Screen(),
  );

  return router;
});

class _404Screen extends StatelessWidget {
  const _404Screen();

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Center(
          child: Text('Page not found',
              style: Theme.of(context).textTheme.bodyLarge),
        ),
      );
}
