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
import '../../providers/auth_provider.dart';
import '../../providers/items_provider.dart';
import '../../providers/user_provider.dart';
import '../../services/location_service.dart';
import '../../widgets/platform_app_bar.dart';
import '../../widgets/platform_button.dart';
import '../../router/app_router.dart';
import 'widgets/image_picker_row.dart';
import 'widgets/item_form_fields.dart';

class CreateItemScreen extends ConsumerStatefulWidget {
  /// Optional template item — used when relisting a sold item.
  final ItemModel? template;

  const CreateItemScreen({super.key, this.template});

  @override
  ConsumerState<CreateItemScreen> createState() => _CreateItemScreenState();
}

class _CreateItemScreenState extends ConsumerState<CreateItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _priceController = TextEditingController();
  final _descController = TextEditingController();
  final _imagePicker = ImagePicker();

  List<ImageSlot> _imageSlots = [];
  File? _receiptFile;
  String? _selectedCategory;
  String? _selectedCondition;
  bool _negotiable = false;
  bool _isLoadingLocation = false;

  // Location
  String? _city;
  String? _area;
  double? _latitude;
  double? _longitude;

  bool get _hasUnsavedChanges =>
      _titleController.text.isNotEmpty ||
      _imageSlots.isNotEmpty ||
      _priceController.text.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _prefillTemplate();
    _detectLocation();
  }

  void _prefillTemplate() {
    final t = widget.template;
    if (t == null) return;
    // Don't prefill title — it must be entered fresh
    _priceController.text = t.price.toStringAsFixed(0);
    _negotiable = t.priceNegotiable;
    _selectedCategory = t.category;
    _selectedCondition = t.condition;
    _descController.text = t.description ?? '';
    // Don't prefill images from sold item — they should be fresh photos
  }

  Future<void> _detectLocation() async {
    setState(() => _isLoadingLocation = true);
    try {
      final result =
          await ref.read(locationServiceProvider).getCurrentLocation();
      if (!mounted) return;
      if (result.hasLocation) {
        setState(() {
          _city = result.city;
          _area = result.area;
          _latitude = result.latitude;
          _longitude = result.longitude;
        });
      }
    } catch (_) {
      // Non-fatal — item can be created without location
    } finally {
      setState(() => _isLoadingLocation = false);
    }
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
    setState(() => _receiptFile = File(picked.path));
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
    if (!_hasUnsavedChanges) return true;
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
    if (_selectedCategory == null) {
      context.showSnackBar('Please select a category.', isError: true);
      return;
    }
    if (_selectedCondition == null) {
      context.showSnackBar('Please select a condition.', isError: true);
      return;
    }

    FocusScope.of(context).unfocus();

    final user = ref.read(currentUserValueProvider);
    final userId = ref.read(currentUserIdProvider);

    if (userId == null || user == null) return;

    // WhatsApp number is removed from here — it's only required to LIST.
    // The provider now handles optional whatsappContact.

    // Check space cap
    final mySpaceItems = ref.read(mySpaceProvider).value ?? [];
    final spaceCount = mySpaceItems
        .where((i) => !i.isSold)
        .length;
    if (spaceCount >= AppConstants.spaceCap) {
      context.showSnackBar(AppStrings.spaceLimitReached, isError: true);
      return;
    }

    final images = _imageSlots
        .where((s) => s.isFile)
        .map((s) => s.file!)
        .toList();

    final price =
        double.tryParse(_priceController.text.replaceAll(',', '')) ?? 0;

    final itemId = await ref
        .read(itemActionNotifierProvider.notifier)
        .createItem(
          title: _titleController.text.trim(),
          price: price,
          priceNegotiable: _negotiable,
          category: _selectedCategory!,
          condition: _selectedCondition!,
          description: _descController.text.trim().isEmpty
              ? null
              : _descController.text.trim(),
          images: images,
          receiptImage: _receiptFile,
          sellerId: userId,
          sellerName: user.displayName,
          whatsappContact: user.whatsappContact ?? '',
          city: _city,
          area: _area,
          latitude: _latitude,
          longitude: _longitude,
        );

    if (!mounted) return;

    final state = ref.read(itemActionNotifierProvider);
    if (state.errorMessage != null) {
      context.showSnackBar(state.errorMessage!, isError: true);
    } else if (itemId != null) {
      context.showSnackBar('Item saved to your space.');
      context.pop();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _priceController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final actionState = ref.watch(itemActionNotifierProvider);
    final isLoading = actionState.isLoading;

    return PopScope(
      canPop: !_hasUnsavedChanges,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final shouldPop = await _onWillPop();
        if (shouldPop && mounted) context.pop();
      },
      child: Scaffold(
        backgroundColor: context.backgroundColor,
        appBar: PlatformAppBar(
          title: AppStrings.createItemTitle,
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

                // ── Title ────────────────────────────────────────────────
                TextFormField(
                  controller: _titleController,
                  maxLength: AppConstants.titleMaxLength,
                  textCapitalization: TextCapitalization.sentences,
                  style: AppTextStyles.inputText(
                      color: context.textPrimaryColor),
                  decoration: const InputDecoration(
                    labelText: AppStrings.titleField,
                    counterText: '',
                  ),
                  validator: Validators.title,
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
                _ReceiptPicker(
                  file: _receiptFile,
                  onPick: _pickReceipt,
                  onRemove: () => setState(() => _receiptFile = null),
                ),

                const SizedBox(height: 16),

                // ── Location ──────────────────────────────────────────────
                _FieldLabel('Location'),
                const SizedBox(height: 6),
                LocationDisplay(
                  city: _city,
                  area: _area,
                  isLoading: _isLoadingLocation,
                  onRetry: _detectLocation,
                ),

                const SizedBox(height: 32),

                // ── Submit ────────────────────────────────────────────────
                PlatformButton(
                  label: AppStrings.saveItem,
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
    return Text(
      label,
      style: AppTextStyles.inputLabel(color: context.textSecondaryColor),
    );
  }
}

class _ReceiptPicker extends StatelessWidget {
  final File? file;
  final VoidCallback onPick;
  final VoidCallback onRemove;

  const _ReceiptPicker({
    required this.file,
    required this.onPick,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppStrings.receiptImage,
            style:
                AppTextStyles.inputLabel(color: context.textSecondaryColor)),
        const SizedBox(height: 8),
        if (file != null)
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(file!,
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
                  color: isDark ? AppColors.darkDivider : AppColors.divider,
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
