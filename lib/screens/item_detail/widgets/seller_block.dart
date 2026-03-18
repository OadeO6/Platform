import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_decorations.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/date_utils.dart' as du;
import '../../../models/user_model.dart';
import '../../../router/app_router.dart';

/// Seller info block shown on item detail page.
/// Shows avatar, display name, city, member since.
/// Tapping the block or "View Other Listings" opens the seller's listings.
class SellerBlock extends StatelessWidget {
  final UserModel seller;

  const SellerBlock({super.key, required this.seller});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary =
        isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final textSecondary =
        isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    final primaryColor = isDark ? AppColors.darkPrimary : AppColors.primary;
    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.surface;
    final borderColor = isDark ? AppColors.darkDivider : AppColors.divider;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: AppDecorations.defaultRadius,
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          // ── Avatar ─────────────────────────────────────────────────────
          _SellerAvatar(photoUrl: seller.photoUrl, name: seller.displayName),

          const SizedBox(width: 12),

          // ── Info ───────────────────────────────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  seller.displayName,
                  style: AppTextStyles.labelLarge(color: textPrimary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    if (seller.hasLocation) ...[
                      Icon(
                        Icons.location_on_outlined,
                        size: 12,
                        color: textSecondary,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        seller.city ?? '',
                        style: AppTextStyles.bodySmall(color: textSecondary),
                      ),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      '${AppStrings.memberSince} ${du.DateUtils.formatMonthYear(seller.memberSince)}',
                      style: AppTextStyles.bodySmall(color: textSecondary),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ── View listings arrow ────────────────────────────────────────
          GestureDetector(
            onTap: () => context.push(
              AppRoutes.sellerListingsPath(seller.id),
            ),
            child: Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Icon(
                Icons.chevron_right_rounded,
                color: textSecondary,
                size: 22,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Seller block as a bottom sheet variant — shown when tapping seller name.
class SellerBottomSheet extends StatelessWidget {
  final UserModel seller;

  const SellerBottomSheet({super.key, required this.seller});

  static Future<void> show(BuildContext context, UserModel seller) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => SellerBottomSheet(seller: seller),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.darkSurface : AppColors.surface;
    final textPrimary =
        isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final textSecondary =
        isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    final primaryColor = isDark ? AppColors.darkPrimary : AppColors.primary;
    final dividerColor = isDark ? AppColors.darkDivider : AppColors.divider;

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius:
            const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 20),
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: dividerColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),

          // Avatar
          _SellerAvatar(
            photoUrl: seller.photoUrl,
            name: seller.displayName,
            size: 64,
          ),

          const SizedBox(height: 14),

          // Name
          Text(
            seller.displayName,
            style: AppTextStyles.headlineMedium(color: textPrimary),
          ),

          const SizedBox(height: 4),

          // Location + member since
          if (seller.hasLocation)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.location_on_outlined,
                    size: 13, color: textSecondary),
                const SizedBox(width: 2),
                Text(seller.city ?? '',
                    style: AppTextStyles.bodyMedium(color: textSecondary)),
              ],
            ),

          const SizedBox(height: 2),

          Text(
            '${AppStrings.memberSince} ${du.DateUtils.formatMonthYear(seller.memberSince)}',
            style: AppTextStyles.bodySmall(color: textSecondary),
          ),

          const SizedBox(height: 24),

          // View listings button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton(
              onPressed: () {
                Navigator.pop(context);
                context.push(AppRoutes.sellerListingsPath(seller.id));
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: primaryColor,
                side: BorderSide(color: primaryColor, width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: AppDecorations.defaultRadius,
                ),
              ),
              child: Text(
                AppStrings.viewOtherListings,
                style: AppTextStyles.labelLarge(color: primaryColor),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SellerAvatar extends StatelessWidget {
  final String? photoUrl;
  final String name;
  final double size;

  const _SellerAvatar({
    this.photoUrl,
    required this.name,
    this.size = 42,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor =
        isDark ? AppColors.darkPrimaryTint : AppColors.primaryTint;
    final textColor = isDark ? AppColors.darkPrimary : AppColors.primary;
    final initial =
        name.isNotEmpty ? name[0].toUpperCase() : '?';

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: bgColor,
      ),
      clipBehavior: Clip.antiAlias,
      child: photoUrl != null && photoUrl!.isNotEmpty
          ? CachedNetworkImage(
              imageUrl: photoUrl!,
              fit: BoxFit.cover,
              placeholder: (_, __) => Container(color: bgColor),
              errorWidget: (_, __, ___) => Center(
                child: Text(
                  initial,
                  style: TextStyle(
                    color: textColor,
                    fontSize: size * 0.4,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            )
          : Center(
              child: Text(
                initial,
                style: TextStyle(
                  color: textColor,
                  fontSize: size * 0.4,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
    );
  }
}
