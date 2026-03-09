/// All user-facing strings for Platform.
/// Never hardcode UI text in widgets — always reference this class.
class AppStrings {
  AppStrings._();

  // ── App ───────────────────────────────────────────────────────────────────

  static const String appName = 'Platform';
  static const String appTagline = 'Buy and sell, simply.';

  // ── Auth ──────────────────────────────────────────────────────────────────

  static const String login = 'Login';
  static const String signup = 'Create Account';
  static const String continueWithGoogle = 'Continue with Google';
  static const String email = 'Email';
  static const String password = 'Password';
  static const String confirmPassword = 'Confirm Password';
  static const String forgotPassword = 'Forgot password?';
  static const String noAccount = "Don't have an account? Sign up";
  static const String hasAccount = 'Already have an account? Login';
  static const String resetPasswordSent =
      'Password reset email sent. Check your inbox.';

  // ── Onboarding ────────────────────────────────────────────────────────────

  static const String onboardingSkip = 'Skip';
  static const String onboardingGetStarted = 'Get Started';

  static const List<String> onboardingTitles = [
    'Buy & Sell Used Items',
    'List in Under a Minute',
    'Connect on WhatsApp',
  ];

  static const List<String> onboardingSubtitles = [
    'Browse listings near you',
    'Photo, price, done.',
    'Direct contact, no middleman.',
  ];

  // ── Home Feed ─────────────────────────────────────────────────────────────

  static const String searchHint = 'Search listings...';
  static const String showingIn = 'Showing listings in';
  static const String allListings = 'All listings';
  static const String popular = 'Popular';

  // ── Categories ────────────────────────────────────────────────────────────

  static const String catAll = 'All';
  static const String catPhones = 'Phones & Tablets';
  static const String catBooks = 'Books & Textbooks';
  static const String catBags = 'Bags & Accessories';
  static const String catGadgets = 'Gadgets & Electronics';
  static const String catClothing = 'Clothing';
  static const String catHome = 'Home & Furniture';
  static const String catOther = 'Other';

  static const List<String> categories = [
    catAll,
    catPhones,
    catBooks,
    catBags,
    catGadgets,
    catClothing,
    catHome,
    catOther,
  ];

  static const List<String> categoriesWithoutAll = [
    catPhones,
    catBooks,
    catBags,
    catGadgets,
    catClothing,
    catHome,
    catOther,
  ];

  // ── Conditions ────────────────────────────────────────────────────────────

  static const String condStillNew = 'Still New';
  static const String condFairlyUsed = 'Fairly Used';
  static const String condOld = 'Old';
  static const String condFairlyOld = 'Fairly Old';
  static const String condNeedsRepair = 'Needs Repair';

  static const List<String> conditions = [
    condStillNew,
    condFairlyUsed,
    condOld,
    condFairlyOld,
    condNeedsRepair,
  ];

  // ── Item Detail ───────────────────────────────────────────────────────────

  static const String negotiable = 'Negotiable';
  static const String contactOnWhatsApp = 'Contact on WhatsApp';
  static const String viewOtherListings = 'View Other Listings';
  static const String reportListing = 'Report this listing';
  static const String readMore = 'Read more';
  static const String readLess = 'Read less';
  static const String itemSold = 'This item has been sold';
  static const String itemUnavailable = 'This listing is no longer available';
  static const String itemUnavailableSubtitle =
      'The item may have been sold or removed by the seller.';
  static const String browseListings = 'Browse Listings';
  static const String edited = 'Edited';
  static const String posted = 'Posted';
  static const String memberSince = 'Member since';
  static const String activeListings = 'active listings';

  // ── My Space ──────────────────────────────────────────────────────────────

  static const String mySpace = 'My Space';
  static const String listed = 'Listed';
  static const String unlisted = 'Unlisted';
  static const String sold = 'Sold';
  static const String createItem = 'Create Item';
  static const String manageItem = 'Manage Item';
  static const String listItem = 'List Item';
  static const String unlistItem = 'Unlist';
  static const String renewListing = 'Renew';
  static const String markAsSold = 'Mark as Sold';
  static const String relistAsTemplate = 'Relist as Template';
  static const String deleteItem = 'Delete';
  static const String expiresIn = 'Expires in';
  static const String days = 'days';
  static const String day = 'day';

  // ── Space / Listing Caps ──────────────────────────────────────────────────

  static const String spaceLimitReached =
      "You've reached your 20-item limit. Delete an item to make space.";
  static const String listingLimitReached =
      "You've reached your 7 listing limit. Unlist or sell an item to list another.";

  // ── Create / Edit Item ────────────────────────────────────────────────────

