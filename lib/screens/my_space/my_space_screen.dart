import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_strings.dart';
import '../../core/extensions/context_extensions.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/item_model.dart';
import '../../providers/items_provider.dart';
import '../../providers/auth_provider.dart';
import '../../router/app_router.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/platform_app_bar.dart';
import '../../widgets/skeleton_loader.dart';
import 'widgets/my_space_item_card.dart';
import 'widgets/manage_item_sheet.dart';

class MySpaceScreen extends ConsumerStatefulWidget {
  const MySpaceScreen({super.key});

  @override
  ConsumerState<MySpaceScreen> createState() => _MySpaceScreenState();
}

class _MySpaceScreenState extends ConsumerState<MySpaceScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isGridView = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mySpaceAsync = ref.watch(mySpaceProvider);
    final listedItems = ref.watch(listedItemsProvider);
    final unlistedItems = ref.watch(unlistedItemsProvider);
    final soldItems = ref.watch(soldItemsProvider);
    final isDark = context.isDark;

    // Space + listing counters
    final spaceCount = listedItems.length + unlistedItems.length;
    final listingCount = listedItems.length;

    return Scaffold(
      backgroundColor: context.backgroundColor,
      appBar: PlatformAppBar(
        title: AppStrings.mySpace,
        actions: [
          // Layout toggle
          IconButton(
            icon: Icon(
              _isGridView ? Icons.view_list_rounded : Icons.grid_view_rounded,
              color: context.textSecondaryColor,
              size: 22,
            ),
            onPressed: () => setState(() => _isGridView = !_isGridView),
          ),
        ],
        leading: const SizedBox.shrink(), // No back button — bottom nav tab
      ),
      body: Column(
        children: [
          // ── Counters ──────────────────────────────────────────────────
          _SpaceCounters(
            spaceCount: spaceCount,
            listingCount: listingCount,
          ),

          // ── Tab bar ───────────────────────────────────────────────────
          _SpaceTabBar(
            controller: _tabController,
            listedCount: listedItems.length,
            unlistedCount: unlistedItems.length,
            soldCount: soldItems.length,
          ),

          // ── Tab content ───────────────────────────────────────────────
          Expanded(
            child: mySpaceAsync.when(
              loading: () => _isGridView
                  ? SkeletonLoader.feedGrid(itemCount: 4)
                  : SkeletonLoader.feedList(itemCount: 3),
              error: (e, _) => Center(
                child: Text(AppStrings.genericError,
                    style: AppTextStyles.bodyMedium(
                        color: context.textSecondaryColor)),
              ),
              data: (_) => TabBarView(
                controller: _tabController,
                children: [
                  _ItemTab(
                    items: listedItems,
                    isGridView: _isGridView,
                    emptyIcon: Icons.rocket_launch_outlined,
                    emptyTitle: 'Nothing listed yet.',
                    emptySubtitle: 'List an item to start selling.',
                  ),
                  _ItemTab(
                    items: unlistedItems,
                    isGridView: _isGridView,
                    emptyIcon: Icons.inventory_2_outlined,
                    emptyTitle: 'Nothing unlisted.',
                    emptySubtitle: 'Unlisted items appear here.',
                  ),
                  _ItemTab(
                    items: soldItems,
                    isGridView: _isGridView,
                    emptyIcon: Icons.check_circle_outline_rounded,
                    emptyTitle: 'No sold items yet.',
                    emptySubtitle: 'Mark items as sold when they sell.',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),

      // ── FAB — Create Item ──────────────────────────────────────────────
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push(AppRoutes.createItem),
        backgroundColor:
            isDark ? AppColors.darkPrimary : AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        child: const Icon(Icons.add_rounded, size: 26),
      ),
    );
  }
}

// ── Space counters ────────────────────────────────────────────────────────────

class _SpaceCounters extends StatelessWidget {
  final int spaceCount;
  final int listingCount;

  const _SpaceCounters({
    required this.spaceCount,
    required this.listingCount,
  });

  @override
  Widget build(BuildContext context) {
    final textSecondary = context.textSecondaryColor;
    final primaryColor = context.primaryColor;
    final warningColor = context.warningColor;

    final spaceNearLimit = spaceCount >= AppConstants.spaceCap - 3;
    final listingNearLimit = listingCount >= AppConstants.listingCap - 1;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Row(
        children: [
          _CounterChip(
            label: '$spaceCount/${AppConstants.spaceCap} items in space',
            color: spaceNearLimit ? warningColor : textSecondary,
          ),
          const SizedBox(width: 12),
          _CounterChip(
            label: '$listingCount/${AppConstants.listingCap} listed',
            color: listingNearLimit ? warningColor : textSecondary,
          ),
        ],
      ),
    );
  }
}

class _CounterChip extends StatelessWidget {
  final String label;
  final Color color;

  const _CounterChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: AppTextStyles.labelSmall(color: color),
    );
  }
}

// ── Tab bar ───────────────────────────────────────────────────────────────────

class _SpaceTabBar extends StatelessWidget {
  final TabController controller;
  final int listedCount;
  final int unlistedCount;
  final int soldCount;

  const _SpaceTabBar({
    required this.controller,
    required this.listedCount,
    required this.unlistedCount,
    required this.soldCount,
  });

  @override
  Widget build(BuildContext context) {
    return TabBar(
      controller: controller,
      tabs: [
        Tab(text: '${AppStrings.listed} ($listedCount)'),
        Tab(text: '${AppStrings.unlisted} ($unlistedCount)'),
        Tab(text: '${AppStrings.sold} ($soldCount)'),
      ],
    );
  }
}

// ── Item tab content ──────────────────────────────────────────────────────────

class _ItemTab extends StatelessWidget {
  final List<ItemModel> items;
  final bool isGridView;
  final IconData emptyIcon;
  final String emptyTitle;
  final String emptySubtitle;

  const _ItemTab({
    required this.items,
    required this.isGridView,
    required this.emptyIcon,
    required this.emptyTitle,
    required this.emptySubtitle,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return EmptyState(
        icon: emptyIcon,
        title: emptyTitle,
        subtitle: emptySubtitle,
      );
    }

    if (isGridView) {
      return GridView.builder(
        padding: const EdgeInsets.all(AppConstants.screenPadding),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.70,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return MySpaceItemCardGrid(
            item: item,
            onTap: () => context.push(AppRoutes.itemDetailPath(item.id)),
            onManage: () => ManageItemSheet.show(context, item),
          );
        },
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(AppConstants.screenPadding),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = items[index];
        return MySpaceItemCardList(
          item: item,
          onTap: () => context.push(AppRoutes.itemDetailPath(item.id)),
          onManage: () => ManageItemSheet.show(context, item),
        );
      },
    );
  }
}
