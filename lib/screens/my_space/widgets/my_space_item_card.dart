import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_decorations.dart';
import '../../../core/utils/date_utils.dart' as du;
import '../../../core/utils/price_formatter.dart';
import '../../../models/item_model.dart';
import '../../../widgets/condition_chip.dart';

class MySpaceItemCardGrid extends StatelessWidget {
  final ItemModel item;
  final VoidCallback onTap;
  final VoidCallback onManage;

  const MySpaceItemCardGrid({
    super.key,
    required this.item,
    required this.onTap,
    required this.onManage,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final decoration = isDark ? AppDecorations.cardDark : AppDecorations.card;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final primaryColor = isDark ? AppColors.darkPrimary : AppColors.primary;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: decoration,
        child: ClipRRect(
          borderRadius: AppDecorations.defaultRadius,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    _CoverImage(imageUrl: item.coverImage, isDark: isDark),
                    if (item.isSold)
                      Container(
                        color: Colors.black.withOpacity(0.4),
                        child: const Center(child: SoldBadge()),
                      ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: _ManageButton(onTap: onManage, isDark: isDark),
                    ),
                    if (item.isActive &&
                        item.expiresAt != null &&
                        du.DateUtils.isNearExpiry(item.expiresAt!))
                      Positioned(
                        bottom: 8,
                        left: 8,
                        child: ExpiryWarningChip(
                          label: du.DateUtils.expiryCountdown(item.expiresAt!),
                        ),
                      ),
                  ],
                ),
              ),
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.title,
                          style: AppTextStyles.labelLarge(color: textPrimary),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis),
                      const Spacer(),
                      Text(
                        PriceFormatter.format(item.price),
                        style: AppTextStyles.labelLarge(color: primaryColor)
                            .copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _statusLabel(item),
                        style: AppTextStyles.labelSmall(
                            color: _statusColor(item, isDark)),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MySpaceItemCardList extends StatelessWidget {
  final ItemModel item;
  final VoidCallback onTap;
  final VoidCallback onManage;

  const MySpaceItemCardList({
    super.key,
    required this.item,
    required this.onTap,
    required this.onManage,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final decoration = isDark ? AppDecorations.cardDark : AppDecorations.card;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final primaryColor = isDark ? AppColors.darkPrimary : AppColors.primary;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 108,
        decoration: decoration,
        child: ClipRRect(
          borderRadius: AppDecorations.defaultRadius,
          child: Row(
            children: [
              SizedBox(
                width: 108,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    _CoverImage(imageUrl: item.coverImage, isDark: isDark),
                    if (item.isSold)
                      Container(
                        color: Colors.black.withOpacity(0.4),
                        child: const Center(child: SoldBadge()),
                      ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(item.title,
                                style: AppTextStyles.labelLarge(color: textPrimary),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis),
                          ),
                          _ManageButton(onTap: onManage, isDark: isDark),
                        ],
                      ),
                      const Spacer(),
                      Text(
                        PriceFormatter.format(item.price),
                        style: AppTextStyles.labelLarge(color: primaryColor)
                            .copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Text(_statusLabel(item),
                              style: AppTextStyles.labelSmall(
                                  color: _statusColor(item, isDark))),
                          if (item.isActive &&
                              item.expiresAt != null &&
                              du.DateUtils.isNearExpiry(item.expiresAt!)) ...[
                            const SizedBox(width: 8),
                            ExpiryWarningChip(
                              label: du.DateUtils.expiryCountdown(item.expiresAt!),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _statusLabel(ItemModel item) {
  if (item.isSold) return 'Sold';
  if (item.isActive) {
    if (item.expiresAt != null) return du.DateUtils.expiryCountdown(item.expiresAt!);
    return 'Listed';
  }
  return 'Unlisted';
}

Color _statusColor(ItemModel item, bool isDark) {
  if (item.isSold) return AppColors.success;
  if (item.isActive) {
    if (item.expiresAt != null && du.DateUtils.isNearExpiry(item.expiresAt!)) {
      return AppColors.warning;
    }
    return isDark ? AppColors.darkPrimary : AppColors.primary;
  }
  return isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
}

class _CoverImage extends StatelessWidget {
  final String? imageUrl;
  final bool isDark;
  const _CoverImage({this.imageUrl, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final placeholder = isDark ? AppColors.darkDivider : AppColors.divider;
    if (imageUrl == null || imageUrl!.isEmpty) return Container(color: placeholder);
    return CachedNetworkImage(
      imageUrl: imageUrl!,
      fit: BoxFit.cover,
      placeholder: (_, __) => Container(color: placeholder),
      errorWidget: (_, __, ___) => Container(
        color: placeholder,
        child: Icon(Icons.image_not_supported_outlined,
            color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
            size: 24),
      ),
    );
  }
}

class _ManageButton extends StatelessWidget {
  final VoidCallback onTap;
  final bool isDark;
  const _ManageButton({required this.onTap, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.darkBackground.withOpacity(0.85)
              : Colors.white.withOpacity(0.92),
          shape: BoxShape.circle,
        ),
        child: Icon(Icons.more_horiz_rounded,
            size: 16,
            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary),
      ),
    );
  }
}
