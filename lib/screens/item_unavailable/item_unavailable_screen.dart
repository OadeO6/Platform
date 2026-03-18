import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/extensions/context_extensions.dart';
import '../../core/theme/app_text_styles.dart';
import '../../router/app_router.dart';
import '../../widgets/platform_button.dart';

class ItemUnavailableScreen extends StatelessWidget {
  const ItemUnavailableScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.link_off_rounded,
                size: 64,
                color: context.textSecondaryColor.withOpacity(0.4),
              ),
              const SizedBox(height: 24),
              Text(
                'This listing is no longer available',
                style: AppTextStyles.headlineMedium(
                    color: context.textPrimaryColor),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'It may have been sold, removed, or the link has expired.',
                style: AppTextStyles.bodyMedium(
                    color: context.textSecondaryColor),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              PlatformButton(
                label: 'Browse other listings',
                onPressed: () => context.go(AppRoutes.home),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => context.pop(),
                child: Text(
                  'Go back',
                  style: AppTextStyles.labelMedium(
                      color: context.textSecondaryColor),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
