import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/notification_service.dart';
import '../services/firestore_service.dart';
import 'auth_provider.dart';
import 'user_provider.dart';

/// Watches auth state and keeps the FCM token in Firestore in sync.
/// No-op on web — FCM is mobile only.
class FcmTokenManager {
  final Ref _ref;
  FcmTokenManager(this._ref) {
    if (!kIsWeb) _init();
  }

  void _init() {
    final notificationService = _ref.read(notificationServiceProvider);

    // Save token when user signs in
    _ref.listen(currentUserIdProvider, (previous, userId) async {
      if (userId == null) return;
      final token = await notificationService.getToken();
      if (token != null) {
        await _ref
            .read(firestoreServiceProvider)
            .updateFcmToken(userId, token);
      }
    });

    // Refresh token when FCM rotates it
    notificationService.onTokenRefresh((token) async {
      final userId = _ref.read(currentUserIdProvider);
      if (userId == null) return;
      await _ref
          .read(firestoreServiceProvider)
          .updateFcmToken(userId, token);
    });
  }
}

final fcmTokenManagerProvider = Provider<FcmTokenManager>((ref) {
  return FcmTokenManager(ref);
});
