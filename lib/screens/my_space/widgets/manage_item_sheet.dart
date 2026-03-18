import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../models/item_model.dart';
import '../../../providers/items_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/user_provider.dart';
import '../../../router/app_router.dart';
import '../../../widgets/platform_bottom_sheet.dart';

class ManageItemSheet extends ConsumerWidget {
  final ItemModel item;

  const ManageItemSheet({super.key, required this.item});

  static Future<void> show(BuildContext context, ItemModel item) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => ManageItemSheet(item: item),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = context.isDark;
    final bgColor = isDark ? AppColors.darkSurface : AppColors.surface;
    final dividerColor = context.dividerColor;
    final userId = ref.watch(currentUserIdProvider) ?? '';
    final user = ref.watch(currentUserValueProvider);
    final listedItems = ref.watch(listedItemsProvider);
    final actionState = ref.watch(itemActionNotifierProvider);

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      padding: EdgeInsets.fromLTRB(
          20, 0, 20, 20 + MediaQuery.of(context).padding.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 4),
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

          // Title
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 4),
            child: Text(
              item.title,
              style: AppTextStyles.headlineSmall(color: context.textPrimaryColor),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          Divider(color: dividerColor, height: 20),

          // ── Actions based on status ───────────────────────────────────

          // LISTED item actions
          if (item.isActive) ...[
            BottomSheetAction(
              icon: Icons.edit_outlined,
              label: 'Edit Item',
              onTap: () {
                Navigator.pop(context);
                context.push(AppRoutes.editItemPath(item.id));
              },
            ),
            BottomSheetAction(
              icon: Icons.visibility_off_outlined,
              label: AppStrings.unlistItem,
              onTap: () async {
                Navigator.pop(context);
                await ref
                    .read(itemActionNotifierProvider.notifier)
                    .unlistItem(item, userId: userId);
              },
            ),
            BottomSheetAction(
              icon: Icons.check_circle_outline_rounded,
              label: AppStrings.markAsSold,
              onTap: () async {
                Navigator.pop(context);
                final confirm = await _confirmDialog(
                  context,
                  title: 'Mark as Sold?',
                  body: AppStrings.markSoldConfirm,
                  confirmLabel: 'Mark as Sold',
                );
                if (confirm == true) {
                  await ref
                      .read(itemActionNotifierProvider.notifier)
                      .markAsSold(item.id, userId);
                }
              },
            ),
          ],

          // UNLISTED item actions
          if (item.isUnlisted) ...[
            BottomSheetAction(
              icon: Icons.rocket_launch_outlined,
              label: AppStrings.listItem,
              onTap: () async {
                Navigator.pop(context);
                
                final profileWhatsApp = user?.whatsappContact;
                
                await ref
                    .read(itemActionNotifierProvider.notifier)
                    .listItem(
                      item,
                      currentListingCount: listedItems.length,
                      userId: userId,
                      contactInfo: profileWhatsApp,
                    );
                if (context.mounted) {
                  final state = ref.read(itemActionNotifierProvider);
                  if (state.errorMessage != null) {
                    context.showSnackBar(state.errorMessage!, isError: true);
                  }
                }
              },
            ),
            BottomSheetAction(
              icon: Icons.edit_outlined,
              label: 'Edit Item',
              onTap: () {
                Navigator.pop(context);
                context.push(AppRoutes.editItemPath(item.id));
              },
            ),
          ],

          // SOLD item actions
          if (item.isSold) ...[
            BottomSheetAction(
              icon: Icons.copy_outlined,
              label: AppStrings.relistAsTemplate,
              onTap: () {
                Navigator.pop(context);
                context.push(
                  AppRoutes.createItem,
                  extra: item, // Pass as template
                );
              },
            ),
          ],

          // Delete — always shown (except sold items get it too)
          BottomSheetAction.destructive(
            icon: Icons.delete_outline_rounded,
            label: AppStrings.deleteItem,
            onTap: () async {
              Navigator.pop(context);
              final confirm = await _confirmDialog(
                context,
                title: 'Delete Item?',
                body: AppStrings.deleteItemConfirm,
                confirmLabel: AppStrings.delete,
                isDestructive: true,
              );
              if (confirm == true) {
                await ref
                    .read(itemActionNotifierProvider.notifier)
                    .deleteItem(item, sellerId: userId);
              }
            },
          ),
        ],
      ),
    );
  }

  Future<bool?> _confirmDialog(
    BuildContext context, {
    required String title,
    required String body,
    required String confirmLabel,
    bool isDestructive = false,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(body),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(
              foregroundColor: isDestructive ? AppColors.destructive : null,
            ),
            child: Text(confirmLabel),
          ),
        ],
      ),
    );
  }
}
