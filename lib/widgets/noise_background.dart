import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

/// Wraps its child with the subtle grain texture overlay used in light mode.
/// In dark mode, the texture is hidden — dark mode uses a flat background.
///
/// Usage:
/// ```dart
/// NoiseBackground(child: Scaffold(...))
/// ```
class NoiseBackground extends StatelessWidget {
  final Widget child;

  const NoiseBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Dark mode — no texture, just flat background
    if (isDark) return child;

    return Stack(
      children: [
        // Base background colour
        Positioned.fill(
          child: ColoredBox(color: AppColors.background),
        ),
        // Grain texture overlay at 4% opacity
        Positioned.fill(
          child: Opacity(
            opacity: 0.04,
            child: Image.asset(
              'assets/images/noise.png',
              repeat: ImageRepeat.repeat,
              fit: BoxFit.none,
            ),
          ),
        ),
        // Actual content
        child,
      ],
    );
  }
}
