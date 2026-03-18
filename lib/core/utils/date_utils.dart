/// Date and time utility functions for Platform.
class DateUtils {
  DateUtils._();

  /// Returns a human-readable relative time string.
  /// e.g. "3 days ago", "just now", "2 hours ago"
  static String timeAgo(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inSeconds < 60) return 'just now';
    if (diff.inMinutes < 60) {
      final m = diff.inMinutes;
      return '$m ${m == 1 ? 'minute' : 'minutes'} ago';
    }
    if (diff.inHours < 24) {
      final h = diff.inHours;
      return '$h ${h == 1 ? 'hour' : 'hours'} ago';
    }
    if (diff.inDays < 7) {
      final d = diff.inDays;
      return '$d ${d == 1 ? 'day' : 'days'} ago';
    }
    if (diff.inDays < 30) {
      final w = (diff.inDays / 7).floor();
      return '$w ${w == 1 ? 'week' : 'weeks'} ago';
    }
    if (diff.inDays < 365) {
      final mo = (diff.inDays / 30).floor();
      return '$mo ${mo == 1 ? 'month' : 'months'} ago';
    }
    final y = (diff.inDays / 365).floor();
    return '$y ${y == 1 ? 'year' : 'years'} ago';
  }

  /// Returns expiry countdown string for a listing.
  /// e.g. "Expires in 12 days", "Expires in 1 day", "Expired"
  static String expiryCountdown(DateTime expiresAt) {
    final now = DateTime.now();
    final diff = expiresAt.difference(now);

    if (diff.isNegative) return 'Expired';
    if (diff.inDays == 0) return 'Expires today';
    if (diff.inDays == 1) return 'Expires in 1 day';
    return 'Expires in ${diff.inDays} days';
  }

  /// Returns true if the listing has expired
  static bool isExpired(DateTime expiresAt) {
    return DateTime.now().isAfter(expiresAt);
  }

  /// Returns true if expiry warning should be shown (within 3 days)
  static bool isNearExpiry(DateTime expiresAt, {int warnDays = 3}) {
    final now = DateTime.now();
    final diff = expiresAt.difference(now);
    return !diff.isNegative && diff.inDays <= warnDays;
  }

  /// Returns a formatted date string for "Member since" and "Posted" labels.
  /// e.g. "January 2024", "March 2026"
  static String formatMonthYear(DateTime date) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${months[date.month - 1]} ${date.year}';
  }

  /// Returns a formatted date + time string for "Edited" label.
  /// e.g. "12 Mar 2026, 3:45 PM"
  static String formatEditedAt(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final hour = date.hour > 12 ? date.hour - 12 : date.hour == 0 ? 12 : date.hour;
    final minute = date.minute.toString().padLeft(2, '0');
    final period = date.hour >= 12 ? 'PM' : 'AM';
    return '${date.day} ${months[date.month - 1]} ${date.year}, $hour:$minute $period';
  }

  /// Calculates expiry date from listing date.
  /// expiresAt = listedAt + 20 days
  static DateTime calculateExpiry(DateTime listedAt, {int days = 20}) {
    return listedAt.add(Duration(days: days));
  }

  /// Calculates renewed expiry from today.
  static DateTime calculateRenewalExpiry({int days = 20}) {
    return DateTime.now().add(Duration(days: days));
  }
}
