import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../core/extensions/context_extensions.dart';
import '../providers/auth_provider.dart';
import '../providers/user_provider.dart';
import '../providers/items_provider.dart';

/// State for location refresh operations.
class LocationRefreshState {
  final bool isLoading;
  final bool success;
  final String? error;
  const LocationRefreshState({
    this.isLoading = false,
    this.success = false,
    this.error,
  });
}

final locationRefreshProvider =
    StateNotifierProvider<LocationRefreshNotifier, LocationRefreshState>(
  (_) => LocationRefreshNotifier(),
);

class LocationRefreshNotifier
    extends StateNotifier<LocationRefreshState> {
  LocationRefreshNotifier() : super(const LocationRefreshState());

  Future<void> refresh(WidgetRef ref) async {
    state = const LocationRefreshState(isLoading: true);
    try {
      final userId = ref.read(currentUserIdProvider);
      if (userId == null) {
        state = const LocationRefreshState(error: 'Not signed in.');
        return;
      }

      final locationService = ref.read(locationServiceProvider);
      final result = await locationService.getCurrentLocation();

      if (!result.hasLocation) {
        state = const LocationRefreshState(
          error: 'Could not detect location. Make sure location permission is granted in your device settings.',
        );
        return;
      }

      await ref.read(userProfileNotifierProvider.notifier).updateLocation(
            userId,
            city: result.city!,
            area: result.area ?? '',
            latitude: result.latitude ?? 0,
            longitude: result.longitude ?? 0,
          );

      state = LocationRefreshState(success: true);
    } catch (e) {
      state = LocationRefreshState(error: e.toString());
    }
  }

  void reset() => state = const LocationRefreshState();
}

/// Banner shown when the user's location is not set.
/// Shows a warning with a "Detect" button.
/// Pass [context] label to tailor the message (e.g. "nearby listings").
class LocationWarningBanner extends ConsumerWidget {
  /// What feature needs location — shown in the message.
  final String featureLabel;

  /// If true, shows as a compact inline chip instead of a full banner.
  final bool compact;

  const LocationWarningBanner({
    super.key,
    this.featureLabel = 'nearby listings',
    this.compact = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserValueProvider);
    final hasLocation = user?.hasLocation ?? false;
    final refreshState = ref.watch(locationRefreshProvider);

    // Don't show if location is already set
    if (hasLocation) return const SizedBox.shrink();

    if (compact) {
      return _CompactBanner(
        featureLabel: featureLabel,
        refreshState: refreshState,
        onDetect: () =>
            ref.read(locationRefreshProvider.notifier).refresh(ref),
      );
    }

    return _FullBanner(
      featureLabel: featureLabel,
      refreshState: refreshState,
      onDetect: () =>
          ref.read(locationRefreshProvider.notifier).refresh(ref),
    );
  }
}

class _FullBanner extends StatelessWidget {
  final String featureLabel;
  final LocationRefreshState refreshState;
  final VoidCallback onDetect;

  const _FullBanner({
    required this.featureLabel,
    required this.refreshState,
    required this.onDetect,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final warningColor = context.warningColor;
    final bgColor = isDark
        ? AppColors.warningDark.withOpacity(0.12)
        : AppColors.warning.withOpacity(0.08);
    final borderColor = warningColor.withOpacity(0.3);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Icon(Icons.location_off_outlined, size: 18, color: warningColor),
          const SizedBox(width: 10),
          Expanded(
            child: refreshState.error != null
                ? Text(
                    refreshState.error!,
                    style:
                        AppTextStyles.bodySmall(color: context.textPrimaryColor),
                  )
                : Text(
                    'Enable location to see $featureLabel first.',
                    style:
                        AppTextStyles.bodySmall(color: context.textPrimaryColor),
                  ),
          ),
          const SizedBox(width: 8),
          if (refreshState.isLoading)
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: warningColor),
            )
          else
            GestureDetector(
              onTap: onDetect,
              child: Text(
                refreshState.error != null ? 'Retry' : 'Detect',
                style: AppTextStyles.labelMedium(color: context.primaryColor),
              ),
            ),
        ],
      ),
    );
  }
}

class _CompactBanner extends StatelessWidget {
  final String featureLabel;
  final LocationRefreshState refreshState;
  final VoidCallback onDetect;

  const _CompactBanner({
    required this.featureLabel,
    required this.refreshState,
    required this.onDetect,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;

    return GestureDetector(
      onTap: refreshState.isLoading ? null : onDetect,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.surface,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(color: context.dividerColor),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (refreshState.isLoading)
              SizedBox(
                width: 12,
                height: 12,
                child: CircularProgressIndicator(
                    strokeWidth: 1.5,
                    color: context.textSecondaryColor),
              )
            else
              Icon(Icons.location_searching_rounded,
                  size: 12, color: context.textSecondaryColor),
            const SizedBox(width: 4),
            Text(
              refreshState.isLoading ? 'Detecting...' : 'Detect location',
              style: AppTextStyles.labelSmall(
                  color: context.textSecondaryColor),
            ),
          ],
        ),
      ),
    );
  }
}
