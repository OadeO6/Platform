import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../services/firestore_service.dart';
import '../services/auth_service.dart';
import 'auth_provider.dart';

// ── Service provider ──────────────────────────────────────────────────────────

final firestoreServiceProvider =
    Provider<FirestoreService>((ref) => FirestoreService());

// ── Current user profile stream ───────────────────────────────────────────────

/// Live stream of the current user's Firestore profile.
/// Rebuilds whenever the profile document changes.
final currentUserProvider = StreamProvider<UserModel?>((ref) {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return Stream.value(null);

  final firestoreService = ref.watch(firestoreServiceProvider);
  return firestoreService.userStream(userId);
});

/// Convenience — returns current UserModel or null (no loading state).
final currentUserValueProvider = Provider<UserModel?>((ref) {
  return ref.watch(currentUserProvider).value;
});

// ── User profile notifier — for profile edits ─────────────────────────────────

class UserProfileState {
  final bool isLoading;
  final String? errorMessage;
  final bool success;

  const UserProfileState({
    this.isLoading = false,
    this.errorMessage,
    this.success = false,
  });

  UserProfileState copyWith({
    bool? isLoading,
    String? errorMessage,
    bool? success,
  }) =>
      UserProfileState(
        isLoading: isLoading ?? this.isLoading,
        errorMessage: errorMessage,
        success: success ?? this.success,
      );
}

class UserProfileNotifier extends StateNotifier<UserProfileState> {
  final FirestoreService _firestore;
  final AuthService _auth;

  UserProfileNotifier(this._firestore, this._auth)
      : super(const UserProfileState());

  /// Creates a new user profile in Firestore after sign-up/first login.
  Future<void> ensureUserExists(UserModel user) async {
    try {
      final existing = await _firestore.getUser(user.id);
      if (existing != null) return; // Already exists
      await _firestore.setUser(user);
    } catch (e) {
      // Non-fatal — user can still use the app
    }
  }

  /// Updates the user's display name.
  Future<void> updateDisplayName(String userId, String name) async {
    state = state.copyWith(isLoading: true);
    try {
      await _firestore.updateUser(userId, {'display_name': name.trim()});
      state = state.copyWith(isLoading: false, success: true);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  /// Updates the user's WhatsApp number.
  Future<void> updateWhatsApp(String userId, String number) async {
    state = state.copyWith(isLoading: true);
    try {
      await _firestore.updateUser(userId, {'whatsapp_contact': number.trim()});
      state = state.copyWith(isLoading: false, success: true);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  /// Updates the user's profile photo URL.
  Future<void> updatePhotoUrl(String userId, String? photoUrl) async {
    state = state.copyWith(isLoading: true);
    try {
      await _firestore.updateUser(userId, {'photo_url': photoUrl});
      state = state.copyWith(isLoading: false, success: true);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  /// Updates the user's location.
  Future<void> updateLocation(
    String userId, {
    required String city,
    required String area,
    required double latitude,
    required double longitude,
  }) async {
    try {
      await _firestore.updateUser(userId, {
        'city': city,
        'area': area,
        'latitude': latitude,
        'longitude': longitude,
      });
    } catch (e) {
      // Non-fatal
    }
  }

  /// Deletes the user's account and all their data.
  Future<bool> deleteAccount(String userId) async {
    state = state.copyWith(isLoading: true);
    try {
      await _firestore.deleteUserData(userId);
      await _auth.deleteAccount();
      state = state.copyWith(isLoading: false, success: true);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }

  void clearError() {
    state = state.copyWith(errorMessage: null, success: false);
  }
}

final userProfileNotifierProvider =
    StateNotifierProvider<UserProfileNotifier, UserProfileState>((ref) {
  return UserProfileNotifier(
    ref.watch(firestoreServiceProvider),
    ref.watch(authServiceProvider),
  );
});

/// Stream provider family for fetching any user's profile by ID.
/// Used by item detail, seller listings, etc.
final sellerProfileProvider =
    StreamProvider.family<UserModel?, String>((ref, sellerId) {
  return ref.watch(firestoreServiceProvider).userStream(sellerId);
});
