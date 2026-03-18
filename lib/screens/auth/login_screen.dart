import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_decorations.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/validators.dart';
import '../../core/extensions/context_extensions.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/items_provider.dart';
import '../../widgets/platform_button.dart';
import '../../router/app_router.dart';
import '../../models/user_model.dart';

enum _AuthMode { login, signup }

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  _AuthMode _mode = _AuthMode.login;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );
    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _toggleMode() {
    _animController.reverse().then((_) {
      setState(() {
        _mode =
            _mode == _AuthMode.login ? _AuthMode.signup : _AuthMode.login;
        _formKey.currentState?.reset();
      });
      _animController.forward();
    });
  }

  Future<void> _submitEmail() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    final notifier = ref.read(authNotifierProvider.notifier);
    if (_mode == _AuthMode.login) {
      await notifier.signInWithEmail(
        email: _emailController.text,
        password: _passwordController.text,
      );
    } else {
      await notifier.createAccount(
        email: _emailController.text,
        password: _passwordController.text,
      );
    }

    if (!mounted) return;
    final state = ref.read(authNotifierProvider);
    if (state.status == AuthStatus.success) {
      // Ensure Firestore profile exists, then let the router redirect handle navigation.
      await _ensureUserProfile();
    } else if (state.hasError) {
      context.showSnackBar(state.errorMessage ?? AppStrings.genericError,
          isError: true);
      notifier.clearError();
    }
  }

  Future<void> _signInWithGoogle() async {
    FocusScope.of(context).unfocus();
    final notifier = ref.read(authNotifierProvider.notifier);
    await notifier.signInWithGoogle();

    if (!mounted) return;
    final state = ref.read(authNotifierProvider);
    if (state.status == AuthStatus.success) {
      // Ensure Firestore profile exists, then let the router redirect handle navigation.
      await _ensureUserProfile();
    } else if (state.hasError) {
      context.showSnackBar(state.errorMessage ?? AppStrings.genericError,
          isError: true);
      notifier.clearError();
    }
  }

  Future<void> _ensureUserProfile() async {
    final firebaseUser = ref.read(currentFirebaseUserProvider);
    if (firebaseUser == null) return;

    final user = UserModel(
      id: firebaseUser.uid,
      email: firebaseUser.email ?? '',
      displayName: firebaseUser.displayName ?? firebaseUser.email ?? '',
      photoUrl: firebaseUser.photoURL,
      memberSince: DateTime.now(),
    );
    await ref.read(userProfileNotifierProvider.notifier).ensureUserExists(user);

    // Detect and save location quietly in background
    _detectAndSaveLocation(firebaseUser.uid);
  }

  Future<void> _detectAndSaveLocation(String userId) async {
    try {
      final locationService = ref.read(locationServiceProvider);
      final result = await locationService.getCurrentLocation();
      if (!result.hasLocation) return;
      await ref.read(userProfileNotifierProvider.notifier).updateLocation(
            userId,
            city: result.city!,
            area: result.area ?? '',
            latitude: result.latitude ?? 0,
            longitude: result.longitude ?? 0,
          );
    } catch (_) {
      // Location is optional — never crash or block login
    }
  }

  Future<void> _forgotPassword() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      context.showSnackBar('Enter your email first', isError: true);
      return;
    }
    await ref.read(authNotifierProvider.notifier).sendPasswordReset(email);
    if (!mounted) return;
    context.showSnackBar(AppStrings.resetPasswordSent);
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final isDark = context.isDark;
    final isSignup = _mode == _AuthMode.signup;

    return Scaffold(
      backgroundColor: context.backgroundColor,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),

                // ── Header ────────────────────────────────────────────────
                Text(
                  isSignup ? 'Create\nAccount —' : 'Welcome\nBack —',
                  style: AppTextStyles.displayLarge(
                    color: context.textPrimaryColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  isSignup
                      ? 'Join Platform to buy and sell.'
                      : 'Sign in to continue.',
                  style: AppTextStyles.bodyMedium(
                      color: context.textSecondaryColor),
                ),

                const SizedBox(height: 40),

                // ── Google button ─────────────────────────────────────────
                PlatformButton.outlined(
                  label: AppStrings.continueWithGoogle,
                  onPressed: authState.isLoading ? null : _signInWithGoogle,
                  icon: Icons.g_mobiledata_rounded,
                  loading: authState.isLoading &&
                      authState.status == AuthStatus.loading,
                ),

                const SizedBox(height: 20),

                // ── Divider ───────────────────────────────────────────────
                Row(
                  children: [
                    Expanded(
                      child: Divider(color: context.dividerColor),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        'or',
                        style: AppTextStyles.bodySmall(
                            color: context.textSecondaryColor),
                      ),
                    ),
                    Expanded(
                      child: Divider(color: context.dividerColor),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // ── Form ──────────────────────────────────────────────────
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Email
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        style: AppTextStyles.inputText(
                            color: context.textPrimaryColor),
                        decoration: const InputDecoration(
                          labelText: AppStrings.email,
                        ),
                        validator: Validators.email,
                      ),
                      const SizedBox(height: 16),

                      // Password
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        textInputAction: isSignup
                            ? TextInputAction.next
                            : TextInputAction.done,
                        onFieldSubmitted: isSignup ? null : (_) => _submitEmail(),
                        style: AppTextStyles.inputText(
                            color: context.textPrimaryColor),
                        decoration: InputDecoration(
                          labelText: AppStrings.password,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: context.textSecondaryColor,
                              size: 20,
                            ),
                            onPressed: () => setState(
                                () => _obscurePassword = !_obscurePassword),
                          ),
                        ),
                        validator: Validators.password,
                      ),

                      // Confirm password (signup only)
                      if (isSignup) ...[
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _confirmPasswordController,
                          obscureText: _obscureConfirm,
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) => _submitEmail(),
                          style: AppTextStyles.inputText(
                              color: context.textPrimaryColor),
                          decoration: InputDecoration(
                            labelText: AppStrings.confirmPassword,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureConfirm
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: context.textSecondaryColor,
                                size: 20,
                              ),
                              onPressed: () => setState(
                                  () => _obscureConfirm = !_obscureConfirm),
                            ),
                          ),
                          validator: (v) => Validators.confirmPassword(
                              v, _passwordController.text),
                        ),
                      ],

                      // Forgot password (login only)
                      if (!isSignup) ...[
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: _forgotPassword,
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: Text(
                              AppStrings.forgotPassword,
                              style: AppTextStyles.bodySmall(
                                      color: context.primaryColor)
                                  .copyWith(fontWeight: FontWeight.w500),
                            ),
                          ),
                        ),
                      ],

                      const SizedBox(height: 28),

                      // Submit button
                      PlatformButton(
                        label: isSignup
                            ? AppStrings.signup
                            : AppStrings.login,
                        onPressed:
                            authState.isLoading ? null : _submitEmail,
                        loading: authState.isLoading,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // ── Toggle mode ───────────────────────────────────────────
                Center(
                  child: GestureDetector(
                    onTap: _toggleMode,
                    child: Text(
                      isSignup
                          ? AppStrings.hasAccount
                          : AppStrings.noAccount,
                      style: AppTextStyles.bodySmall(
                              color: context.primaryColor)
                          .copyWith(fontWeight: FontWeight.w500),
                    ),
                  ),
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
