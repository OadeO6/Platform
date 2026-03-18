import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_strings.dart';
import '../../core/extensions/context_extensions.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/validators.dart';
import '../../models/item_model.dart';
import '../../providers/items_provider.dart';
import '../../widgets/platform_app_bar.dart';
import '../../widgets/platform_button.dart';
import '../../widgets/skeleton_loader.dart';
import 'widgets/image_picker_row.dart';
import 'widgets/item_form_fields.dart';

class EditItemScreen extends ConsumerWidget {
  final String itemId;
  const EditItemScreen({super.key, required this.itemId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemAsync = ref.watch(itemDetailProvider(itemId));
    return itemAsync.when(
      loading: () => Scaffold(
        backgroundColor: context.backgroundColor,
        appBar: PlatformAppBar(title: AppStrings.editItemTitle),
        body: SkeletonLoader.itemDetail(),
      ),
      error: (_, __) => Scaffold(
        backgroundColor: context.backgroundColor,
        appBar: PlatformAppBar(title: AppStrings.editItemTitle),
        body: Center(
          child: Text(AppStrings.genericError,
              style: AppTextStyles.bodyMedium(
                  color: context.textSecondaryColor)),
        ),
      ),
      data: (item) {
        if (item == null) {
          return Scaffold(
            backgroundColor: context.backgroundColor,
            appBar: PlatformAppBar(title: AppStrings.editItemTitle),
            body: Center(
              child: Text('Item not found.',
                  style: AppTextStyles.bodyMedium(
                      color: context.textSecondaryColor)),
            ),
          );
        }
        return _EditItemForm(item: item);
      },
    );
  }
}

class _EditItemForm extends ConsumerStatefulWidget {
  final ItemModel item;
  const _EditItemForm({required this.item});

  @override
  ConsumerState<_EditItemForm> createState() => _EditItemFormState();
}

class _EditItemFormState extends ConsumerState<_EditItemForm> {
  final _formKey = GlobalKey<FormState>();
  final _priceController = TextEditingController();
  final _descController = TextEditingController();
  final _imagePicker = ImagePicker();

  late List<ImageSlot> _imageSlots;
  File? _receiptFile;
  String? _existingReceiptUrl;
  late String? _selectedCategory;
  late String? _selectedCondition;
  late bool _negotiable;

  bool get _hasUnsavedChanges => true; // Always warn on edit screen

  @override
  void initState() {
    super.initState();
    final item = widget.item;

    _priceController.text = item.price.toStringAsFixed(0);
    _descController.text = item.description ?? '';
    _selectedCategory = item.category;
    _selectedCondition = item.condition;
    _negotiable = item.priceNegotiable;
    _existingReceiptUrl = item.receiptImageUrl;

    // Pre-fill image slots with existing URLs
    _imageSlots = item.imageUrls
        .map((url) => ImageSlot(url: url))
        .toList();
  }

  Future<void> _pickImages() async {
    final remaining = AppConstants.maxImages - _imageSlots.length;
    if (remaining <= 0) return;

    final picked = await _imagePicker.pickMultiImage(
      imageQuality: 85,
      limit: remaining,
    );
    if (picked.isEmpty) return;

    setState(() {
      for (final xFile in picked) {
        if (_imageSlots.length < AppConstants.maxImages) {
          _imageSlots.add(ImageSlot(file: File(xFile.path)));
        }
      }
    });
  }

  Future<void> _pickReceipt() async {
    final picked = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (picked == null) return;
    setState(() {
      _receiptFile = File(picked.path);
      _existingReceiptUrl = null;
    });
  }

  void _removeImage(int index) {
    setState(() => _imageSlots.removeAt(index));
  }

