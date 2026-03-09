# Platform — Design System

**Version:** 1.0

---

## Table of Contents

1. [Personality & Direction](#1-personality--direction)
2. [Colour](#2-colour)
3. [Typography](#3-typography)
4. [Spacing & Layout](#4-spacing--layout)
5. [Shape & Elevation](#5-shape--elevation)
6. [Buttons](#6-buttons)
7. [Cards](#7-cards)
8. [Pills & Chips](#8-pills--chips)
9. [Tabs](#9-tabs)
10. [Bottom Navigation](#10-bottom-navigation)
11. [Form Elements](#11-form-elements)
12. [Empty States](#12-empty-states)
13. [Loading States](#13-loading-states)
14. [Icons](#14-icons)
15. [Texture & Background](#15-texture--background)
16. [Dark Mode](#16-dark-mode)
17. [Design Tokens (Flutter)](#17-design-tokens-flutter)

---

## 1. Personality & Direction

Platform is not a typical marketplace app. The visual identity should feel:

- **Human** — like it was made by a person, not a template
- **Confident** — knows what it is, doesn't try to do too much
- **Understated** — neutral base, personality in the details
- **Sketch-inspired** — unconventional layouts, unexpected accents, tactile texture

The design avoids:
- Generic mobile UI patterns (standard Material Design out of the box)
- Overly polished, sterile SaaS aesthetics
- Loud colours or complex gradients

The personality lives in:
- The **Caveat** display font — casual, handwritten, human
- The **offset sticker shadow** on cards — tactile, distinctive
- The **grain texture** on backgrounds — subtle but felt
- The **hand-drawn dash accent** on screen headings — a small but consistent detail

Item photos are the hero. The UI steps back and lets them breathe.

---

## 2. Colour

### 2.1 Light Mode Palette

| Token | Hex | Usage |
|---|---|---|
| `background` | `#FAF9F7` | App background (+ grain texture) |
| `surface` | `#FFFFFF` | Cards, bottom sheets, modals |
| `primary` | `#1B3A6B` | Primary buttons, active icons, accent |
| `primaryTint` | `#E8EEF7` | Chip backgrounds, highlight fills |
| `textPrimary` | `#1A1A1A` | Headings, body text |
| `textSecondary` | `#6B6B6B` | Meta info, placeholders, inactive nav |
| `divider` | `#E5E3DF` | Borders, dividers, separators |
| `whatsapp` | `#25D366` | WhatsApp CTA button |
| `destructive` | `#D94F4F` | Delete actions, error states |
| `success` | `#2E7D32` | Sold badge, confirmation states |
| `warning` | `#B45309` | Expiry warning, location warning |

### 2.2 Dark Mode Palette

| Token | Hex | Usage |
|---|---|---|
| `background` | `#141414` | App background |
| `surface` | `#1F1F1F` | Cards, bottom sheets |
| `primary` | `#4A7FD4` | Primary buttons, active icons |
| `primaryTint` | `#1E2D45` | Chip backgrounds |
| `textPrimary` | `#F0EFED` | Headings, body text |
| `textSecondary` | `#9B9B9B` | Meta info, placeholders |
| `divider` | `#2C2C2C` | Borders, dividers |
| `whatsapp` | `#25D366` | WhatsApp CTA (unchanged) |
| `destructive` | `#EF5350` | Delete actions |
| `success` | `#66BB6A` | Sold badge |
| `warning` | `#FFA726` | Warnings |

### 2.3 Colour Usage Rules

- **Never** use `primary` for large background fills — only for buttons, icons, chips, and accents
- **Always** use `surface` for cards, not `background`
- The `background` + `surface` contrast creates the subtle layering that separates content from the page
- `textSecondary` for all supporting info: dates, location, condition meta, counter labels

---

## 2. Typography

### 2.1 Font Families

| Role | Font | Usage |
|---|---|---|
| Display | **Caveat** | Screen titles, price on item detail, onboarding headings, empty state messages, Platform wordmark in app bar |
| UI / Body | **DM Sans** | Body text, buttons, labels, chips, form fields, meta info, navigation |

Both fonts are available on Google Fonts and fully supported in Flutter via the `google_fonts` package.

### 2.2 Type Scale

| Style | Font | Weight | Size | Line Height | Usage |
|---|---|---|---|---|---|
| `displayLarge` | Caveat | Bold 700 | 36sp | 44sp | Price on item detail, onboarding H1 |
| `displayMedium` | Caveat | Bold 700 | 28sp | 36sp | Screen titles (My Space, Saved, etc.) |
| `displaySmall` | Caveat | SemiBold 600 | 22sp | 30sp | Empty state headings, section labels |
| `headlineMedium` | DM Sans | SemiBold 600 | 20sp | 28sp | Item title on detail page |
| `headlineSmall` | DM Sans | SemiBold 600 | 18sp | 26sp | Card titles, form section headers |
| `bodyLarge` | DM Sans | Regular 400 | 16sp | 24sp | Descriptions, body content |
| `bodyMedium` | DM Sans | Regular 400 | 14sp | 22sp | Meta info, secondary content |
| `bodySmall` | DM Sans | Regular 400 | 12sp | 18sp | Timestamps, captions, badges |
| `labelLarge` | DM Sans | Medium 500 | 14sp | 20sp | Buttons, active tab labels |
| `labelMedium` | DM Sans | Medium 500 | 12sp | 16sp | Chips, pills, small labels |
| `labelSmall` | DM Sans | Regular 400 | 11sp | 14sp | Counter labels, fine print |

### 2.3 Heading Decoration

Screen titles in the app bar use **Caveat displayMedium** with a small hand-drawn dash accent:

```
My Space  —
Saved  —
Notifications  —
```

The dash (`—`) is rendered in `primary` colour at reduced opacity (60%), positioned inline after the title text. This is a consistent detail across all screens with a Caveat title.

### 2.4 Platform Wordmark

The app name "Platform" in the home feed app bar uses **Caveat Bold 700, 24sp**, colour `textPrimary`. No logo image required — the wordmark is typographic.

---

## 4. Spacing & Layout

### 4.1 Base Grid

- Base unit: **4dp**
- All spacing is a multiple of 4dp

### 4.2 Spacing Scale

| Token | Value | Usage |
|---|---|---|
| `space2` | 2dp | Icon internal padding |
| `space4` | 4dp | Tight internal spacing |
| `space8` | 8dp | Between related elements |
| `space12` | 12dp | Card internal padding (tight) |
| `space16` | 16dp | Standard section padding, card padding |
| `space20` | 20dp | Between sections |
| `space24` | 24dp | Large section gaps |
| `space32` | 32dp | Screen-level vertical rhythm |
| `space48` | 48dp | Empty state vertical centering |

### 4.3 Screen Margins

- Horizontal screen padding: **16dp** on all sides
- Content never touches screen edges

### 4.4 Asymmetry

Platform intentionally avoids perfect visual symmetry in some places to reinforce the sketch-inspired personality:

- Section headings are left-aligned, not centred
- Onboarding text is left-aligned, not centred
- Price on item detail is left-aligned and large — not placed in a symmetric block

---

## 5. Shape & Elevation

### 5.1 Border Radius

- **Global radius:** 8dp — applied to cards, buttons, inputs, chips, bottom sheets
- **Pill radius:** 100dp — used for condition/category chips only
- **Circle:** used for avatar, Create Item nav button

### 5.2 Card Elevation — Offset Sticker Shadow

Cards do **not** use standard Material elevation (blurred drop shadow). Instead they use a hard offset shadow that creates a sticker/stamp effect:

```
Box shadow:
  offset: (3dp, 3dp)
  blur: 0
  spread: 0
  colour: #1A1A1A at 10% opacity
```

In Flutter:
```dart
BoxDecoration(
  color: AppColors.surface,
  borderRadius: BorderRadius.circular(8),
  border: Border.all(color: AppColors.divider, width: 1),
  boxShadow: [
    BoxShadow(
      color: Color(0x1A1A1A1A),
      offset: Offset(3, 3),
      blurRadius: 0,
    ),
  ],
)
```

### 5.3 No Other Shadows

- Bottom sheets: no shadow — use a top border (`divider` colour)
- App bar: no shadow — use a bottom border (`divider` colour)
- Buttons: no shadow
- Modals/dialogs: no shadow — use border + background overlay

---

## 6. Buttons

### 6.1 Primary Button

Used for the main action on any screen (Save Item, Login, Create Account, Submit Report).

```
Background:   #1B3A6B  (primary)
Text:         #FFFFFF   DM Sans Medium 14sp
Border radius: 8dp
Height:       52dp
Width:        Full width (minus screen margins)
Padding:      16dp horizontal
```

**Disabled state:**
```
Background:   #1B3A6B at 40% opacity
Text:         #FFFFFF at 60% opacity
```

### 6.2 WhatsApp Button

```
Background:   #25D366
Text:         #FFFFFF   DM Sans SemiBold 14sp
Icon:         WhatsApp logo (left of text)
Border radius: 8dp
Height:       52dp
```

### 6.3 Destructive Button

Used for Delete Account, confirm delete actions.

```
Background:   #D94F4F
Text:         #FFFFFF   DM Sans Medium 14sp
Border radius: 8dp
Height:       52dp
```

### 6.4 Ghost Button (Secondary)

Used for secondary actions (View Other Listings, Browse Listings, View Listings).

```
Background:   Transparent
Border:       None
Text:         #1B3A6B   DM Sans Medium 14sp
Icon:         Optional, right of text, accent colour
Underline:    None — distinguished by colour and icon only
```

### 6.5 Text Link

Used for Forgot Password, toggle links, Report this listing.

```
Text:         #1B3A6B   DM Sans Regular 14sp
Underline:    On
```

### 6.6 Destructive Text Link

Used for Delete Account on profile.

```
Text:         #D94F4F   DM Sans Regular 14sp
Underline:    None
```

---

## 7. Cards

### 7.1 Grid Item Card (Home Feed, Saved)

```
┌─────────────────────┐
│                     │  ← image, square aspect ratio
│   [ 🔥 Popular ]   │  ← badge overlay (if applicable)
│                     │
├─────────────────────┤
│ iPhone 11           │  ← DM Sans SemiBold 14sp, textPrimary
│ ₦120,000            │  ← DM Sans Bold 16sp, textPrimary
│ (Negotiable)        │  ← DM Sans Regular 12sp, textSecondary
│ [Fairly Used] Yaba  │  ← chip + DM Sans Regular 12sp
└─────────────────────┘
   (offset shadow)
```

- Image: square crop, 8dp top radius, no bottom radius on image
- Card: full 8dp radius, offset sticker shadow, `surface` background, `divider` border 1dp
- Popular badge: `primary` background, white DM Sans Medium 11sp, 100dp radius, top-left of image

### 7.2 List Item Card (Home Feed, Saved)

```
┌──────────────────────────────────────────────┐
│ [Image]  iPhone 11                           │
│  80×80   ₦120,000  (Negotiable)              │
│          [Fairly Used]  📍 Yaba              │
└──────────────────────────────────────────────┘
```

- Image: 80×80dp, 8dp radius, left-aligned
- Content: right of image, 12dp gap
- Same card shadow and border as grid card

### 7.3 My Space Item Card

Same as list card with an additional expiry line:

```
│ [Image]  iPhone 11                           │
│  80×80   ₦120,000                            │
│          [Fairly Used]  📍 Yaba              │
│          Expires in 12 days  ← warning colour│
```

### 7.4 Notification Row

```
┌──────────────────────────────────────────────┐
│ 🔔  Your listing "iPhone 11" expires in      │
│     3 days                        2h ago  •  │
└──────────────────────────────────────────────┘
```

- No card shadow — flat list rows separated by `divider`
- Unread dot: `primary` colour, 8dp circle, right-aligned

---

## 8. Pills & Chips

### 8.1 Condition / Category Pills (Item Cards & Detail)

```
Background:   #1B3A6B  (primary)
Text:         #FFFFFF   DM Sans Medium 11sp
Border radius: 100dp  (pill)
Padding:      4dp vertical, 10dp horizontal
```

### 8.2 Feed Filter Chips (Home Feed Category Row)

**Inactive:**
```
Background:   transparent
Border:       1dp  #E5E3DF
Text:         #6B6B6B   DM Sans Medium 13sp
Border radius: 100dp
Padding:      8dp vertical, 16dp horizontal
```

**Active:**
```
Background:   #1B3A6B
Border:       none
Text:         #FFFFFF   DM Sans Medium 13sp
```

### 8.3 Status Badge (My Space)

| Status | Background | Text |
|---|---|---|
| Listed | `#E8EEF7` | `#1B3A6B` |
| Unlisted | `#F5F5F5` | `#6B6B6B` |
| Sold | `#E8F5E9` | `#2E7D32` |

---

## 9. Tabs

Used in My Space (Listed / Unlisted / Sold).

**Active tab:**
```
Text:         #1A1A1A   DM Sans SemiBold 14sp
Indicator:    2dp underline, #1A1A1A, full tab width
```

**Inactive tab:**
```
Text:         #6B6B6B   DM Sans Regular 14sp
Indicator:    none
```

- Tab bar has a bottom border (`divider`) separating it from content
- No background colour on tabs — transparent

---

## 10. Bottom Navigation

5 tabs, icons only, no labels.

| Tab | Icon | Active Colour | Inactive Colour |
|---|---|---|---|
| Home | house outline | `#1B3A6B` | `#6B6B6B` |
| Saved | bookmark outline | `#1B3A6B` | `#6B6B6B` |
| Create Item | + in outlined circle | `#1B3A6B` border | `#6B6B6B` border |
| My Space | grid outline | `#1B3A6B` | `#6B6B6B` |
| Profile | person outline | `#1B3A6B` | `#6B6B6B` |

**Create Item button:**
```
Shape:        Circle, 44×44dp
Border:       2dp  #1B3A6B  (active) / #6B6B6B (inactive)
Background:   transparent
Icon:         + symbol, 20dp, accent colour
```

**Nav bar:**
```
Background:   surface  #FFFFFF
Top border:   1dp  #E5E3DF
Height:       64dp
```

---

## 11. Form Elements

### 11.1 Text Input

```
Background:   #FFFFFF
Border:       1dp  #E5E3DF  (idle)
              2dp  #1B3A6B  (focused)
              1dp  #D94F4F  (error)
Border radius: 8dp
Height:       52dp
Padding:      16dp horizontal
Label:        DM Sans Medium 13sp, textSecondary, above field
Text:         DM Sans Regular 16sp, textPrimary
Placeholder:  DM Sans Regular 16sp, textSecondary at 60%
```

### 11.2 Character Counter

```
Text:         DM Sans Regular 11sp, textSecondary
Position:     Bottom right of input field
Format:       "0/80"
```

### 11.3 Toggle / Switch

- Uses Flutter's `Switch` widget
- Active: `primary` colour track
- Inactive: `divider` colour track

### 11.4 Image Upload Area

```
Background:   #FAF9F7
Border:       1.5dp dashed  #E5E3DF
Border radius: 8dp
Height:       160dp
Icon:         Camera icon, textSecondary
Text:         DM Sans Regular 14sp, textSecondary
              "Add photos (min 1, max 5)"
```

Uploaded thumbnails:
```
Size:         80×80dp
Border radius: 8dp
Delete icon:  ✕ overlay, top-right corner
```

---

## 12. Empty States

Minimal — large Caveat message + a single icon. No complex illustrations.

**Layout:**
```
         [Icon — 48dp, textSecondary]

    Nothing here yet.        ← Caveat displaySmall
    [Supporting text]        ← DM Sans bodyMedium, textSecondary

    [Action button]          ← Primary or ghost button (if applicable)
```

**Examples:**

| Screen | Icon | Caveat Heading | Supporting Text |
|---|---|---|---|
| Empty feed | 🏷 | Nothing here yet. | Be the first to list something. |
| Empty saved | 🔖 | Nothing saved yet. | Tap the bookmark on any listing. |
| Empty My Space | 📦 | Your space is empty. | Create your first item to get started. |
| Empty notifications | 🔔 | All quiet here. | We'll let you know when something happens. |
| No search results | 🔍 | No results found. | Try a different search or category. |

---

## 13. Loading States

**Skeleton screens** — shown while content is loading. No spinners for primary content.

Skeleton rules:
- Skeleton shapes match the exact layout of the real content
- Skeleton colour: `#E5E3DF` base, animated shimmer from left to right
- Shimmer highlight: `#F0EFED`
- Used on: home feed, saved tab, my space, notifications, item detail

**Inline loaders** (for button actions, form submissions):
- Small circular `CircularProgressIndicator` inside the button
- Button text replaced by loader while processing
- Button disabled during loading

---

## 14. Icons

- Icon library: **Lucide Icons** (consistent with the clean, slightly rounded aesthetic)
- Size: 24dp standard, 20dp for inline/compact contexts, 16dp for chips
- Colour: inherits from context (`textPrimary`, `textSecondary`, or `primary`)
- Stroke weight: 1.5dp (Lucide default)

---

## 15. Texture & Background

### 15.1 Grain Texture

A very subtle noise texture is applied as an overlay on the `#FAF9F7` background in light mode.

```
Type:     SVG or PNG noise texture
Opacity:  4%
Blend:    Overlay
Repeat:   Tile across full screen
```

In Flutter, this is implemented as a full-screen `Stack` with a semi-transparent noise image widget behind all content:

```dart
Stack(
  children: [
    Positioned.fill(
      child: Opacity(
        opacity: 0.04,
        child: Image.asset('assets/noise.png', repeat: ImageRepeat.repeat),
      ),
    ),
    // screen content
  ],
)
```

The texture is **disabled in dark mode** — dark backgrounds don't benefit from it.

### 15.2 Noise Asset

A small (200×200px) tileable PNG noise texture. Generated once and stored as an asset. Kept under 10KB.

---

## 16. Dark Mode

Dark mode follows the same design language with adjusted colours. Key rules:

- `background` → `#141414`
- `surface` → `#1F1F1F`
- Card offset shadow colour changes to `#000000` at 20% opacity
- Grain texture disabled
- `primary` accent lightened to `#4A7FD4` for legibility on dark backgrounds
- All other design tokens remain structurally identical

Dark mode is toggled from the Profile screen and respects the system default on first launch.

---

## 17. Design Tokens (Flutter)

```dart
// lib/core/theme/app_colors.dart

class AppColors {
  // Light Mode
  static const background     = Color(0xFFFAF9F7);
  static const surface        = Color(0xFFFFFFFF);
  static const primary        = Color(0xFF1B3A6B);
  static const primaryTint    = Color(0xFFE8EEF7);
  static const textPrimary    = Color(0xFF1A1A1A);
  static const textSecondary  = Color(0xFF6B6B6B);
  static const divider        = Color(0xFFE5E3DF);
  static const whatsapp       = Color(0xFF25D366);
  static const destructive    = Color(0xFFD94F4F);
  static const success        = Color(0xFF2E7D32);
  static const warning        = Color(0xFFB45309);

  // Dark Mode
  static const darkBackground    = Color(0xFF141414);
  static const darkSurface       = Color(0xFF1F1F1F);
  static const darkPrimary       = Color(0xFF4A7FD4);
  static const darkPrimaryTint   = Color(0xFF1E2D45);
  static const darkTextPrimary   = Color(0xFFF0EFED);
  static const darkTextSecondary = Color(0xFF9B9B9B);
  static const darkDivider       = Color(0xFF2C2C2C);
}
```

```dart
// lib/core/theme/app_text_styles.dart

class AppTextStyles {
  static const displayLarge = TextStyle(
    fontFamily: 'Caveat',
    fontSize: 36, fontWeight: FontWeight.w700, height: 1.2,
  );
  static const displayMedium = TextStyle(
    fontFamily: 'Caveat',
    fontSize: 28, fontWeight: FontWeight.w700, height: 1.3,
  );
  static const displaySmall = TextStyle(
    fontFamily: 'Caveat',
    fontSize: 22, fontWeight: FontWeight.w600, height: 1.4,
  );
  static const headlineMedium = TextStyle(
    fontFamily: 'DM Sans',
    fontSize: 20, fontWeight: FontWeight.w600, height: 1.4,
  );
  static const bodyLarge = TextStyle(
    fontFamily: 'DM Sans',
    fontSize: 16, fontWeight: FontWeight.w400, height: 1.5,
  );
  static const bodyMedium = TextStyle(
    fontFamily: 'DM Sans',
    fontSize: 14, fontWeight: FontWeight.w400, height: 1.6,
  );
  static const labelLarge = TextStyle(
    fontFamily: 'DM Sans',
    fontSize: 14, fontWeight: FontWeight.w500, height: 1.4,
  );
}
```

```dart
// lib/core/theme/app_decorations.dart

class AppDecorations {
  static BoxDecoration card = BoxDecoration(
    color: AppColors.surface,
    borderRadius: BorderRadius.circular(8),
    border: Border.all(color: AppColors.divider, width: 1),
    boxShadow: [
      BoxShadow(
        color: Color(0x1A1A1A1A),
        offset: Offset(3, 3),
        blurRadius: 0,
      ),
    ],
  );

  static BoxDecoration input = BoxDecoration(
    color: AppColors.surface,
    borderRadius: BorderRadius.circular(8),
    border: Border.all(color: AppColors.divider, width: 1),
  );
}
```

---

*End of Platform Design System v1.0*
