/// Price formatting utilities for Platform.
/// All prices are in Nigerian Naira (₦).
class PriceFormatter {
  PriceFormatter._();

  /// Formats a number as a Naira price string.
  /// e.g. 120000 → "₦120,000"
  static String format(num price) {
    if (price == 0) return 'Free';
    final formatted = _addCommas(price.toInt());
    return '₦$formatted';
  }

  /// Formats price with negotiable tag if applicable.
  /// e.g. "₦120,000 (Negotiable)"
  static String formatWithNegotiable(num price, {bool negotiable = false}) {
    final base = format(price);
    if (negotiable) return '$base (Negotiable)';
    return base;
  }

  /// Adds comma separators to an integer.
  /// e.g. 1200000 → "1,200,000"
  static String _addCommas(int value) {
    final str = value.toString();
    final buffer = StringBuffer();
    final length = str.length;

    for (int i = 0; i < length; i++) {
      if (i > 0 && (length - i) % 3 == 0) {
        buffer.write(',');
      }
      buffer.write(str[i]);
    }
    return buffer.toString();
  }

  /// Parses a price string back to a number.
  /// Strips ₦ and commas before parsing.
  static double? parse(String value) {
    final cleaned = value.replaceAll('₦', '').replaceAll(',', '').trim();
    return double.tryParse(cleaned);
  }
}
