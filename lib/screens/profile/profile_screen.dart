import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/constants/app_strings.dart';
import '../../core/extensions/context_extensions.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_decorations.dart';
import '../../core/utils/validators.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/items_provider.dart';
import '../../services/location_service.dart';
import '../../widgets/location_warning_banner.dart';
import '../../services/storage_service.dart';
import '../../widgets/platform_app_bar.dart';
import '../../widgets/platform_button.dart';
import '../../widgets/skeleton_loader.dart';
import '../../router/app_router.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);

    return userAsync.when(
      loading: () => Scaffold(
        backgroundColor: context.backgroundColor,
        appBar: PlatformAppBar(
            title: AppStrings.profile, leading: const SizedBox.shrink()),
        body: SkeletonLoader.box(width: double.infinity, height: 200),
      ),
      error: (_, __) => Scaffold(
        backgroundColor: context.backgroundColor,
        appBar: PlatformAppBar(
            title: AppStrings.profile, leading: const SizedBox.shrink()),
        body: Center(
          child: Text(AppStrings.genericError,
              style: AppTextStyles.bodyMedium(
                  color: context.textSecondaryColor)),
        ),
      ),
      data: (user) {
        if (user == null) return const SizedBox.shrink();
        return _ProfileContent(user: user);
      },
    );
  }
}

class _ProfileContent extends ConsumerStatefulWidget {
  final UserModel user;
  const _ProfileContent({required this.user});

  @override
  ConsumerState<_ProfileContent> createState() => _ProfileContentState();
}

class _ProfileContentState extends ConsumerState<_ProfileContent> {
  bool _editingName = false;
  bool _editingWhatsapp = false;
  late TextEditingController _nameController;
  late TextEditingController _whatsappController;
  bool _isSavingAvatar = false;

  @override
  void initState() {
    super.initState();
    _nameController =
        TextEditingController(text: widget.user.displayName);
    _whatsappController =
        TextEditingController(text: widget.user.whatsappContact ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _whatsappController.dispose();
    super.dispose();
  }

  Future<void> _pickAvatar() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (picked == null || !mounted) return;

    setState(() => _isSavingAvatar = true);
    try {
      final url = await ref
          .read(storageServiceProvider)
          .uploadAvatarImage(File(picked.path));
      await ref
          .read(userProfileNotifierProvider.notifier)
          .updatePhotoUrl(widget.user.id, url);
    } catch (e) {
      if (mounted) {
        context.showSnackBar('Failed to update photo.', isError: true);
      }
    } finally {
      if (mounted) setState(() => _isSavingAvatar = false);
    }
  }

