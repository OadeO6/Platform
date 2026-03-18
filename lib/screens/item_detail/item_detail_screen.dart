import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_decorations.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/date_utils.dart' as du;
import '../../core/utils/price_formatter.dart';
import '../../core/extensions/context_extensions.dart';
import '../../models/item_model.dart';
import '../../models/user_model.dart';
import '../../providers/items_provider.dart';
import '../../providers/saved_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_provider.dart';
import '../../services/whatsapp_service.dart';
import '../../widgets/condition_chip.dart';
import '../../widgets/skeleton_loader.dart';
import '../../router/app_router.dart';
import 'widgets/image_gallery.dart';
import 'widgets/seller_block.dart';
import 'widgets/report_bottom_sheet.dart';

class ItemDetailScreen extends ConsumerWidget {
  final String itemId;
  const ItemDetailScreen({super.key, required this.itemId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemAsync = ref.watch(itemDetailProvider(itemId));

    return itemAsync.when(
      loading: () => const _DetailSkeleton(),
      error: (_, __) => const _ErrorState(),
      data: (item) {
        if (item == null) {
          return const _UnavailableState();
        }
        if (item.isSold) {
          return _ItemDetailContent(item: item, isSoldView: true);
        }
        if (!item.isActive || du.DateUtils.isExpired(item.expiresAt ?? DateTime(0))) {
          return const _UnavailableState();
        }
        return _ItemDetailContent(item: item, isSoldView: false);
      },
    );
  }
}

// ── Main content ──────────────────────────────────────────────────────────────

class _ItemDetailContent extends ConsumerStatefulWidget {
  final ItemModel item;
  final bool isSoldView;

  const _ItemDetailContent({required this.item, required this.isSoldView});

  @override
  ConsumerState<_ItemDetailContent> createState() =>
      _ItemDetailContentState();
}

class _ItemDetailContentState extends ConsumerState<_ItemDetailContent> {
  bool _descExpanded = false;
  static const _descPreviewLength = 160;

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final currentUserId = ref.watch(currentUserIdProvider);
    final isSaved = ref.watch(isItemSavedProvider(item.id));
    final isOwnItem = currentUserId == item.sellerId;
    final isDark = context.isDark;

    return Scaffold(
      backgroundColor: context.backgroundColor,
      body: CustomScrollView(
        slivers: [
          // ── App bar ────────────────────────────────────────────────────
          SliverAppBar(
            pinned: true,
            backgroundColor: context.backgroundColor,
            elevation: 0,
            scrolledUnderElevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios_new_rounded,
                  color: context.textPrimaryColor, size: 20),
              onPressed: () => context.pop(),
            ),
            actions: [
              // Share
              IconButton(
                icon: Icon(Icons.ios_share_rounded,
                    color: context.textPrimaryColor, size: 22),
                onPressed: () {
                  // TODO: implement share
                },
              ),
              // Report (only for other people's items)
              if (!isOwnItem)
                IconButton(
                  icon: Icon(Icons.flag_outlined,
                      color: context.textSecondaryColor, size: 22),
                  onPressed: () =>
                      ReportBottomSheet.show(context, item.id),
                ),
              const SizedBox(width: 4),
            ],
          ),

          // ── Image gallery ──────────────────────────────────────────────
          SliverToBoxAdapter(
            child: ImageGallery(imageUrls: item.imageUrls),
          ),

          // ── Content ────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Chips row ────────────────────────────────────────
                  Row(
                    children: [
                      ConditionChip(label: item.condition),
                      const SizedBox(width: 8),
                      ConditionChip(label: item.category),
                      const Spacer(),
                      if (item.isPopular) const PopularBadge(),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // ── Title ────────────────────────────────────────────
                  Text(
                    item.title,
                    style: AppTextStyles.headlineMedium(
                        color: context.textPrimaryColor),
                  ),

                  const SizedBox(height: 10),

                  // ── Price (Caveat) ────────────────────────────────────
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        PriceFormatter.format(item.price),
                        style: AppTextStyles.displayLarge(
                            color: context.primaryColor),
                      ),
                      if (item.priceNegotiable) ...[
                        const SizedBox(width: 8),
                        Text(
                          AppStrings.negotiable,
                          style: AppTextStyles.bodySmall(
                              color: context.textSecondaryColor),
                        ),
                      ],
                    ],
                  ),

