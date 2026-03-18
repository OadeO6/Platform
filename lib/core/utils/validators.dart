import '../constants/app_constants.dart';
import '../constants/app_strings.dart';

/// Form field validators for Platform.
/// All validators return null on success, or an error string on failure.
class Validators {
  Validators._();

  // ── Auth ──────────────────────────────────────────────────────────────────

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) return 'Email is required';
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) return 'Enter a valid email address';
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  static String? confirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) return 'Please confirm your password';
    if (value != password) return 'Passwords do not match';
    return null;
  }

  // ── Item ──────────────────────────────────────────────────────────────────

  static String? title(String? value) {
    if (value == null || value.trim().isEmpty) return 'Title is required';
    if (value.trim().length > AppConstants.titleMaxLength) {
      return 'Title must be ${AppConstants.titleMaxLength} characters or less';
    }
    return null;
  }

  static String? price(String? value) {
    if (value == null || value.trim().isEmpty) return 'Price is required';
    final parsed = double.tryParse(
      value.replaceAll('₦', '').replaceAll(',', '').trim(),
    );
    if (parsed == null) return 'Enter a valid price';
    if (parsed < 0) return 'Price cannot be negative';
    return null;
  }

  static String? description(String? value) {
    if (value == null || value.isEmpty) return null; // optional
    if (value.length > AppConstants.descriptionMaxLength) {
      return 'Description must be ${AppConstants.descriptionMaxLength} characters or less';
    }
    return null;
  }

  static String? category(String? value) {
    if (value == null || value.trim().isEmpty) return 'Please select a category';
    return null;
  }

  static String? condition(String? value) {
    if (value == null || value.trim().isEmpty) return 'Please select a condition';
    return null;
  }

  // ── Contact ───────────────────────────────────────────────────────────────

  /// Validates a WhatsApp number.
  /// Accepts Nigerian formats: 08012345678, +2348012345678, 2348012345678
  /// Also accepts other international formats: +447911123456 etc.
  static String? whatsappNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.whatsappRequired;
    }

    // Strip spaces, dashes, parentheses
    final cleaned = value.replaceAll(RegExp(r'[\s\-\(\)]'), '');

    if (cleaned.isEmpty) return 'Enter a valid WhatsApp number';

    // Normalise to E.164-style for validation
    String normalised;
    if (cleaned.startsWith('+')) {
      normalised = cleaned; // already has country code
    } else if (cleaned.startsWith('234')) {
      normalised = '+$cleaned'; // Nigerian number without +
    } else if (cleaned.startsWith('0') && cleaned.length >= 10) {
      // Nigerian local format: 0XXXXXXXXXX
      normalised = '+234${cleaned.substring(1)}';
    } else {
      normalised = '+$cleaned';
    }

    // Strip + for digit count check
    final digits = normalised.replaceAll('+', '');

    // Must be 7–15 digits after stripping + (E.164 standard)
    if (!RegExp(r'^\d{7,15}$').hasMatch(digits)) {
      return 'Enter a valid phone number (e.g. 08012345678)';
    }

    // Nigerian numbers: +234 followed by 10 digits (7XX, 8XX, 9XX)
    if (normalised.startsWith('+234')) {
      final local = normalised.substring(4); // digits after +234
      if (local.length != 10) {
        return 'Nigerian numbers must have 10 digits after the country code';
      }
      if (!RegExp(r'^[789]').hasMatch(local)) {
        return 'Enter a valid Nigerian mobile number';
      }
    }

    return null;
  }

  /// Normalises a WhatsApp number to E.164 format for wa.me links.
  /// Returns null if the number is invalid.
  static String? normaliseWhatsApp(String value) {
    final cleaned = value.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    if (cleaned.isEmpty) return null;

    String normalised;
    if (cleaned.startsWith('+')) {
      normalised = cleaned;
    } else if (cleaned.startsWith('234')) {
      normalised = '+$cleaned';
    } else if (cleaned.startsWith('0') && cleaned.length >= 10) {
      normalised = '+234${cleaned.substring(1)}';
    } else {
      normalised = '+$cleaned';
    }

    final digits = normalised.replaceAll('+', '');
    if (!RegExp(r'^\d{7,15}$').hasMatch(digits)) return null;
    return normalised;
  }

  // ── Display name ──────────────────────────────────────────────────────────

  static String? displayName(String? value) {
    if (value == null || value.trim().isEmpty) return 'Name is required';
    if (value.trim().length < 2) return 'Name must be at least 2 characters';
    if (value.trim().length > 50) return 'Name must be 50 characters or less';
    return null;
  }

  // ── Report ────────────────────────────────────────────────────────────────

  static String? reportReason(String? value) {
    if (value == null || value.trim().isEmpty) return 'Please select a reason';
    return null;
  }
}