  Future<void> _saveName() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;
    await ref
        .read(userProfileNotifierProvider.notifier)
        .updateDisplayName(widget.user.id, name);
    if (mounted) setState(() => _editingName = false);
  }

  Future<void> _saveWhatsapp() async {
    final number = _whatsappController.text.trim();
    final error = Validators.whatsappNumber(number);
    if (error != null) {
      context.showSnackBar(error, isError: true);
      return;
    }
    // Normalise to E.164 before saving (e.g. 08012345678 → +2348012345678)
    final normalised = Validators.normaliseWhatsApp(number) ?? number;
    await ref
        .read(userProfileNotifierProvider.notifier)
        .updateWhatsApp(widget.user.id, normalised);
    if (mounted) {
      _whatsappController.text = normalised;
      setState(() => _editingWhatsapp = false);
    }
  }

  Future<void> _signOut() async {
    final confirm = await _confirmDialog(
      context,
      title: AppStrings.signOut,
      body: 'Are you sure you want to sign out?',
      confirmLabel: AppStrings.signOut,
    );
    if (confirm != true) return;
    await ref.read(authNotifierProvider.notifier).signOut();
  }

  Future<void> _deleteAccount() async {
    final confirm = await _confirmDialog(
      context,
      title: AppStrings.deleteAccount,
      body: AppStrings.deleteAccountConfirm,
      confirmLabel: AppStrings.deleteAccount,
      isDestructive: true,
    );
    if (confirm != true || !mounted) return;

    final success = await ref
        .read(userProfileNotifierProvider.notifier)
        .deleteAccount(widget.user.id);

    if (!success && mounted) {
      final state = ref.read(userProfileNotifierProvider);
      context.showSnackBar(
          state.errorMessage ?? AppStrings.genericError,
          isError: true);
    }
  }

  Future<bool?> _confirmDialog(
    BuildContext context, {
    required String title,
    required String body,
    required String confirmLabel,
    bool isDestructive = false,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(body),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(
              foregroundColor:
                  isDestructive ? AppColors.destructive : null,
            ),
            child: Text(confirmLabel),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.user;
    final isDark = context.isDark;
    final themeMode = ref.watch(themeNotifierProvider);
    final profileState = ref.watch(userProfileNotifierProvider);
    final mySpaceItems = ref.watch(mySpaceProvider).value ?? [];
    final listedCount =
        mySpaceItems.where((i) => i.isActive && !i.isExpired).length;
    final soldCount = mySpaceItems.where((i) => i.isSold).length;

    return Scaffold(
      backgroundColor: context.backgroundColor,
      appBar: PlatformAppBar(
        title: AppStrings.profile,
        leading: const SizedBox.shrink(),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Avatar + name ───────────────────────────────────────────
            Center(
              child: Column(
                children: [
                  GestureDetector(
                    onTap: _pickAvatar,
                    child: Stack(
                      children: [
                        _Avatar(
                          photoUrl: user.photoUrl,
                          name: user.displayName,
                          size: 84,
                        ),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            width: 26,
                            height: 26,
                            decoration: BoxDecoration(
                              color: context.primaryColor,
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: context.backgroundColor, width: 2),
                            ),
                            child: _isSavingAvatar
                                ? const Padding(
                                    padding: EdgeInsets.all(5),
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white),
                                  )
                                : const Icon(Icons.camera_alt_rounded,
                                    color: Colors.white, size: 14),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Display name
                  if (!_editingName)
                    GestureDetector(
                      onTap: () => setState(() => _editingName = true),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            user.displayName,
                            style: AppTextStyles.headlineMedium(
                                color: context.textPrimaryColor),
                          ),
                          const SizedBox(width: 6),
                          Icon(Icons.edit_outlined,
                              size: 16,
                              color: context.textSecondaryColor),
                        ],
                      ),
                    )
                  else
                    _InlineEdit(
                      controller: _nameController,
                      hint: 'Display name',
                      onSave: _saveName,
                      onCancel: () =>
                          setState(() => _editingName = false),
                      isLoading: profileState.isLoading,
                    ),

                  const SizedBox(height: 4),

                  Text(
                    user.email,
                    style: AppTextStyles.bodySmall(
                        color: context.textSecondaryColor),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ── Stats row ────────────────────────────────────────────────
            _StatsRow(
              listedCount: listedCount,
              soldCount: soldCount,
              memberSince: user.memberSince,
            ),

            const SizedBox(height: 28),

            // ── WhatsApp warning ─────────────────────────────────────────
            if (user.whatsappContact == null ||
                user.whatsappContact!.trim().isEmpty) ...[
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: context.warningColor.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                      color: context.warningColor.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.chat_outlined,
                        size: 18, color: context.warningColor),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Add a WhatsApp number to start listing items.',
                        style: AppTextStyles.bodySmall(
                            color: context.textPrimaryColor),
                      ),
                    ),
                    GestureDetector(
                      onTap: () =>
                          setState(() => _editingWhatsapp = true),
                      child: Text('Add',
                          style: AppTextStyles.labelSmall(
                              color: context.primaryColor)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // ── Settings ─────────────────────────────────────────────────
            _SectionLabel('Account'),
            const SizedBox(height: 8),

            _SettingsCard(children: [
              // WhatsApp
              _SettingsTile(
                icon: Icons.chat_outlined,
                label: 'WhatsApp Number',
                value: user.whatsappContact?.isNotEmpty == true
                    ? user.whatsappContact!
                    : 'Not set',
                onTap: () => setState(() => _editingWhatsapp = true),
              ),
              if (_editingWhatsapp) ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  child: _InlineEdit(
                    controller: _whatsappController,
                    hint: '+234 800 000 0000',
                    onSave: _saveWhatsapp,
                    onCancel: () =>
                        setState(() => _editingWhatsapp = false),
                    isLoading: profileState.isLoading,
                    keyboardType: TextInputType.phone,
                  ),
                ),
              ],
              Divider(color: context.dividerColor, height: 1),

              // Location with refresh button
              _LocationTile(user: user),
            ]),

            const SizedBox(height: 20),

            _SectionLabel('Preferences'),
            const SizedBox(height: 8),

            _SettingsCard(children: [
              // Dark mode toggle
              _SettingsTile(
                icon: isDark
                    ? Icons.dark_mode_outlined
                    : Icons.light_mode_outlined,
                label: 'Dark Mode',
                onTap: null,
                trailing: Switch(
                  value: isDark,
                  onChanged: (_) =>
                      ref.read(themeNotifierProvider.notifier).toggle(),
                  activeColor: context.primaryColor,
                ),
              ),
            ]),

            const SizedBox(height: 20),

            _SectionLabel('More'),
            const SizedBox(height: 8),

            _SettingsCard(children: [
              _SettingsTile(
                icon: Icons.logout_rounded,
                label: AppStrings.signOut,
                onTap: _signOut,
              ),
              Divider(color: context.dividerColor, height: 1),
              _SettingsTile(
                icon: Icons.delete_forever_outlined,
                label: AppStrings.deleteAccount,
                onTap: _deleteAccount,
                destructive: true,
              ),
            ]),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

// ── Stats row ─────────────────────────────────────────────────────────────────

class _StatsRow extends StatelessWidget {
  final int listedCount;
  final int soldCount;
  final DateTime memberSince;

  const _StatsRow({
    required this.listedCount,
    required this.soldCount,
    required this.memberSince,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.surface;
    final borderColor = context.dividerColor;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: AppDecorations.defaultRadius,
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          _StatCell(label: 'Listed', value: '$listedCount'),
          _Divider(),
          _StatCell(label: 'Sold', value: '$soldCount'),
          _Divider(),
          _StatCell(
            label: 'Member Since',
            value:
                '${memberSince.year}',
          ),
        ],
      ),
    );
  }
}

class _StatCell extends StatelessWidget {
  final String label;
  final String value;
  const _StatCell({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(value,
              style: AppTextStyles.headlineMedium(
                  color: context.textPrimaryColor)),
          const SizedBox(height: 2),
          Text(label,
              style: AppTextStyles.bodySmall(
                  color: context.textSecondaryColor)),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 32, color: context.dividerColor);
  }
}

// ── Inline edit field ─────────────────────────────────────────────────────────

class _InlineEdit extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final VoidCallback onSave;
  final VoidCallback onCancel;
  final bool isLoading;
  final TextInputType? keyboardType;

  const _InlineEdit({
    required this.controller,
    required this.hint,
    required this.onSave,
    required this.onCancel,
    required this.isLoading,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            autofocus: true,
            keyboardType: keyboardType,
            style:
                AppTextStyles.bodyLarge(color: context.textPrimaryColor),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: AppTextStyles.bodyLarge(
                  color: context.textSecondaryColor.withOpacity(0.5)),
              isDense: true,
            ),
          ),
        ),
        const SizedBox(width: 8),
        if (isLoading)
          const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        else ...[
          GestureDetector(
            onTap: onSave,
            child: Icon(Icons.check_rounded,
                color: context.primaryColor, size: 22),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onCancel,
            child: Icon(Icons.close_rounded,
                color: context.textSecondaryColor, size: 22),
          ),
        ],
      ],
    );
  }
}