                  const SizedBox(height: 12),

                  // ── Meta row ─────────────────────────────────────────
                  _MetaRow(item: item),

                  const SizedBox(height: 20),

                  // ── Divider ──────────────────────────────────────────
                  Divider(color: context.dividerColor, height: 1),

                  const SizedBox(height: 20),

                  // ── Description ──────────────────────────────────────
                  if (item.hasDescription) ...[
                    _DescriptionBlock(
                      description: item.description!,
                      expanded: _descExpanded,
                      onToggle: () =>
                          setState(() => _descExpanded = !_descExpanded),
                      previewLength: _descPreviewLength,
                    ),
                    const SizedBox(height: 20),
                    Divider(color: context.dividerColor, height: 1),
                    const SizedBox(height: 20),
                  ],

                  // ── Seller block ─────────────────────────────────────
                  _SellerSection(sellerId: item.sellerId),

                  const SizedBox(height: 100), // space for sticky bar
                ],
              ),
            ),
          ),
        ],
      ),

      // ── Sticky bottom bar ──────────────────────────────────────────────
      bottomNavigationBar: widget.isSoldView
          ? _SoldBar()
          : isOwnItem
              ? null // No action bar for own items
              : _ActionBar(item: item, isSaved: isSaved),
    );
  }
}

// ── Meta row ──────────────────────────────────────────────────────────────────

class _MetaRow extends StatelessWidget {
  final ItemModel item;
  const _MetaRow({required this.item});

  @override
  Widget build(BuildContext context) {
    final textSecondary = context.textSecondaryColor;

    return Wrap(
      spacing: 16,
      runSpacing: 4,
      children: [
        // Location
        if (item.city != null)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.location_on_outlined,
                  size: 13, color: textSecondary),
              const SizedBox(width: 3),
              Text(item.locationDisplay,
                  style: AppTextStyles.bodySmall(color: textSecondary)),
            ],
          ),

        // Posted / Edited
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.access_time_rounded,
                size: 13, color: textSecondary),
            const SizedBox(width: 3),
            Text(
              item.edited
                  ? '${AppStrings.edited} ${du.DateUtils.formatEditedAt(item.updatedAt)}'
                  : '${AppStrings.posted} ${du.DateUtils.timeAgo(item.createdAt)}',
              style: AppTextStyles.bodySmall(color: textSecondary),
            ),
          ],
        ),
      ],
    );
  }
}

// ── Description block ─────────────────────────────────────────────────────────

class _DescriptionBlock extends StatelessWidget {
  final String description;
  final bool expanded;
  final VoidCallback onToggle;
  final int previewLength;

  const _DescriptionBlock({
    required this.description,
    required this.expanded,
    required this.onToggle,
    required this.previewLength,
  });

  bool get _isLong => description.length > previewLength;

  @override
  Widget build(BuildContext context) {
    final textPrimary = context.textPrimaryColor;
    final primaryColor = context.primaryColor;
    final displayText = (!expanded && _isLong)
        ? '${description.substring(0, previewLength)}...'
        : description;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          displayText,
          style: AppTextStyles.bodyLarge(color: textPrimary),
        ),
        if (_isLong) ...[
          const SizedBox(height: 6),
          GestureDetector(
            onTap: onToggle,
            child: Text(
              expanded ? AppStrings.readLess : AppStrings.readMore,
              style: AppTextStyles.labelMedium(color: primaryColor),
            ),
          ),
        ],
      ],
    );
  }
}

// ── Seller section ────────────────────────────────────────────────────────────

class _SellerSection extends ConsumerWidget {
  final String sellerId;
  const _SellerSection({required this.sellerId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sellerAsync = ref.watch(sellerProfileProvider(sellerId));

    return sellerAsync.when(
      loading: () => SkeletonLoader.box(width: double.infinity, height: 72),
      error: (_, __) => const SizedBox.shrink(),
      data: (seller) {
        if (seller == null) return const SizedBox.shrink();
        return SellerBlock(seller: seller);
      },
    );
  }
}

// ── Action bar (Save + WhatsApp) ─────────────────────────────────────────────

class _ActionBar extends ConsumerWidget {
  final ItemModel item;
  final bool isSaved;