  void _reorderImages(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) newIndex--;
      final slot = _imageSlots.removeAt(oldIndex);
      _imageSlots.insert(newIndex, slot);
    });
  }

  Future<bool> _onWillPop() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(AppStrings.discardChanges),
        content: const Text(AppStrings.discardChangesBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(AppStrings.keepEditing),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(AppStrings.discard),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_imageSlots.isEmpty) {
      context.showSnackBar(AppStrings.minImagesRequired, isError: true);
      return;
    }

    FocusScope.of(context).unfocus();

    final newImages = _imageSlots
        .where((s) => s.isFile)
        .map((s) => s.file!)
        .toList();
    final existingUrls = _imageSlots
        .where((s) => s.isUrl)
        .map((s) => s.url!)
        .toList();

    final price =
        double.tryParse(_priceController.text.replaceAll(',', '')) ?? 0;

    final success = await ref
        .read(itemActionNotifierProvider.notifier)
        .updateItem(
          widget.item.id,
          price: price,
          priceNegotiable: _negotiable,
          category: _selectedCategory,
          condition: _selectedCondition,
          description: _descController.text.trim().isEmpty
              ? null
              : _descController.text.trim(),
          newImages: newImages.isEmpty ? null : newImages,
          existingImageUrls: existingUrls,
          receiptImage: _receiptFile,
          existingReceiptUrl: _existingReceiptUrl,
        );

    if (!mounted) return;

    if (success) {
      context.showSnackBar('Item updated.');
      context.pop();
    } else {
      final state = ref.read(itemActionNotifierProvider);
      context.showSnackBar(
          state.errorMessage ?? AppStrings.genericError,
          isError: true);
    }
  }

  @override
  void dispose() {
    _priceController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final actionState = ref.watch(itemActionNotifierProvider);
    final isLoading = actionState.isLoading;
    final isDark = context.isDark;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final shouldPop = await _onWillPop();
        if (shouldPop && mounted) context.pop();
      },
      child: Scaffold(
        backgroundColor: context.backgroundColor,
        appBar: PlatformAppBar(
          title: AppStrings.editItemTitle,
          showDash: true,
        ),
        body: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Images ───────────────────────────────────────────────
                ImagePickerRow(
                  slots: _imageSlots,
                  onAdd: _pickImages,
                  onRemove: _removeImage,
                  onReorder: _reorderImages,
                ),

                const SizedBox(height: 24),

                // ── Title (LOCKED) ────────────────────────────────────────
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.darkSurface.withOpacity(0.5)
                        : AppColors.background,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: isDark
                            ? AppColors.darkDivider
                            : AppColors.divider),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppStrings.titleField,
                              style: AppTextStyles.inputLabel(
                                  color: context.textSecondaryColor),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.item.title,
                              style: AppTextStyles.bodyLarge(
                                  color: context.textSecondaryColor),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.lock_outline_rounded,
                          size: 16,
                          color: context.textSecondaryColor.withOpacity(0.5)),
                    ],
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  AppStrings.titleLocked,
                  style: AppTextStyles.labelSmall(
                      color: context.textSecondaryColor),
                ),

                const SizedBox(height: 16),

                // ── Price + Negotiable ────────────────────────────────────
                PriceField(
                  controller: _priceController,
                  negotiable: _negotiable,
                  onNegotiableChanged: (v) =>
                      setState(() => _negotiable = v),
                ),

                const SizedBox(height: 16),

                // ── Category ─────────────────────────────────────────────
                _FieldLabel(AppStrings.categoryField),
                const SizedBox(height: 6),
                CategorySelector(
                  selected: _selectedCategory,
                  onSelected: (v) =>
                      setState(() => _selectedCategory = v),
                ),

                const SizedBox(height: 16),

                // ── Condition ─────────────────────────────────────────────
                _FieldLabel(AppStrings.conditionField),
                const SizedBox(height: 6),
                ConditionSelector(
                  selected: _selectedCondition,
                  onSelected: (v) =>
                      setState(() => _selectedCondition = v),
                ),

                const SizedBox(height: 16),

                // ── Description ───────────────────────────────────────────
                TextFormField(
                  controller: _descController,
                  maxLength: AppConstants.descriptionMaxLength,
                  maxLines: 4,
                  textCapitalization: TextCapitalization.sentences,
                  style: AppTextStyles.inputText(
                      color: context.textPrimaryColor),
                  decoration: const InputDecoration(
                    labelText: AppStrings.descriptionField,
                    alignLabelWithHint: true,
                  ),
                  validator: Validators.description,
                ),

                const SizedBox(height: 16),

                // ── Receipt ───────────────────────────────────────────────
                _ReceiptSection(
                  newFile: _receiptFile,
                  existingUrl: _existingReceiptUrl,
                  onPick: _pickReceipt,
                  onRemove: () => setState(() {
                    _receiptFile = null;
                    _existingReceiptUrl = null;
                  }),
                ),

                const SizedBox(height: 16),

                // ── Location (display only — not editable) ────────────────
                _FieldLabel('Location'),
                const SizedBox(height: 6),
                LocationDisplay(
                  city: widget.item.city,
                  area: widget.item.area,
                ),

                const SizedBox(height: 32),

                // ── Save button ───────────────────────────────────────────
                PlatformButton(
                  label: AppStrings.saveChanges,
                  onPressed: isLoading ? null : _submit,
                  loading: isLoading,
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String label;
  const _FieldLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return Text(label,
        style: AppTextStyles.inputLabel(color: context.textSecondaryColor));
  }
}

class _ReceiptSection extends StatelessWidget {
  final File? newFile;
  final String? existingUrl;
  final VoidCallback onPick;
  final VoidCallback onRemove;

  const _ReceiptSection({
    required this.newFile,
    required this.existingUrl,
    required this.onPick,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final hasReceipt = newFile != null || existingUrl != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppStrings.receiptImage,
            style: AppTextStyles.inputLabel(
                color: context.textSecondaryColor)),
        const SizedBox(height: 8),
        if (hasReceipt)
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: newFile != null
                    ? Image.file(newFile!,
                        height: 100, width: 100, fit: BoxFit.cover)
                    : Image.network(existingUrl!,
                        height: 100, width: 100, fit: BoxFit.cover),
              ),
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
                    child: const Icon(Icons.close_rounded,
                        color: Colors.white, size: 14),
                  ),
                ),
              ),
            ],
          )
        else
          GestureDetector(
            onTap: onPick,
            child: Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color:
                      isDark ? AppColors.darkDivider : AppColors.divider,
                  width: 1.5,
                ),
                color:
                    isDark ? AppColors.darkSurface : AppColors.background,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.receipt_long_outlined,
                      size: 18, color: context.textSecondaryColor),
                  const SizedBox(width: 8),
                  Text(AppStrings.addReceipt,
                      style: AppTextStyles.labelMedium(
                          color: context.textSecondaryColor)),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