// ── Settings card + tile ──────────────────────────────────────────────────────

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;
  const _SettingsCard({required this.children});

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.surface,
        borderRadius: AppDecorations.defaultRadius,
        border: Border.all(color: context.dividerColor),
      ),
      child: Column(children: children),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? value;
  final VoidCallback? onTap;
  final Widget? trailing;
  final bool destructive;

  const _SettingsTile({
    required this.icon,
    required this.label,
    this.value,
    required this.onTap,
    this.trailing,
    this.destructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = destructive
        ? context.destructiveColor
        : context.textPrimaryColor;
    final secondaryColor = context.textSecondaryColor;

    return InkWell(
      onTap: onTap,
      borderRadius: AppDecorations.defaultRadius,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: AppTextStyles.bodyLarge(color: color)),
                  if (value != null)
                    Text(value!,
                        style: AppTextStyles.bodySmall(
                            color: secondaryColor)),
                ],
              ),
            ),
            if (trailing != null) trailing!,
            if (trailing == null && onTap != null)
              Icon(Icons.chevron_right_rounded,
                  color: secondaryColor, size: 20),
          ],
        ),
      ),
    );
  }
}

// ── Section label ─────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: AppTextStyles.labelMedium(color: context.textSecondaryColor),
    );
  }
}

