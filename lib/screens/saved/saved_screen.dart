import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_strings.dart';
import '../../core/extensions/context_extensions.dart';
import '../../core/theme/app_text_styles.dart';
import '../../providers/saved_provider.dart';
import '../../providers/auth_provider.dart';
import '../../router/app_router.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/platform_app_bar.dart';
import '../../widgets/skeleton_loader.dart';
import '../home/widgets/feed_item_card.dart';

class SavedScreen extends ConsumerStatefulWidget {
  const SavedScreen({super.key});

  @override
  ConsumerState<SavedScreen> createState() => _SavedScreenState();
}

class _SavedScreenState extends ConsumerState<SavedScreen> {
  bool _isGridView = true;

  @override
  Widget build(BuildContext context) {
    final savedItemsAsync = ref.watch(savedItemsProvider);
    final savedIds = ref.watch(savedItemIdsProvider).value ?? [];

    return Scaffold(
      backgroundColor: context.backgroundColor,
      appBar: PlatformAppBar(
        title: AppStrings.saved,
        leading: const SizedBox.shrink(),
        actions: [
          if (savedIds.isNotEmpty)
            IconButton(
              icon: Icon(
                _isGridView ? Icons.view_list_rounded : Icons.grid_view_rounded,
                color: context.textSecondaryColor,
                size: 22,
              ),
              onPressed: () => setState(() => _isGridView = !_isGridView),
            ),
        ],
      ),
      body: savedItemsAsync.when(
        loading: () => _isGridView
            ? SkeletonLoader.feedGrid()
            : SkeletonLoader.feedList(),
        error: (_, __) => Center(
          child: Text(AppStrings.genericError,
              style: AppTextStyles.bodyMedium(
                  color: context.textSecondaryColor)),
        ),
        data: (items) {
          if (items.isEmpty) {
            return const EmptyState(
              icon: Icons.bookmark_outline_rounded,
              title: 'Nothing saved yet.',
              subtitle: 'Tap the bookmark on any listing to save it.',
            );
          }

          if (_isGridView) {
            return RefreshIndicator(
              onRefresh: () => ref.refresh(savedItemsProvider.future),
              color: context.primaryColor,
              child: GridView.builder(
                padding:
                    const EdgeInsets.all(AppConstants.screenPadding),
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.70,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  return FeedItemCardGrid(
                    item: item,
                    onTap: () =>
                        context.push(AppRoutes.itemDetailPath(item.id)),
                  );
                },
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => ref.refresh(savedItemsProvider.future),
            color: context.primaryColor,
            child: ListView.separated(
              padding: const EdgeInsets.all(AppConstants.screenPadding),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = items[index];
                return FeedItemCardList(
                  item: item,
                  onTap: () =>
                      context.push(AppRoutes.itemDetailPath(item.id)),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
