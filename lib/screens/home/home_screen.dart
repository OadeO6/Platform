import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_strings.dart';
import '../../core/extensions/context_extensions.dart';
import '../../providers/items_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/platform_app_bar.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/skeleton_loader.dart';
import '../../widgets/condition_chip.dart';
import '../../router/app_router.dart';
import '../../widgets/location_warning_banner.dart';
import 'widgets/feed_item_card.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  bool _isGridView = true;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    // Dismiss keyboard on scroll
    if (_scrollController.offset > 10) {
      FocusScope.of(context).unfocus();
    }
  }

  void _onSearch(String query) {
    ref.read(feedNotifierProvider.notifier).search(query);
    setState(() => _isSearching = query.isNotEmpty);
  }

  void _clearSearch() {
    _searchController.clear();
    ref.read(feedNotifierProvider.notifier).refresh();
    setState(() => _isSearching = false);
    FocusScope.of(context).unfocus();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final feedState = ref.watch(feedNotifierProvider);
    final isDark = context.isDark;

    return Scaffold(
      backgroundColor: context.backgroundColor,
      body: RefreshIndicator(
        onRefresh: () => ref.read(feedNotifierProvider.notifier).refresh(),
        color: context.primaryColor,
        child: CustomScrollView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // ── App bar ──────────────────────────────────────────────────
            SliverAppBar(
              pinned: true,
              floating: true,
              backgroundColor: context.backgroundColor,
              elevation: 0,
              scrolledUnderElevation: 0,
              title: Text(
                AppStrings.appName,
                style: AppTextStyles.wordmark(color: context.textPrimaryColor),
              ),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(1),
                child: Container(
                  height: 1,
                  color: context.dividerColor,
                ),
              ),
            ),

            // ── Search bar ───────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: _SearchBar(
                  controller: _searchController,
                  onChanged: _onSearch,
                  onClear: _clearSearch,
                  isSearching: _isSearching,
                ),
              ),
            ),

            // ── Category chips ───────────────────────────────────────────
            SliverToBoxAdapter(
              child: _CategoryChips(
                selected: feedState.selectedCategory,
                onSelect: (cat) => ref
                    .read(feedNotifierProvider.notifier)
                    .setCategory(cat == AppStrings.catAll ? null : cat),
              ),
            ),

            // ── Location warning ─────────────────────────────────────────
            SliverToBoxAdapter(
              child: LocationWarningBanner(
                featureLabel: 'nearby listings',
              ),
            ),

            // ── City strip + layout toggle ────────────────────────────────
            SliverToBoxAdapter(
              child: _FeedHeader(
                isGridView: _isGridView,
                onToggle: () => setState(() => _isGridView = !_isGridView),
                itemCount: feedState.items.length,
                isSearching: _isSearching,
                nearbyOnly: feedState.nearbyOnly,
                userCity: ref.read(feedNotifierProvider.notifier).userCity,
                onNearbyToggle: () =>
                    ref.read(feedNotifierProvider.notifier).toggleNearby(),
              ),
            ),

            // ── Content ───────────────────────────────────────────────────
            if (feedState.isLoading)
              SliverToBoxAdapter(
                child: _isGridView
                    ? SkeletonLoader.feedGrid()
                    : SkeletonLoader.feedList(),
              )
            else if (feedState.items.isEmpty)
              SliverFillRemaining(
                child: EmptyState(
                  icon: _isSearching
                      ? Icons.search_off_rounded
                      : Icons.storefront_outlined,
                  title: _isSearching
                      ? AppStrings.emptySearchTitle
                      : AppStrings.emptyFeedTitle,
                  subtitle: _isSearching
                      ? AppStrings.emptySearchSubtitle
                      : AppStrings.emptyFeedSubtitle,
                ),
              )
            else if (_isGridView)
              SliverPadding(
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
                      final item = feedState.items[index];
                      return FeedItemCardGrid(
                        item: item,
                        onTap: () => context
                            .push(AppRoutes.itemDetailPath(item.id)),
                      );
                    },
                    childCount: feedState.items.length,
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.all(AppConstants.screenPadding),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final item = feedState.items[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: FeedItemCardList(
                          item: item,
                          onTap: () => context
                              .push(AppRoutes.itemDetailPath(item.id)),
                        ),
                      );
                    },
                    childCount: feedState.items.length,
                  ),
                ),
              ),

            // ── Bottom padding ─────────────────────────────────────────────
            const SliverToBoxAdapter(child: SizedBox(height: 20)),
          ],
        ),
      ),
    );
  }
}

