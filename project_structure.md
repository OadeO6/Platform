# Platform — Flutter Project Structure

**Version:** 1.0

---

## Table of Contents

1. [Overview](#1-overview)
2. [Tech Stack](#2-tech-stack)
3. [Folder Structure](#3-folder-structure)
4. [Layer Responsibilities](#4-layer-responsibilities)
5. [pubspec.yaml](#5-pubspecyaml)
6. [Key Files Explained](#6-key-files-explained)
7. [Naming Conventions](#7-naming-conventions)
8. [Setup Checklist](#8-setup-checklist)

---

## 1. Overview

Platform uses a **layer-first** architecture. Code is organised by what it does, not which feature it belongs to. This keeps the codebase predictable and easy to navigate — every developer knows exactly where to find models, services, screens, and shared widgets.

```
lib/
├── core/          # Theme, constants, utilities, extensions
├── models/        # Pure data classes
├── services/      # Firebase + external integrations
├── providers/     # Riverpod state management
├── screens/       # UI screens (one folder per screen)
├── widgets/       # Shared reusable widgets
└── router/        # GoRouter navigation
```

---

## 2. Tech Stack

| Concern | Package | Notes |
|---|---|---|
| State Management | `flutter_riverpod` | Modern, flexible, AI-friendly |
| Navigation | `go_router` | Declarative, deep link support |
| Firebase Auth | `firebase_auth` | Google + email/password |
| Firestore | `cloud_firestore` | Main database |
| Firebase Storage | `firebase_storage` | Image uploads |
| Push Notifications | `firebase_messaging` | FCM |
| Deep Links | `firebase_dynamic_links` | Listing share links |
| Google Sign-In | `google_sign_in` | OAuth |
| Location | `geolocator` | Device GPS |
| Geocoding | `geocoding` | Coords → city/area |
| Image Picker | `image_picker` | Camera + gallery |
| Image Compression | `flutter_image_compress` | Before upload |
| WhatsApp | `url_launcher` | Open WhatsApp links |
| Share | `share_plus` | System share sheet |
| Fonts | `google_fonts` | Caveat + DM Sans |
| Cached Images | `cached_network_image` | Feed performance |
| Skeleton Loading | `shimmer` | Loading states |
| Local Storage | `shared_preferences` | Onboarding seen flag, theme preference |
| Notifications UI | `flutter_local_notifications` | Local notification display |
| Drag to Reorder | Built-in `ReorderableListView` | Image reordering |

---

## 3. Folder Structure

```
platform/
├── android/
├── ios/
├── assets/
│   ├── fonts/                        # Not needed (using google_fonts)
│   ├── images/
│   │   └── noise.png                 # Grain texture overlay (200×200px)
│   └── icons/
│       └── app_icon.png
│
├── lib/
│   ├── main.dart                     # Entry point, Firebase init
│   ├── app.dart                      # ProviderScope, MaterialApp.router
│   │
│   ├── core/
│   │   ├── theme/
│   │   │   ├── app_colors.dart       # All colour tokens
│   │   │   ├── app_text_styles.dart  # Full type scale
│   │   │   ├── app_decorations.dart  # Card, input decorations
│   │   │   └── app_theme.dart        # ThemeData light + dark
│   │   ├── constants/
│   │   │   ├── app_constants.dart    # LISTING_CAP=7, SPACE_CAP=20, EXPIRY_DAYS=20, POPULAR_THRESHOLD=10
│   │   │   └── app_strings.dart      # All UI strings
│   │   ├── utils/
│   │   │   ├── date_utils.dart       # "3 days ago", "Expires in 12 days"
│   │   │   ├── price_formatter.dart  # ₦120,000 formatting
│   │   │   └── validators.dart       # Form validation logic
│   │   ├── extensions/
│   │   │   ├── string_extensions.dart   # .capitalise(), .toDisplayName()
│   │   │   └── context_extensions.dart  # context.theme, context.colors
│   │   └── errors/
│   │       └── app_exceptions.dart   # Custom exception classes
│   │
│   ├── models/
│   │   ├── user_model.dart           # UserModel + fromFirestore + toMap
│   │   ├── item_model.dart           # ItemModel + fromFirestore + toMap
│   │   └── report_model.dart         # ReportModel + fromFirestore + toMap
│   │
│   ├── services/
│   │   ├── auth_service.dart         # signInWithGoogle, signInWithEmail, signOut, deleteAccount
│   │   ├── firestore_service.dart    # All Firestore reads/writes
│   │   ├── storage_service.dart      # Image upload/delete (Firebase Storage)
│   │   ├── fcm_service.dart          # FCM token, notification handling
│   │   ├── location_service.dart     # getCurrentLocation, reverseGeocode
│   │   └── whatsapp_service.dart     # buildWhatsAppUrl, launchWhatsApp
│   │
│   ├── providers/
│   │   ├── auth_provider.dart        # authStateProvider, currentUserProvider
│   │   ├── items_provider.dart       # feedItemsProvider, mySpaceProvider, savedItemsProvider
│   │   ├── user_provider.dart        # userProfileProvider, updateProfile
│   │   ├── saved_provider.dart       # savedItemIdsProvider, toggleSave
│   │   └── theme_provider.dart       # themeProvider (light/dark toggle)
│   │
│   ├── screens/
│   │   ├── splash/
│   │   │   └── splash_screen.dart
│   │   │
│   │   ├── auth/
│   │   │   ├── login_screen.dart
│   │   │   └── widgets/
│   │   │       ├── google_sign_in_button.dart
│   │   │       └── auth_toggle_link.dart
│   │   │
│   │   ├── onboarding/
│   │   │   ├── onboarding_screen.dart
│   │   │   └── widgets/
│   │   │       └── onboarding_slide.dart
│   │   │
│   │   ├── home/
│   │   │   ├── home_screen.dart
│   │   │   └── widgets/
│   │   │       ├── item_grid_card.dart
│   │   │       ├── item_list_card.dart
│   │   │       ├── category_filter_row.dart
│   │   │       └── city_filter_strip.dart
│   │   │
│   │   ├── item_detail/
│   │   │   ├── item_detail_screen.dart
│   │   │   └── widgets/
│   │   │       ├── image_gallery.dart
│   │   │       ├── seller_info_block.dart
│   │   │       └── item_detail_bottom_bar.dart
│   │   │
│   │   ├── my_space/
│   │   │   ├── my_space_screen.dart
│   │   │   ├── item_management_screen.dart
│   │   │   └── widgets/
│   │   │       ├── my_space_card.dart
│   │   │       └── manage_item_sheet.dart
│   │   │
│   │   ├── create_item/
│   │   │   ├── create_item_screen.dart
│   │   │   ├── edit_item_screen.dart
│   │   │   ├── category_picker_screen.dart
│   │   │   ├── condition_picker_screen.dart
│   │   │   └── widgets/
│   │   │       ├── image_upload_area.dart
│   │   │       └── receipt_upload_button.dart
│   │   │
│   │   ├── saved/
│   │   │   └── saved_screen.dart
│   │   │
│   │   ├── profile/
│   │   │   ├── profile_screen.dart
│   │   │   └── seller_profile_sheet.dart
│   │   │
│   │   ├── notifications/
│   │   │   ├── notifications_screen.dart
│   │   │   └── widgets/
│   │   │       └── notification_row.dart
│   │   │
│   │   └── error/
│   │       ├── item_unavailable_screen.dart
│   │       └── item_sold_screen.dart
│   │
│   ├── widgets/                      # Shared across multiple screens
│   │   ├── platform_app_bar.dart     # Custom app bar with Caveat title + dash accent
│   │   ├── platform_button.dart      # Primary, ghost, destructive, WhatsApp variants
│   │   ├── platform_text_field.dart  # Styled input with label + counter
│   │   ├── platform_bottom_sheet.dart # Styled bottom sheet wrapper
│   │   ├── platform_card.dart        # Card with offset sticker shadow
│   │   ├── empty_state.dart          # Icon + Caveat heading + supporting text
│   │   ├── skeleton_loader.dart      # Shimmer skeleton shapes
│   │   ├── popular_badge.dart        # "Popular" overlay badge
│   │   ├── condition_chip.dart       # Filled accent pill
│   │   ├── noise_background.dart     # Grain texture overlay wrapper
│   │   └── layout_toggle.dart        # Grid / list view toggle button
│   │
│   └── router/
│       └── app_router.dart           # All GoRouter routes + redirect logic
│
├── test/
│   ├── models/
│   ├── services/
│   └── providers/
│
└── pubspec.yaml
```

---

## 4. Layer Responsibilities

### `core/`
Pure utilities. No Flutter widgets, no Firebase calls. Can be tested without any dependencies.

- `theme/` — all design tokens, ThemeData configuration
- `constants/` — magic numbers and strings in one place (change `LISTING_CAP` here, it updates everywhere)
- `utils/` — stateless helper functions
- `extensions/` — syntactic sugar on existing types
- `errors/` — typed exceptions for clean error handling

### `models/`
Plain Dart classes. Each model has:
- Named constructor
- `fromFirestore(DocumentSnapshot)` factory
- `toMap()` method for writes
- `copyWith()` for immutable updates

No business logic. No Firebase imports in models.

### `services/`
All external communication lives here. Services are plain Dart classes injected via Riverpod providers. They know nothing about UI.

- One responsibility per service
- All methods are `async` and return typed results
- Errors thrown as `AppException` subtypes

### `providers/`
Riverpod providers that connect services to UI. They hold state, expose streams, and call services. Screens never call services directly — always through providers.

### `screens/`
One folder per screen. Each screen folder contains:
- The main screen file
- A `widgets/` subfolder for screen-specific widgets that aren't shared

Screens only read from providers and call provider methods. No direct Firebase or service calls.

### `widgets/`
Shared UI components used across 2+ screens. These are the building blocks of the design system — `PlatformButton`, `PlatformCard`, `EmptyState`, etc.

### `router/`
Single source of truth for all navigation. GoRouter configuration, route names, redirect logic (e.g. redirect to login if not authenticated).

---

## 5. pubspec.yaml

```yaml
name: platform
description: A minimalist marketplace app for buying and selling used items.
version: 1.0.0+1

environment:
  sdk: ">=3.0.0 <4.0.0"

dependencies:
  flutter:
    sdk: flutter

  # Firebase Core
  firebase_core: ^2.24.2
  firebase_auth: ^4.16.0
  cloud_firestore: ^4.14.0
  firebase_storage: ^11.6.0
  firebase_messaging: ^14.7.10
  firebase_dynamic_links: ^5.4.12

  # Auth
  google_sign_in: ^6.2.1

  # State Management
  flutter_riverpod: ^2.4.10
  riverpod_annotation: ^2.3.4

  # Navigation
  go_router: ^13.2.0

  # Location
  geolocator: ^11.0.0
  geocoding: ^3.0.0

  # Images
  image_picker: ^1.0.7
  flutter_image_compress: ^2.1.0
  cached_network_image: ^3.3.1

  # UI & UX
  google_fonts: ^6.2.1
  shimmer: ^3.0.0
  share_plus: ^7.2.2
  url_launcher: ^6.2.6

  # Storage
  shared_preferences: ^2.2.3

  # Notifications
  flutter_local_notifications: ^17.1.2

  # Utils
  intl: ^0.19.0
  uuid: ^4.3.3
  equatable: ^2.0.5

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0
  build_runner: ^2.4.8
  riverpod_generator: ^2.3.9
  custom_lint: ^0.6.4
  riverpod_lint: ^2.3.9

flutter:
  uses-material-design: true

  assets:
    - assets/images/noise.png
    - assets/icons/app_icon.png
```

---

## 6. Key Files Explained

### `main.dart`
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const ProviderScope(child: PlatformApp()));
}
```

### `app.dart`
```dart
class PlatformApp extends ConsumerWidget {
  const PlatformApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeProvider);

    return MaterialApp.router(
      title: 'Platform',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}
```

### `router/app_router.dart`
```dart
// Route names as constants — never use raw strings
class AppRoutes {
  static const splash        = '/';
  static const login         = '/login';
  static const onboarding    = '/onboarding';
  static const home          = '/home';
  static const itemDetail    = '/item/:id';
  static const mySpace       = '/my-space';
  static const createItem    = '/create-item';
  static const editItem      = '/edit-item/:id';
  static const saved         = '/saved';
  static const profile       = '/profile';
  static const notifications = '/notifications';
  static const itemUnavailable = '/unavailable';
}
```

### `core/constants/app_constants.dart`
```dart
class AppConstants {
  // Listing rules
  static const int listingCap      = 7;
  static const int spaceCap        = 20;
  static const int expiryDays      = 20;
  static const int renewalDays     = 20;
  static const int expiryWarnDays  = 3;
  static const int popularThreshold = 10;

  // Item constraints
  static const int titleMaxLength       = 80;
  static const int descriptionMaxLength = 400;
  static const int maxImages            = 5;
  static const int minImages            = 1;
  static const int maxImageSizeMb       = 2;

  // Pagination
  static const int feedPageSize = 20;

  // WhatsApp
  static const String whatsappBaseUrl = 'https://wa.me/';
  static const String whatsappMessage =
    'Hi, I saw your listing for "{title}". Item ID: {id}. Is it still available?';
}
```

---

## 7. Naming Conventions

| Type | Convention | Example |
|---|---|---|
| Files | `snake_case` | `item_detail_screen.dart` |
| Classes | `PascalCase` | `ItemDetailScreen` |
| Variables | `camelCase` | `isLoading` |
| Constants | `camelCase` | `listingCap` |
| Riverpod providers | `camelCase` + `Provider` suffix | `feedItemsProvider` |
| Routes | `camelCase` in `AppRoutes` | `AppRoutes.itemDetail` |
| Firestore collections | `camelCase` | `items`, `users`, `reports` |
| Assets | `snake_case` | `noise.png`, `app_icon.png` |

---

## 8. Setup Checklist

- [ ] Create Flutter project: `flutter create platform`
- [ ] Replace `pubspec.yaml` with the one above
- [ ] Run `flutter pub get`
- [ ] Create folder structure as defined in Section 3
- [ ] Add `assets/images/noise.png` (tileable grain texture, 200×200px, <10KB)
- [ ] Create `lib/core/theme/app_colors.dart` from DESIGN.md tokens
- [ ] Create `lib/core/theme/app_text_styles.dart` from DESIGN.md type scale
- [ ] Create `lib/core/constants/app_constants.dart`
- [ ] Set up Firebase project (see Firebase setup guide)
- [ ] Run `flutterfire configure` to connect Flutter to Firebase
- [ ] Set up GoRouter in `lib/router/app_router.dart`
- [ ] Build splash screen first — validates Firebase connection works

---

*End of Platform Flutter Project Structure v1.0*