// ── Avatar ────────────────────────────────────────────────────────────────────

class _Avatar extends StatelessWidget {
  final String? photoUrl;
  final String name;
  final double size;

  const _Avatar(
      {required this.photoUrl, required this.name, required this.size});

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final bgColor =
        isDark ? AppColors.darkPrimaryTint : AppColors.primaryTint;
    final textColor =
        isDark ? AppColors.darkPrimary : AppColors.primary;
    final initial =
        name.isNotEmpty ? name[0].toUpperCase() : '?';

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: bgColor),
      clipBehavior: Clip.antiAlias,
      child: photoUrl != null && photoUrl!.isNotEmpty
          ? CachedNetworkImage(
              imageUrl: photoUrl!,
              fit: BoxFit.cover,
              placeholder: (_, __) => Container(color: bgColor),
              errorWidget: (_, __, ___) => Center(
                child: Text(initial,
                    style: TextStyle(
                        color: textColor,
                        fontSize: size * 0.4,
                        fontWeight: FontWeight.w600)),
              ),
            )
          : Center(
              child: Text(initial,
                  style: TextStyle(
                      color: textColor,
                      fontSize: size * 0.4,
                      fontWeight: FontWeight.w600)),
            ),
    );
  }
}

// ── Location tile with refresh ────────────────────────────────────────────────

class _LocationTile extends ConsumerWidget {
  final UserModel user;
  const _LocationTile({required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final refreshState = ref.watch(locationRefreshProvider);
    final hasLocation = user.hasLocation;
    final secondaryColor = context.textSecondaryColor;
    final primaryColor = context.primaryColor;
    final warningColor = context.warningColor;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Icon(
            hasLocation
                ? Icons.location_on_outlined
                : Icons.location_off_outlined,
            size: 20,
            color: hasLocation ? context.textPrimaryColor : warningColor,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Location',
                    style: AppTextStyles.bodyLarge(
                        color: context.textPrimaryColor)),
                Text(
                  hasLocation
                      ? user.area != null && user.area!.isNotEmpty
                          ? '${user.area}, ${user.city}'
                          : user.city!
                      : 'Not set — tap Detect to enable nearby features',
                  style: AppTextStyles.bodySmall(
                    color: hasLocation ? secondaryColor : warningColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (refreshState.isLoading)
            SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: primaryColor),
            )
          else
            GestureDetector(
              onTap: () =>
                  ref.read(locationRefreshProvider.notifier).refresh(ref),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  hasLocation ? 'Refresh' : 'Detect',
                  style: AppTextStyles.labelSmall(color: primaryColor),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
