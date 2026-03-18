import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_decorations.dart';
import '../../../core/utils/date_utils.dart' as du;
import '../../../core/utils/price_formatter.dart';
import '../../../models/item_model.dart';
import '../../../widgets/condition_chip.dart';

/// Grid variant of the feed item card.
/// Cover image fills the top, details below.
class FeedItemCardGrid extends StatelessWidget {
  final ItemModel item;
  final VoidCallback onTap;

  const FeedItemCardGrid({
    super.key,
    required this.item,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final decoration = isDark ? AppDecorations.cardDark : AppDecorations.card;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: decoration,
        child: ClipRRect(
          borderRadius: AppDecorations.defaultRadius,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cover image
              Expanded(
                flex: 3,
                child: _CoverImage(
                  imageUrl: item.coverImage,
                  isPopular: item.isPopular,
                ),
              ),

              // Details
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        item.title,
                        style: AppTextStyles.labelLarge(
                          color: isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.textPrimary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                      const Spacer(),

                      // Price
                      Text(
                        PriceFormatter.formatWithNegotiable(
                          item.price,
                          negotiable: item.priceNegotiable,
                        ),
                        style: AppTextStyles.labelLarge(
                          color: isDark
                              ? AppColors.darkPrimary
                              : AppColors.primary,
                        ).copyWith(fontWeight: FontWeight.w700),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),

                      const SizedBox(height: 4),

                      // Location + time
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 11,
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.textSecondary,
                          ),
                          const SizedBox(width: 2),
                          Expanded(
                            child: Text(
                              item.city ?? '',
                              style: AppTextStyles.labelSmall(
                                color: isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.textSecondary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
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

/// List variant of the feed item card.
/// Horizontal layout — image on left, details on right.
class FeedItemCardList extends StatelessWidget {
  final ItemModel item;
  final VoidCallback onTap;

  const FeedItemCardList({
    super.key,
    required this.item,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final decoration = isDark ? AppDecorations.cardDark : AppDecorations.card;
    final textPrimary =
        isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final textSecondary =
        isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
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
              // Image
              SizedBox(
                width: 108,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    _CoverImage(
                      imageUrl: item.coverImage,
                      isPopular: false,
                    ),
                    if (item.isPopular)
                      Positioned(
                        top: 8,
                        left: 8,
                        child: const PopularBadge(),
                      ),
                  ],
                ),
              ),

              // Details
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        item.title,
                        style: AppTextStyles.labelLarge(color: textPrimary),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                      const Spacer(),

                      // Condition chip
                      ConditionChip(label: item.condition),

                      const SizedBox(height: 6),

                      // Price + location row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            PriceFormatter.format(item.price),
                            style: AppTextStyles.labelLarge(
                              color: primaryColor,
                            ).copyWith(fontWeight: FontWeight.w700),
                          ),
                          Row(
                            children: [
                              Icon(
                                Icons.location_on_outlined,
                                size: 11,
                                color: textSecondary,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                item.city ?? '',
                                style:
                                    AppTextStyles.labelSmall(color: textSecondary),
                              ),
                            ],
                          ),
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

/// Cover image with shimmer placeholder and popular badge.
class _CoverImage extends StatelessWidget {
  final String? imageUrl;
  final bool isPopular;

  const _CoverImage({this.imageUrl, required this.isPopular});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final placeholderColor =
        isDark ? AppColors.darkDivider : AppColors.divider;

    return Stack(
      fit: StackFit.expand,
      children: [
        imageUrl != null
            ? CachedNetworkImage(
                imageUrl: imageUrl!,
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(color: placeholderColor),
                errorWidget: (_, __, ___) => Container(
                  color: placeholderColor,
                  child: Icon(
                    Icons.image_not_supported_outlined,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.textSecondary,
                    size: 24,
                  ),
                ),
              )
            : Container(color: placeholderColor),

        if (isPopular)
          Positioned(
            top: 8,
            left: 8,
            child: const PopularBadge(),
          ),
      ],
    );
  }
}