// ── Search bar ────────────────────────────────────────────────────────────────

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;
  final bool isSearching;

  const _SearchBar({
    required this.controller,
    required this.onChanged,
    required this.onClear,
    required this.isSearching,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;

    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: context.dividerColor),
      ),
      child: Row(
        children: [
          const SizedBox(width: 12),
          Icon(
            Icons.search_rounded,
            size: 20,
            color: context.textSecondaryColor,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              style: AppTextStyles.bodyMedium(color: context.textPrimaryColor),
              decoration: InputDecoration(
                hintText: AppStrings.searchHint,
                hintStyle: AppTextStyles.bodyMedium(
                    color: context.textSecondaryColor.withOpacity(0.6)),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          if (isSearching) ...[
            GestureDetector(
              onTap: onClear,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Icon(
                  Icons.close_rounded,
                  size: 18,
                  color: context.textSecondaryColor,
                ),
              ),
            ),
          ] else
            const SizedBox(width: 12),
        ],
      ),
    );
  }
}

// ── Category chips ────────────────────────────────────────────────────────────

class _CategoryChips extends StatelessWidget {
  final String? selected;
  final ValueChanged<String> onSelect;

  const _CategoryChips({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.screenPadding,
          vertical: 10,
        ),
        scrollDirection: Axis.horizontal,
        itemCount: AppStrings.categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final cat = AppStrings.categories[index];
          final isActive = (selected == null && cat == AppStrings.catAll) ||
              selected == cat;
          return FilterChipWidget(
            label: cat,
            isActive: isActive,
            onTap: () => onSelect(cat),
          );
        },
      ),
    );
  }
}

// ── Feed header (count + nearby filter + layout toggle) ──────────────────────

class _FeedHeader extends StatelessWidget {
  final bool isGridView;
  final VoidCallback onToggle;
  final int itemCount;
  final bool isSearching;
  final bool nearbyOnly;
  final String? userCity;
  final VoidCallback onNearbyToggle;

  const _FeedHeader({
    required this.isGridView,
    required this.onToggle,
    required this.itemCount,
    required this.isSearching,
    required this.nearbyOnly,
    required this.userCity,
    required this.onNearbyToggle,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final primaryColor = context.primaryColor;
    final secondaryColor = context.textSecondaryColor;
    final hasCity = userCity != null && userCity!.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 12, 0),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                // Nearby pill — only shown when user's city is known
                if (hasCity)
                  GestureDetector(
                    onTap: onNearbyToggle,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: nearbyOnly
                            ? primaryColor
                            : isDark
                                ? AppColors.darkSurface
                                : AppColors.surface,
                        borderRadius: BorderRadius.circular(100),
                        border: Border.all(
                          color:
                              nearbyOnly ? primaryColor : context.dividerColor,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.location_on_rounded,
                              size: 12,
                              color:
                                  nearbyOnly ? Colors.white : secondaryColor),
                          const SizedBox(width: 4),
                          Text(
                            userCity!,
                            style: AppTextStyles.labelSmall(
                              color:
                                  nearbyOnly ? Colors.white : secondaryColor,
                            ),
                          ),
                          if (nearbyOnly) ...[
                            const SizedBox(width: 4),
                            Icon(Icons.close_rounded,
                                size: 12, color: Colors.white),
                          ],
                        ],
                      ),
                    ),
                  ),

                if (hasCity) const SizedBox(width: 8),

                Text(
                  isSearching
                      ? '$itemCount ${itemCount == 1 ? 'result' : 'results'}'
                      : nearbyOnly
                          ? '$itemCount nearby'
                          : AppStrings.allListings,
                  style: AppTextStyles.labelMedium(color: secondaryColor),
                ),
              ],
            ),
          ),

          IconButton(
            onPressed: onToggle,
            icon: Icon(
              isGridView
                  ? Icons.view_list_rounded
                  : Icons.grid_view_rounded,
              color: secondaryColor,
              size: 22,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}
