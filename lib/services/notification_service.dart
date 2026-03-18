import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants/app_constants.dart';

// ── Background handler (top-level, required by FCM) ──────────────────────────

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Firebase is already initialised by the time this runs.
  // We don't need to show a notification here — FCM shows it automatically
  // when the app is in the background and the message has a `notification` payload.
}

// ── Notification channels ─────────────────────────────────────────────────────

const _expiryChannelId = 'platform_expiry';
const _expiryChannelName = 'Listing Expiry';
const _expiryChannelDesc = 'Alerts when your listings are about to expire';

const _generalChannelId = 'platform_general';
const _generalChannelName = 'General';
const _generalChannelDesc = 'General Platform notifications';

// ── Service ───────────────────────────────────────────────────────────────────

class NotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _local =
      FlutterLocalNotificationsPlugin();

  // Called once at app startup from main.dart
  Future<void> init() async {
    await _requestPermission();
    await _initLocalNotifications();
    _registerFcmHandlers();
  }

  // ── Permission ────────────────────────────────────────────────────────────

  Future<void> _requestPermission() async {
    await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  // ── Local notifications setup ─────────────────────────────────────────────

  Future<void> _initLocalNotifications() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false, // Already requested via FCM
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    await _local.initialize(
      const InitializationSettings(
          android: androidSettings, iOS: iosSettings),
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    // Create Android notification channels
    await _createChannel(
      id: _expiryChannelId,
      name: _expiryChannelName,
      description: _expiryChannelDesc,
      importance: Importance.high,
    );
    await _createChannel(
      id: _generalChannelId,
      name: _generalChannelName,
      description: _generalChannelDesc,
      importance: Importance.defaultImportance,
    );
  }

  Future<void> _createChannel({
    required String id,
    required String name,
    required String description,
    required Importance importance,
  }) async {
    final channel = AndroidNotificationChannel(
      id,
      name,
      description: description,
      importance: importance,
    );
    await _local
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  // Callback invoked for every foreground message — used to add to in-app list
  void Function(RemoteMessage message)? onForegroundMessage;

  // ── FCM handlers ──────────────────────────────────────────────────────────

  void _registerFcmHandlers() {
    // Foreground messages — FCM doesn't auto-show these, we show them locally
    FirebaseMessaging.onMessage.listen((message) {
      _showLocalNotification(message);
      onForegroundMessage?.call(message);
    });

    // App opened from a notification (background → foreground)
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      _handleNotificationTap(message.data);
    });
  }

  // ── Show local notification ───────────────────────────────────────────────

  Future<void> _showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    final isExpiry =
        message.data['type'] == AppConstants.notifTypeExpiry;

    final channelId =
        isExpiry ? _expiryChannelId : _generalChannelId;

    final androidDetails = AndroidNotificationDetails(
      channelId,
      isExpiry ? _expiryChannelName : _generalChannelName,
      importance: isExpiry ? Importance.high : Importance.defaultImportance,
      priority: isExpiry ? Priority.high : Priority.defaultPriority,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails();

    await _local.show(
      message.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(android: androidDetails, iOS: iosDetails),
      payload: jsonEncode(message.data),
    );
  }

  // ── Tap handlers ──────────────────────────────────────────────────────────

  void _onNotificationTap(NotificationResponse response) {
    if (response.payload == null) return;
    try {
      final data =
          jsonDecode(response.payload!) as Map<String, dynamic>;
      _handleNotificationTap(data);
    } catch (_) {}
  }

  void _handleNotificationTap(Map<String, dynamic> data) {
    // Navigation is handled by the app's router via a global key or
    // deep link. For now we store the pending route and handle on next frame.
    // TODO: wire up with GoRouter once shell is fully stable.
    final type = data['type'] as String?;
    final itemId = data['item_id'] as String?;

    if (type == AppConstants.notifTypeExpiry && itemId != null) {
      pendingNotificationRoute = '/item/$itemId';
    }
  }

  // ── FCM token ─────────────────────────────────────────────────────────────

  /// Gets the current FCM token for this device.
  Future<String?> getToken() async {
    return _fcm.getToken();
  }

  /// Listens for token refreshes and calls [onRefresh] with the new token.
  void onTokenRefresh(void Function(String token) onRefresh) {
    _fcm.onTokenRefresh.listen(onRefresh);
  }

  /// Deletes the FCM token (called on sign-out).
  Future<void> deleteToken() async {
    await _fcm.deleteToken();
  }

  // ── Check for notification that launched app from terminated state ─────────

  Future<Map<String, dynamic>?> getInitialMessage() async {
    final message = await _fcm.getInitialMessage();
    return message?.data;
  }
}

/// Stores a pending deep-link route from a notification tap.
/// Read and cleared by the router on next navigation.
String? pendingNotificationRoute;

// ── Provider ──────────────────────────────────────────────────────────────────

final notificationServiceProvider =
    Provider<NotificationService>((ref) => NotificationService());
