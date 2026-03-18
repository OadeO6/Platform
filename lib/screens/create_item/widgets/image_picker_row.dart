import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_decorations.dart';
import '../../../core/extensions/context_extensions.dart';

/// Represents a single image slot — either a new local file or existing URL.
class ImageSlot {
  final File? file;        // new image picked from device
  final String? url;       // existing Cloudinary URL (edit mode)

  const ImageSlot({this.file, this.url});

  bool get isFile => file != null;
  bool get isUrl => url != null;
}

/// Image picker row for Create/Edit Item forms.
/// Supports picking new images, removing, and reordering (first = cover).
/// Shows existing URLs in edit mode alongside newly picked files.
class ImagePickerRow extends StatelessWidget {
  final List<ImageSlot> slots;
  final VoidCallback onAdd;
  final ValueChanged<int> onRemove;
  final void Function(int oldIndex, int newIndex) onReorder;

  const ImagePickerRow({
    super.key,
    required this.slots,
    required this.onAdd,
    required this.onRemove,
    required this.onReorder,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final canAdd = slots.length < AppConstants.maxImages;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Text(
          AppStrings.addPhotos,
          style: AppTextStyles.inputLabel(color: context.textSecondaryColor),
        ),
        const SizedBox(height: 8),

        // Horizontal scroll row
        SizedBox(
          height: 110,
          child: ReorderableListView.builder(
            scrollDirection: Axis.horizontal,
            buildDefaultDragHandles: false,
            onReorder: onReorder,
            itemCount: slots.length + (canAdd ? 1 : 0),
            itemBuilder: (context, index) {
              // Add button slot
              if (index == slots.length) {
                return _AddSlot(
                  key: const ValueKey('add'),
                  onTap: onAdd,
                  isDark: isDark,
                );
              }

              final slot = slots[index];
              final isCover = index == 0;

              return ReorderableDragStartListener(
                key: ValueKey(slot.isFile ? slot.file!.path : slot.url),
                index: index,
                child: _ImageSlotWidget(
                  slot: slot,
                  isCover: isCover,
                  onRemove: () => onRemove(index),
                  isDark: isDark,
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 6),

        // Hint
        Text(
          'First image is the cover. Drag to reorder.',
          style: AppTextStyles.labelSmall(color: context.textSecondaryColor),
        ),
      ],
    );
  }
}

class _ImageSlotWidget extends StatelessWidget {
  final ImageSlot slot;
  final bool isCover;
  final VoidCallback onRemove;
  final bool isDark;

  const _ImageSlotWidget({
    required this.slot,
    required this.isCover,
    required this.onRemove,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      margin: const EdgeInsets.only(right: 10),
      decoration: BoxDecoration(
        borderRadius: AppDecorations.defaultRadius,
        border: isCover
            ? Border.all(
                color: isDark ? AppColors.darkPrimary : AppColors.primary,
                width: 2,
              )
            : Border.all(color: isDark ? AppColors.darkDivider : AppColors.divider),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Image
            if (slot.isFile)
              Image.file(slot.file!, fit: BoxFit.cover)
            else
              CachedNetworkImage(
                imageUrl: slot.url!,
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(
                  color: isDark ? AppColors.darkDivider : AppColors.divider,
                ),
              ),

            // Cover badge
            if (isCover)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  color: (isDark ? AppColors.darkPrimary : AppColors.primary)
                      .withOpacity(0.85),
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: Text(
                    'Cover',
                    style: AppTextStyles.labelSmall(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),

            // Remove button
            Positioned(
              top: 5,
              right: 5,
              child: GestureDetector(
                onTap: onRemove,
                child: Container(
                  width: 22,
                  height: 22,
                  decoration: const BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close_rounded,
                    color: Colors.white,
                    size: 14,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddSlot extends StatelessWidget {
  final VoidCallback onTap;
  final bool isDark;

  const _AddSlot({
    super.key,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100,
        margin: const EdgeInsets.only(right: 10),
        decoration: BoxDecoration(
          borderRadius: AppDecorations.defaultRadius,
          border: Border.all(
            color: isDark ? AppColors.darkDivider : AppColors.divider,
            width: 1.5,
          ),
          color: isDark ? AppColors.darkSurface : AppColors.background,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_photo_alternate_outlined,
              size: 28,
              color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
            ),
            const SizedBox(height: 4),
            Text(
              'Add',
              style: AppTextStyles.labelSmall(
                color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
