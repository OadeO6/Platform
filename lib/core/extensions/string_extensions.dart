/// Useful string extensions for Platform.
extension StringExtensions on String {
  /// Capitalises the first letter of the string.
  /// e.g. "hello world" → "Hello world"
  String get capitalised {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  /// Converts an email to a display name.
  /// e.g. "abdulrahman@gmail.com" → "abdulrahman"
  String get toDisplayName {
    if (!contains('@')) return capitalised;
    return split('@').first.capitalised;
  }

  /// Formats a raw phone number for WhatsApp.
  /// Strips spaces, dashes, parentheses.
  /// Ensures it starts with + for international format.
  String get toWhatsAppNumber {
    final cleaned = replaceAll(RegExp(r'[\s\-\(\)]'), '');
    if (cleaned.startsWith('0')) {
      // Nigerian numbers: replace leading 0 with +234
      return '+234${cleaned.substring(1)}';
    }
    if (!cleaned.startsWith('+')) {
      return '+$cleaned';
    }
    return cleaned;
  }

  /// Truncates string to maxLength and appends ellipsis if needed.
  /// e.g. "Hello World"..truncate(5) → "Hello..."
  String truncate(int maxLength) {
    if (length <= maxLength) return this;
    return '${substring(0, maxLength)}...';
  }

  /// Returns true if the string is a valid URL.
  bool get isValidUrl {
    final urlRegex = RegExp(
      r'^(https?:\/\/)?([\da-z\.-]+)\.([a-z\.]{2,6})([\/\w \.-]*)*\/?$',
    );
    return urlRegex.hasMatch(this);
  }

  /// Removes leading/trailing whitespace and collapses internal whitespace.
  String get normalized => trim().replaceAll(RegExp(r'\s+'), ' ');
}

/// Nullable string extensions.
extension NullableStringExtensions on String? {
  /// Returns true if the string is null or empty.
  bool get isNullOrEmpty => this == null || this!.isEmpty;

  /// Returns the string or a fallback value if null/empty.
  String orDefault(String fallback) {
    return isNullOrEmpty ? fallback : this!;
  }
}
