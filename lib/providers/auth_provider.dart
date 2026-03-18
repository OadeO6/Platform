import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';
import 'user_provider.dart';

// ── Service provider ──────────────────────────────────────────────────────────

final authServiceProvider = Provider<AuthService>((ref) => AuthService());

// ── Auth state stream ─────────────────────────────────────────────────────────

/// Stream of Firebase auth state changes (User? — null when signed out).
/// Used by GoRouter redirect to protect routes.
final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authServiceProvider).authStateChanges;
});

/// Convenience — returns the current Firebase User or null.
final currentFirebaseUserProvider = Provider<User?>((ref) {
  return ref.watch(authStateProvider).value;
});

/// Returns the current user's UID or null.
final currentUserIdProvider = Provider<String?>((ref) {
  return ref.watch(currentFirebaseUserProvider)?.uid;
});

/// Returns true if a user is currently signed in.
final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authStateProvider).value != null;
});

// ── Auth notifier — for login/signup/logout actions ───────────────────────────

enum AuthStatus { idle, loading, success, error }

class AuthState {
  final AuthStatus status;
  final String? errorMessage;

  const AuthState({
    this.status = AuthStatus.idle,
    this.errorMessage,
  });

  AuthState copyWith({AuthStatus? status, String? errorMessage}) => AuthState(
        status: status ?? this.status,
        errorMessage: errorMessage,
      );

  bool get isLoading => status == AuthStatus.loading;
  bool get hasError => status == AuthStatus.error;
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;
  final UserProfileNotifier _userProfileNotifier;

  AuthNotifier(this._authService, this._userProfileNotifier)
      : super(const AuthState());

  Future<void> signInWithGoogle() async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      final user = await _authService.signInWithGoogle();
      await _ensureProfile(user);
      state = state.copyWith(status: AuthStatus.success);
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      final user = await _authService.signInWithEmail(
        email: email,
        password: password,
      );
      await _ensureProfile(user);
      state = state.copyWith(status: AuthStatus.success);
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> createAccount({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      final user = await _authService.createAccountWithEmail(
        email: email,
        password: password,
      );
      await _ensureProfile(user);
      state = state.copyWith(status: AuthStatus.success);
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> _ensureProfile(User firebaseUser) async {
    final user = UserModel(
      id: firebaseUser.uid,
      email: firebaseUser.email ?? '',
      displayName: firebaseUser.displayName ?? firebaseUser.email ?? '',
      photoUrl: firebaseUser.photoURL,
      memberSince: DateTime.now(),
    );
    await _userProfileNotifier.ensureUserExists(user);
  }

  Future<void> sendPasswordReset(String email) async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      await _authService.sendPasswordResetEmail(email);
      state = state.copyWith(status: AuthStatus.success);
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> signOut() async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      await _authService.signOut();
      state = state.copyWith(status: AuthStatus.idle);
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  void clearError() {
    state = state.copyWith(status: AuthStatus.idle, errorMessage: null);
  }
}

final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(
    ref.watch(authServiceProvider),
    ref.watch(userProfileNotifierProvider.notifier),
  );
});
