import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_strings.dart';
import '../../core/extensions/context_extensions.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_decorations.dart';
import '../../core/utils/date_utils.dart' as du;
import '../../models/item_model.dart';
import '../../models/user_model.dart';
import '../../providers/items_provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/user_provider.dart';
import '../../router/app_router.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/skeleton_loader.dart';
import '../home/widgets/feed_item_card.dart';
import '../item_detail/widgets/seller_block.dart';

// ── Provider ──────────────────────────────────────────────────────────────────

final sellerListingsProvider =
    FutureProvider.family<List<ItemModel>, String>((ref, sellerId) {
  return ref.watch(firestoreServiceProvider).getSellerListings(sellerId);
});

// ── Screen ────────────────────────────────────────────────────────────────────

class SellerListingsScreen extends ConsumerWidget {
  final String sellerId;
  const SellerListingsScreen({super.key, required this.sellerId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sellerAsync = ref.watch(sellerProfileProvider(sellerId));
    final listingsAsync = ref.watch(sellerListingsProvider(sellerId));

    return Scaffold(
      backgroundColor: context.backgroundColor,
      appBar: AppBar(
        backgroundColor: context.backgroundColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              color: context.textPrimaryColor, size: 20),
          onPressed: () => context.pop(),
        ),
        title: sellerAsync.when(
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
          data: (seller) => seller == null
              ? const SizedBox.shrink()
              : Text(
                  seller.displayName,
                  style: AppTextStyles.labelLarge(
                      color: context.textPrimaryColor),
                ),
        ),
      ),
      body: CustomScrollView(
        slivers: [
          // ── Seller info header ────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: sellerAsync.when(
                loading: () =>
                    SkeletonLoader.box(width: double.infinity, height: 80),
                error: (_, __) => const SizedBox.shrink(),
                data: (seller) => seller == null
                    ? const SizedBox.shrink()
                    : _SellerHeader(seller: seller),
              ),
            ),
          ),

          // ── Listings count ────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
              child: listingsAsync.when(
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
                data: (items) => Text(
                  '${items.length} ${items.length == 1 ? 'listing' : 'listings'}',
                  style: AppTextStyles.labelMedium(
                      color: context.textSecondaryColor),
                ),
              ),
            ),
          ),

          // ── Listings grid ─────────────────────────────────────────────
          listingsAsync.when(
            loading: () => SliverToBoxAdapter(
              child: SkeletonLoader.feedGrid(itemCount: 4),
            ),
            error: (_, __) => SliverFillRemaining(
              child: Center(
                child: Text(AppStrings.genericError,
                    style: AppTextStyles.bodyMedium(
                        color: context.textSecondaryColor)),
              ),
            ),
            data: (items) {
              if (items.isEmpty) {
                return const SliverFillRemaining(
                  child: EmptyState(
                    icon: Icons.storefront_outlined,
                    title: 'No active listings.',
                    subtitle: 'This seller has nothing listed right now.',
                  ),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.all(AppConstants.screenPadding),
                sliver: SliverGrid(
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.70,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final item = items[index];
                      return FeedItemCardGrid(
                        item: item,
                        onTap: () => context
                            .push(AppRoutes.itemDetailPath(item.id)),
                      );
                    },
                    childCount: items.length,
                  ),
                ),
              );
            },
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }
}

// ── Seller header ─────────────────────────────────────────────────────────────

class _SellerHeader extends StatelessWidget {
  final UserModel seller;
  const _SellerHeader({required this.seller});

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.surface;
    final borderColor = context.dividerColor;
    final textSecondary = context.textSecondaryColor;
    final bgColor =
        isDark ? AppColors.darkPrimaryTint : AppColors.primaryTint;
    final avatarTextColor =
        isDark ? AppColors.darkPrimary : AppColors.primary;
    final initial = seller.displayName.isNotEmpty
        ? seller.displayName[0].toUpperCase()
        : '?';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: AppDecorations.defaultRadius,
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(shape: BoxShape.circle, color: bgColor),
            clipBehavior: Clip.antiAlias,
            child: seller.photoUrl != null && seller.photoUrl!.isNotEmpty
                ? Image.network(seller.photoUrl!, fit: BoxFit.cover)
                : Center(
                    child: Text(
                      initial,
                      style: TextStyle(
                          color: avatarTextColor,
                          fontSize: 20,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
          ),
          const SizedBox(width: 12),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  seller.displayName,
                  style: AppTextStyles.labelLarge(
                      color: context.textPrimaryColor),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    if (seller.hasLocation) ...[
                      Icon(Icons.location_on_outlined,
                          size: 12, color: textSecondary),
                      const SizedBox(width: 2),
                      Text(seller.city ?? '',
                          style:
                              AppTextStyles.bodySmall(color: textSecondary)),
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
        ],
      ),
    );
  }
}
