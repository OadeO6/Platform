import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'core/theme/app_theme.dart';
import 'providers/theme_provider.dart';
import 'providers/fcm_token_provider.dart';
import 'providers/auth_provider.dart';
import 'router/app_router.dart';
import 'screens/notifications/notifications_screen.dart';
import 'services/notification_service.dart';

/// Root application widget.
class PlatformApp extends ConsumerStatefulWidget {
  const PlatformApp({super.key});

  @override
  ConsumerState<PlatformApp> createState() => _PlatformAppState();
}

class _PlatformAppState extends ConsumerState<PlatformApp> {
  @override
  void initState() {
    super.initState();
    if (!kIsWeb) _setupNotifications();
  }

  void _setupNotifications() {
    final notificationService = ref.read(notificationServiceProvider);

    // Add foreground FCM messages to in-app notification list
    notificationService.onForegroundMessage = (RemoteMessage message) {
      final notification = message.notification;
      if (notification == null) return;
      ref.read(notificationsNotifierProvider.notifier).add(
            AppNotification(
              id: const Uuid().v4(),
              title: notification.title ?? 'Platform',
              body: notification.body ?? '',
              type: message.data['type'] ?? 'general',
              itemId: message.data['item_id'] as String?,
              receivedAt: DateTime.now(),
            ),
          );
    };
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeNotifierProvider);
    final router = ref.watch(routerProvider);

    // Start FCM token manager — keeps token in sync with Firestore
    if (!kIsWeb) ref.watch(fcmTokenManagerProvider);

    return MaterialApp.router(
      title: 'Platform',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}