  static const String createItemTitle = 'Create Item';
  static const String editItemTitle = 'Edit Item';
  static const String saveItem = 'Save Item';
  static const String saveChanges = 'Save Changes';
  static const String titleField = 'Title';
  static const String titleLocked = 'Title cannot be changed after creation';
  static const String priceField = 'Price (₦)';
  static const String negotiableToggle = 'Negotiable';
  static const String categoryField = 'Category';
  static const String selectCategory = 'Select Category';
  static const String conditionField = 'Condition';
  static const String selectCondition = 'Select Condition';
  static const String descriptionField = 'Description (optional)';
  static const String receiptImage = 'Receipt Image (optional)';
  static const String addReceipt = '+ Add Receipt';
  static const String addPhotos = 'Add photos (min 1, max 5)';
  static const String locationAuto = 'Location is automatically detected';
  static const String discardChanges = 'Discard changes?';
  static const String discardChangesBody =
      'You have unsaved changes. Are you sure you want to leave?';
  static const String discard = 'Discard';
  static const String keepEditing = 'Keep Editing';

  // ── WhatsApp ──────────────────────────────────────────────────────────────

  static const String whatsappRequired =
      'A WhatsApp number is required to list items.';
  static const String whatsappNumberField = 'WhatsApp Number';
  static const String addWhatsApp = 'Add WhatsApp Number';

  // ── Profile ───────────────────────────────────────────────────────────────

  static const String profile = 'Profile';
  static const String displayName = 'Display Name';
  static const String whatsappNumber = 'WhatsApp Number';
  static const String appearance = 'Appearance';
  static const String darkMode = 'Dark Mode';
  static const String about = 'About';
  static const String appVersion = 'App Version';
  static const String contactSupport = 'Contact & Support';
  static const String termsOfService = 'Terms of Service';
  static const String privacyPolicy = 'Privacy Policy';
  static const String logout = 'Log Out';
  static const String deleteAccount = 'Delete Account';
  static const String deleteAccountConfirm =
      'Are you sure you want to delete your account? This will permanently remove your account and all your listings.';
  static const String viewPhoto = 'View Photo';
  static const String changePhoto = 'Change Photo';
  static const String removePhoto = 'Remove Photo';

  // ── Saved ─────────────────────────────────────────────────────────────────

  static const String saved = 'Saved';
  static const String savedItems = 'saved items';
  static const String savedItem = 'saved item';

  // ── Notifications ─────────────────────────────────────────────────────────

  static const String notifications = 'Notifications';
  static const String markAllRead = 'Mark all as read';
  static const String noNotifications = 'All quiet here.';
  static const String noNotificationsSubtitle =
      "We'll let you know when something happens.";

  // ── Reporting ─────────────────────────────────────────────────────────────

  static const String reportTitle = 'Report Listing';
  static const String reportSubtitle = 'Help us keep Platform safe';
  static const String reportReasonScam = 'Scam';
  static const String reportReasonFake = 'Fake item';
  static const String reportReasonProhibited = 'Prohibited item';
  static const String reportReasonSpam = 'Spam';
  static const String reportReasonOther = 'Other';
  static const String reportDetails = 'Additional details (optional)';
  static const String submitReport = 'Submit Report';
  static const String reported = 'Reported';

  static const List<String> reportReasons = [
    reportReasonScam,
    reportReasonFake,
    reportReasonProhibited,
    reportReasonSpam,
    reportReasonOther,
  ];

  // ── Navigation ────────────────────────────────────────────────────────────

  static const String navHome = 'Home';
  static const String navSaved = 'Saved';
  static const String navCreate = 'Create';
  static const String navMySpace = 'My Space';
  static const String navProfile = 'Profile';

  // ── Empty States ──────────────────────────────────────────────────────────

  static const String emptyFeedTitle = 'Nothing here yet.';
  static const String emptyFeedSubtitle =
      'Be the first to list something.';
  static const String emptySearchTitle = 'No results found.';
  static const String emptySearchSubtitle =
      'Try a different search or category.';
  static const String emptySavedTitle = 'Nothing saved yet.';
  static const String emptySavedSubtitle =
      'Tap the bookmark on any listing.';
  static const String emptySpaceTitle = 'Your space is empty.';
  static const String emptySpaceSubtitle =
      'Create your first item to get started.';
  static const String emptyNotificationsTitle = 'All quiet here.';
  static const String emptyNotificationsSubtitle =
      "We'll let you know when something happens.";

  // ── Location ──────────────────────────────────────────────────────────────

  static const String locationDisabled =
      'Location disabled — results may be inaccurate';
  static const String locationRequired =
      'Location is required to list an item. Please enable it in your device settings.';

  // ── Errors ────────────────────────────────────────────────────────────────

  static const String genericError = 'Something went wrong. Please try again.';
  static const String networkError =
      'No internet connection. Please check your network.';
  static const String imageTooLarge =
      'Image is too large. Maximum size is 2MB.';
  static const String minImagesRequired =
      'Please add at least one photo.';

  // ── Confirmations ─────────────────────────────────────────────────────────

  static const String deleteItemConfirm =
      'Delete this item? This cannot be undone.';
  static const String markSoldConfirm =
      'Mark this item as sold? It will be moved to your sold history.';
  static const String cancel = 'Cancel';
  static const String confirm = 'Confirm';
  static const String delete = 'Delete';
  static const String yes = 'Yes';
  static const String no = 'No';
}
