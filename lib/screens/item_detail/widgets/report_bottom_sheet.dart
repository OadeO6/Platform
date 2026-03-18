import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_decorations.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../providers/items_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../widgets/platform_button.dart';

class ReportBottomSheet extends ConsumerStatefulWidget {
  final String itemId;

  const ReportBottomSheet({super.key, required this.itemId});

  static Future<void> show(BuildContext context, String itemId) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ReportBottomSheet(itemId: itemId),
    );
  }

  @override
  ConsumerState<ReportBottomSheet> createState() => _ReportBottomSheetState();
}

class _ReportBottomSheetState extends ConsumerState<ReportBottomSheet> {
  String? _selectedReason;
  final _detailsController = TextEditingController();
  bool _submitted = false;

  @override
  void dispose() {
    _detailsController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_selectedReason == null) return;
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) return;

    final success = await ref.read(itemActionNotifierProvider.notifier).reportItem(
          itemId: widget.itemId,
          reporterId: userId,
          reason: _selectedReason!,
          details: _detailsController.text.trim().isEmpty
              ? null
              : _detailsController.text.trim(),
        );

    if (success && mounted) {
      setState(() => _submitted = true);
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final bgColor = isDark ? AppColors.darkSurface : AppColors.surface;
    final dividerColor = context.dividerColor;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final actionState = ref.watch(itemActionNotifierProvider);

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      padding: EdgeInsets.fromLTRB(20, 0, 20, 20 + bottomInset),
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

          const SizedBox(height: 12),

          Text(AppStrings.reportTitle,
              style: AppTextStyles.headlineSmall(
                  color: context.textPrimaryColor)),
          const SizedBox(height: 2),
          Text(AppStrings.reportSubtitle,
              style: AppTextStyles.bodySmall(
                  color: context.textSecondaryColor)),

          const SizedBox(height: 20),

          // Reasons
          ...AppStrings.reportReasons.map((reason) => _ReasonTile(
                reason: reason,
                isSelected: _selectedReason == reason,
                onTap: () => setState(() => _selectedReason = reason),
              )),

          const SizedBox(height: 16),

          // Details
          TextField(
            controller: _detailsController,
            maxLines: 3,
            style: AppTextStyles.bodyMedium(color: context.textPrimaryColor),
            decoration: InputDecoration(
              hintText: AppStrings.reportDetails,
              hintStyle: AppTextStyles.bodyMedium(
                  color: context.textSecondaryColor.withOpacity(0.6)),
            ),
          ),

          const SizedBox(height: 20),

          // Submit
          _submitted
              ? Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle_outline_rounded,
                          color: context.successColor, size: 20),
                      const SizedBox(width: 8),
                      Text(AppStrings.reported,
                          style: AppTextStyles.labelLarge(
                              color: context.successColor)),
                    ],
                  ),
                )
              : PlatformButton(
                  label: AppStrings.submitReport,
                  onPressed:
                      _selectedReason == null || actionState.isLoading
                          ? null
                          : _submit,
                  loading: actionState.isLoading,
                ),
        ],
      ),
    );
  }
}

class _ReasonTile extends StatelessWidget {
  final String reason;
  final bool isSelected;
  final VoidCallback onTap;

  const _ReasonTile({
    required this.reason,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = context.primaryColor;
    final textColor = context.textPrimaryColor;

    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? primaryColor : context.dividerColor,
                  width: 2,
                ),
                color: isSelected ? primaryColor : Colors.transparent,
              ),
              child: isSelected
                  ? const Icon(Icons.check_rounded,
                      color: Colors.white, size: 12)
                  : null,
            ),
            const SizedBox(width: 12),
            Text(reason,
                style: AppTextStyles.bodyLarge(color: textColor)),
          ],
        ),
      ),
    );
  }
}
