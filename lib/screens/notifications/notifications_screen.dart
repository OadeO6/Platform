import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_strings.dart';
import '../../core/extensions/context_extensions.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_decorations.dart';
import '../../core/utils/date_utils.dart' as du;
import '../../router/app_router.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/platform_app_bar.dart';

// ── Model ─────────────────────────────────────────────────────────────────────

class AppNotification {
  final String id;
  final String title;
  final String body;
  final String type;
  final String? itemId;
  final DateTime receivedAt;
  bool isRead;

  AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    this.itemId,
    required this.receivedAt,
    this.isRead = false,
  });
}

// ── Provider ──────────────────────────────────────────────────────────────────

class NotificationsNotifier extends StateNotifier<List<AppNotification>> {
  NotificationsNotifier() : super([]);

  void add(AppNotification notification) {
    state = [notification, ...state];
  }

  void markRead(String id) {
    state = state.map((n) {
      if (n.id == id) n.isRead = true;
      return n;
    }).toList();
  }

  void markAllRead() {
    state = state.map((n) {
      n.isRead = true;
      return n;
    }).toList();
  }

  void remove(String id) {
    state = state.where((n) => n.id != id).toList();
  }

  void clear() => state = [];

  int get unreadCount => state.where((n) => !n.isRead).length;
}

final notificationsNotifierProvider =
    StateNotifierProvider<NotificationsNotifier, List<AppNotification>>(
  (_) => NotificationsNotifier(),
);

final unreadNotificationCountProvider = Provider<int>((ref) {
  return ref.watch(notificationsNotifierProvider
      .select((list) => list.where((n) => !n.isRead).length));
});

// ── Screen ────────────────────────────────────────────────────────────────────

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifications = ref.watch(notificationsNotifierProvider);
    final notifier = ref.read(notificationsNotifierProvider.notifier);
    final hasUnread = notifications.any((n) => !n.isRead);

    return Scaffold(
      backgroundColor: context.backgroundColor,
      appBar: PlatformAppBar(
        title: AppStrings.notifications,
        actions: [
          if (hasUnread)
            TextButton(
              onPressed: notifier.markAllRead,
              child: Text(
                'Mark all read',
                style: AppTextStyles.labelMedium(
                    color: context.primaryColor),
              ),
            ),
          if (notifications.isNotEmpty)
            IconButton(
              icon: Icon(Icons.delete_sweep_outlined,
                  color: context.textSecondaryColor, size: 22),
              onPressed: () => _confirmClear(context, notifier),
            ),
        ],
      ),
      body: notifications.isEmpty
          ? const EmptyState(
              icon: Icons.notifications_none_rounded,
              title: 'No notifications yet.',
              subtitle: "We'll let you know when your listings are about to expire.",
            )
          : ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: notifications.length,
              separatorBuilder: (_, __) =>
                  Divider(color: context.dividerColor, height: 1),
              itemBuilder: (context, index) {
                final n = notifications[index];
                return _NotificationTile(
                  notification: n,
                  onTap: () {
                    notifier.markRead(n.id);
                    if (n.itemId != null) {
                      context.push(AppRoutes.itemDetailPath(n.itemId!));
                    }
                  },
                  onDismiss: () => notifier.remove(n.id),
                );
              },
            ),
    );
  }

  Future<void> _confirmClear(
      BuildContext context, NotificationsNotifier notifier) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear all notifications?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
    if (confirm == true) notifier.clear();
  }
}

// ── Tile ──────────────────────────────────────────────────────────────────────

class _NotificationTile extends StatelessWidget {
  final AppNotification notification;
  final VoidCallback onTap;
  final VoidCallback onDismiss;

  const _NotificationTile({
    required this.notification,
    required this.onTap,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final isExpiry = notification.type == 'listing_expiry';
    final unreadBg = isDark
        ? AppColors.darkPrimaryTint
        : AppColors.primaryTint.withOpacity(0.4);

    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDismiss(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: AppColors.destructive.withOpacity(0.1),
        child: Icon(Icons.delete_outline_rounded,
            color: context.destructiveColor),
      ),
      child: InkWell(
        onTap: onTap,
        child: Container(
          color: notification.isRead ? null : unreadBg,
          padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.darkPrimaryTint
                      : AppColors.primaryTint,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isExpiry
                      ? Icons.access_time_rounded
                      : Icons.notifications_outlined,
                  size: 20,
                  color: context.primaryColor,
                ),
              ),
              const SizedBox(width: 12),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: AppTextStyles.labelMedium(
                              color: context.textPrimaryColor,
                            ),
                          ),
                        ),
                        if (!notification.isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: context.primaryColor,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      notification.body,
                      style: AppTextStyles.bodySmall(
                          color: context.textSecondaryColor),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      du.DateUtils.timeAgo(notification.receivedAt),
                      style: AppTextStyles.labelSmall(
                          color: context.textSecondaryColor),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
