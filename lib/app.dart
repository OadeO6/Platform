import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';

// TODO: import router and theme provider once built
// import 'router/app_router.dart';
// import 'providers/theme_provider.dart';

/// Root application widget.
/// Wrapped in ProviderScope in main.dart.
class PlatformApp extends ConsumerWidget {
  const PlatformApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // TODO: Replace with themeProvider and routerProvider once implemented
    // final themeMode = ref.watch(themeProvider);
    // final router = ref.watch(routerProvider);

    return MaterialApp(
      title: 'Platform',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      // TODO: Switch to MaterialApp.router once GoRouter is set up
      // routerConfig: router,
      home: const _PlaceholderScreen(),
    );
  }
}

/// Temporary placeholder shown until screens are built.
/// Replace with GoRouter routing once auth + screens are ready.
class _PlaceholderScreen extends StatelessWidget {
  const _PlaceholderScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          'Platform',
          style: Theme.of(context).appBarTheme.titleTextStyle,
        ),
      ),
    );
  }
}