  const _ActionBar({required this.item, required this.isSaved});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = context.isDark;
    final bgColor = isDark ? AppColors.darkSurface : AppColors.surface;
    final borderColor = context.dividerColor;

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        border: Border(top: BorderSide(color: borderColor, width: 1)),
      ),
      padding: EdgeInsets.fromLTRB(
          16, 12, 16, 12 + MediaQuery.of(context).padding.bottom),
      child: Row(
        children: [
          // Save button
          _SaveButton(itemId: item.id, isSaved: isSaved),
          const SizedBox(width: 12),

          // WhatsApp button
          Expanded(
            child: SizedBox(
              height: 52,
              child: ElevatedButton.icon(
                onPressed: () async {
                  try {
                    await WhatsAppService().contactSeller(
                      phone: item.whatsappContact,
                      itemTitle: item.title,
                      itemId: item.id,
                    );
                  } catch (e) {
                    if (context.mounted) {
                      context.showSnackBar(e.toString(), isError: true);
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.whatsapp,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: AppDecorations.defaultRadius,
                  ),
                ),
                icon: const Icon(Icons.chat_rounded, size: 18),
                label: Text(
                  AppStrings.contactOnWhatsApp,
                  style: AppTextStyles.labelLarge(color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SaveButton extends ConsumerWidget {
  final String itemId;
  final bool isSaved;

  const _SaveButton({required this.itemId, required this.isSaved});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = context.isDark;
    final borderColor = context.dividerColor;
    final primaryColor = context.primaryColor;

    return GestureDetector(
      onTap: () {
        ref
            .read(savedNotifierProvider.notifier)
            .toggleSave(itemId, currentlySaved: isSaved);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: isSaved ? primaryColor.withOpacity(0.1) : Colors.transparent,
          borderRadius: AppDecorations.defaultRadius,
          border: Border.all(
            color: isSaved ? primaryColor : borderColor,
            width: 1.5,
          ),
        ),
        child: Icon(
          isSaved ? Icons.bookmark_rounded : Icons.bookmark_outline_rounded,
          color: isSaved ? primaryColor : context.textSecondaryColor,
          size: 22,
        ),
      ),
    );
  }
}

// ── Sold bar ──────────────────────────────────────────────────────────────────

class _SoldBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.surface,
        border: Border(
            top: BorderSide(color: context.dividerColor, width: 1)),
      ),
      padding: EdgeInsets.fromLTRB(
          16, 12, 16, 12 + MediaQuery.of(context).padding.bottom),
      child: Container(
        width: double.infinity,
        height: 52,
        decoration: BoxDecoration(
          color: AppColors.success.withOpacity(0.1),
          borderRadius: AppDecorations.defaultRadius,
          border: Border.all(color: AppColors.success.withOpacity(0.4)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_outline_rounded,
                color: AppColors.success, size: 18),
            const SizedBox(width: 8),
            Text(
              AppStrings.itemSold,
              style: AppTextStyles.labelLarge(color: AppColors.success),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Skeleton / Error / Unavailable states ─────────────────────────────────────

class _DetailSkeleton extends StatelessWidget {
  const _DetailSkeleton();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.backgroundColor,
      body: SkeletonLoader.itemDetail(),
    );
  }
}

class _UnavailableState extends StatelessWidget {
  const _UnavailableState();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.backgroundColor,
      appBar: AppBar(
        backgroundColor: context.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              color: context.textPrimaryColor, size: 20),
          onPressed: () => context.pop(),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.link_off_rounded,
                  size: 52,
                  color: context.textSecondaryColor.withOpacity(0.3)),
              const SizedBox(height: 20),
              Text(
                AppStrings.itemUnavailable,
                style: AppTextStyles.displaySmall(
                    color: context.textPrimaryColor),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                AppStrings.itemUnavailableSubtitle,
                style: AppTextStyles.bodyMedium(
                    color: context.textSecondaryColor),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () => context.go(AppRoutes.home),
                  child: Text(AppStrings.browseListings),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.backgroundColor,
      appBar: AppBar(
        backgroundColor: context.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              color: context.textPrimaryColor, size: 20),
          onPressed: () => context.pop(),
        ),
      ),
      body: Center(
        child: Text(
          AppStrings.genericError,
          style: AppTextStyles.bodyMedium(color: context.textSecondaryColor),
        ),
      ),
    );
  }
}
