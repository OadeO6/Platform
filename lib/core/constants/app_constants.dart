/// All magic numbers and configuration constants for Platform.
/// Never hardcode these values in screens or widgets — always reference here.
class AppConstants {
  AppConstants._();

  // ── Listing Rules ─────────────────────────────────────────────────────────

  /// Maximum number of items with status=active at one time
  static const int listingCap = 7;

  /// Maximum items in space (active + unlisted combined — sold excluded)
  static const int spaceCap = 20;

  /// Days until a listing expires after being listed/renewed
  static const int expiryDays = 20;

  /// Days before expiry to send FCM warning notification
  static const int expiryWarnDays = 3;

  /// Number of saves required to show the Popular badge
  static const int popularThreshold = 10;

  // ── Item Constraints ──────────────────────────────────────────────────────

  static const int titleMaxLength = 80;
  static const int descriptionMaxLength = 400;
  static const int maxImages = 5;
  static const int minImages = 1;
  static const int maxImageSizeMb = 2;
  static const int maxImageSizeBytes = maxImageSizeMb * 1024 * 1024;

  // ── Feed ──────────────────────────────────────────────────────────────────

  /// Number of items loaded per infinite scroll batch
  static const int feedPageSize = 20;

  // ── WhatsApp ──────────────────────────────────────────────────────────────

  static const String whatsappBaseUrl = 'https://wa.me/';

  /// Prefilled message template.
  /// Replace {title} and {id} before encoding.
  static const String whatsappMessageTemplate =
      'Hi, I saw your listing for "{title}". Item ID: {id}. Is it still available?';

  // ── Cloudinary ────────────────────────────────────────────────────────────

  /// Upload preset for item listing images
  static const String cloudinaryPresetItems = 'platform_items';

  /// Upload preset for user profile photos
  static const String cloudinaryPresetAvatars = 'platform_avatars';

  /// Base Cloudinary upload URL — append cloud name at runtime from .env
  static const String cloudinaryUploadBaseUrl =
      'https://api.cloudinary.com/v1_1';

  // ── UI ────────────────────────────────────────────────────────────────────

  /// Standard horizontal screen padding
  static const double screenPadding = 16.0;

  /// Standard card border radius
  static const double cardRadius = 8.0;

  /// Card offset shadow — x and y offset in dp
  static const double cardShadowOffset = 3.0;

  /// Bottom nav bar height
  static const double bottomNavHeight = 64.0;

  /// Standard button height
  static const double buttonHeight = 52.0;

  // ── Firestore Collections ─────────────────────────────────────────────────

  static const String colUsers = 'users';
  static const String colItems = 'items';
  static const String colReports = 'reports';
  static const String colSaved = 'saved';

  // ── Item Status Values ────────────────────────────────────────────────────

  static const String statusActive = 'active';
  static const String statusUnlisted = 'unlisted';
  static const String statusSold = 'sold';

  // ── SharedPreferences Keys ────────────────────────────────────────────────

  static const String prefOnboardingSeen = 'onboarding_seen';
  static const String prefThemeMode = 'theme_mode';

  // ── Notification Types ────────────────────────────────────────────────────

  static const String notifTypeExpiry  = 'listing_expiry';
  static const String notifTypeGeneral = 'general';
}
