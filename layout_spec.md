# Platform — Screen Layout Specification

**Version:** 1.0

---

## Table of Contents

1. [Splash Screen](#1-splash-screen)
2. [Login / Signup](#2-login--signup)
3. [Onboarding](#3-onboarding)
4. [Home Feed](#4-home-feed)
5. [Item Detail](#5-item-detail)
6. [Seller Public Profile](#6-seller-public-profile)
7. [My Space](#7-my-space)
8. [Item Management Detail](#8-item-management-detail)
9. [Create Item Form](#9-create-item-form)
10. [Edit Item Form](#10-edit-item-form)
11. [Saved Tab](#11-saved-tab)
12. [Profile](#12-profile)
13. [Notifications Screen](#13-notifications-screen)
14. [Report Form](#14-report-form)
15. [Item Unavailable](#15-item-unavailable)
16. [Item Sold State](#16-item-sold-state)

---

## 1. Splash Screen

**Purpose:** Shown for 1–2 seconds while Firebase initialises and checks auth state.

**Layout:**
- Centred logo/icon mark — no text
- Bold solid colour background (primary brand colour)
- Small subtle loading indicator at the very bottom

**Routing:**
- If user is logged in → Home Feed
- If user is not logged in → Login Screen

---

## 2. Login / Signup

**Purpose:** Entry point for new and returning users. Login and signup share the same screen with a toggle.

**Layout (top to bottom):**
- Logo/icon mark — centred, top area
- App name: **"Platform"** — below logo
- **"Continue with Google"** button — full width, prominent
- Divider: *"or"*
- Email input field
- Password input field
- *(Sign up mode only)* Confirm password input field
- Primary button — full width:
  - Login mode: **"Login"**
  - Sign up mode: **"Create Account"**
- **"Forgot password?"** link — small, below primary button, visible in login mode only
- Toggle link at the bottom:
  - Login mode: *"Don't have an account? Sign up"*
  - Sign up mode: *"Already have an account? Login"*

**Notes:**
- No extra fields on signup — display name is auto-generated from email
- Password reset sends a Firebase email reset link
- After successful login/signup → Onboarding (first time) or Home Feed (returning user)

---

## 3. Onboarding

**Purpose:** Shown once after first login to introduce the app. Never shown again.

**Layout:**
- 3 full-screen slides
- Each slide: full-screen illustration, heading, one short line of supporting text
- **Skip** button — top right corner, visible on all slides
- Progress dots — bottom centre
- Last slide replaces auto-advance with a **"Get Started"** button

**Slides:**

| # | Heading | Supporting Text |
|---|---|---|
| 1 | Buy & Sell Used Items | Browse listings near you |
| 2 | List in Under a Minute | Photo, price, done |
| 3 | Connect on WhatsApp | Direct contact, no middleman |

**Behaviour:**
- Slides auto-advance (also manually swipeable)
- After **"Get Started"** → Location permission request → Home Feed

---

## 4. Home Feed

**Purpose:** Main browsing screen. First screen users land on after login.

**Layout (top to bottom):**

```
[ Platform Logo ]          [ 🔔 Bell ]  [ Grid/List Toggle ]
─────────────────────────────────────────────────────────────
[ 🔍 Search bar                                            ]
─────────────────────────────────────────────────────────────
[ All ] [ Phones ] [ Books ] [ Bags ] [ Gadgets ] [ More → ]
─────────────────────────────────────────────────────────────
  📍 Showing listings in Lagos  ✕
─────────────────────────────────────────────────────────────
[ Card ]  [ Card ]
[ Card ]  [ Card ]
[ Card ]  [ Card ]
       ↓ infinite scroll
─────────────────────────────────────────────────────────────
[ Home ] [ Saved ] [ ⊕ ] [ My Space ] [ Profile ]
```

**Default state:** Grid view (2 columns), filtered to user's city.

**Grid Item Card:**
- Square image (with Popular badge overlay if applicable)
- Title
- Price (+ *"Negotiable"* tag if applicable)
- Condition pill
- Area

**List Item Card:**
- Image on the left (fixed size)
- Title, price, condition pill, area on the right
- More spacious than grid card

**City Filter Strip:**
- Shows: *"Showing listings in [City] ✕"*
- Tapping ✕ clears city filter and shows all nationwide listings

**Category Filter Chips:**
- Horizontally scrollable
- Options: All, Phones & Tablets, Books & Textbooks, Bags & Accessories, Gadgets & Electronics, Clothing, Home & Furniture, Other

**Loading State:** Skeleton screens (no spinner)

**Empty State:** Custom illustrated screen when no results match filters or search

---

## 5. Item Detail

**Purpose:** Full information view of a listing for buyers.

**Layout (scrollable):**

```
[ ← Back ]                        [ Share ]  [ Report ]
─────────────────────────────────────────────────────────
[ ←   Full-width image gallery (swipeable)   → ]
                    • • • • (page dots)
─────────────────────────────────────────────────────────
  ₦120,000  (Negotiable)
  iPhone 11
─────────────────────────────────────────────────────────
  [ Fairly Used ]  Phones & Tablets  📍 Yaba, Lagos
  Posted 3 days ago  ·  Edited 1 day ago
─────────────────────────────────────────────────────────
  Description
  Lorem ipsum... (collapsed if long)
                              [ Read more ]
─────────────────────────────────────────────────────────
  📄 Receipt image (thumbnail, tappable to expand)
─────────────────────────────────────────────────────────
  [ Avatar ]  Abdul Rahman
              Lagos  ·  Member since Jan 2024
              12 active listings
              [ View Other Listings → ]
─────────────────────────────────────────────────────────
  Report this listing
═════════════════════════════════════════════════════════
[ 🔖 Save ]  [ Contact on WhatsApp          (green)    ]
```

**Sticky Bottom Bar:**
- Save icon button (left) — toggles saved/unsaved state
- "Contact on WhatsApp" button (right, green, fills remaining width)
- Both hidden/replaced if item is sold (see Screen 16)

**Notes:**
- Save button hidden on user's own listings
- Report link hidden on user's own listings
- Seller name is tappable — opens Seller Public Profile bottom sheet

---

## 6. Seller Public Profile

**Purpose:** Quick view of a seller's public info. Accessed by tapping seller name on item detail.

**Presentation:** Bottom sheet sliding up over the item detail page.

**Layout:**

```
        ─────── (drag handle)
[ ← ]   Abdul Rahman

  [ Avatar / Initials ]
  Abdul Rahman
  Lagos  ·  Member since January 2024

  12 active listings

[ View Listings                              ]

```

**Notes:**
- Drag handle at the top for dismissal
- "View Listings" opens a separate screen — a filtered feed of that seller's active items (same card layout as home feed, no bottom nav)

---

## 7. My Space

**Purpose:** Seller's personal item management area.

**Layout:**

```
[ My Space ]                [ 12/20 ]  [ Grid/List Toggle ]
─────────────────────────────────────────────────────────────
  5/7 listed
─────────────────────────────────────────────────────────────
[ Listed ]    [ Unlisted ]    [ Sold ]
─────────────────────────────────────────────────────────────
[ Card ]  [ Card ]
[ Card ]  [ Card ]
[ Card ]  [ Card ]
─────────────────────────────────────────────────────────────
[ Home ] [ Saved ] [ ⊕ ] [ My Space ] [ Profile ]
                                          [ + Create Item ]
```

**Item Card (My Space):**
- Image thumbnail
- Title
- Price
- Expiry countdown *(Listed tab only)* e.g. *"Expires in 12 days"*

**Counters:**
- Space counter in app bar: e.g. *"12/20"*
- Listing counter strip: e.g. *"5/7 listed"*

**Floating Button:** `+ Create Item` — bottom right

**Tapping a card** → opens Item Management Detail screen

**Cap Messages:**
- Space cap hit: *"You've reached your 20-item limit. Delete an item to make space."*
- Listing cap hit: *"You've reached your 7 listing limit. Unlist or sell an item to list another."*

---

## 8. Item Management Detail

**Purpose:** Seller's own view of an item with full management actions.

**Layout (scrollable):**

```
[ ← Back ]        iPhone 11
─────────────────────────────────────────────────────────
[ ←   Full-width image gallery (swipeable)   → ]
                    • • • • (page dots)
─────────────────────────────────────────────────────────
  ₦120,000  (Negotiable)
  iPhone 11
─────────────────────────────────────────────────────────
  [ Fairly Used ]  Phones & Tablets  📍 Yaba, Lagos
  Posted 3 days ago  ·  Edited 1 day ago
─────────────────────────────────────────────────────────
  Description (if provided)
─────────────────────────────────────────────────────────
  🟢 Listed — Expires in 12 days
═════════════════════════════════════════════════════════
[          Manage Item          ]
```

**"Manage Item" Bottom Sheet:**

```
        ─────── (drag handle)
  Manage Item

  ✏️  Edit
  👁  Unlist         (or "List" if currently unlisted)
  🔄  Renew          (visible only if Listed)
  ✅  Mark as Sold
  🗑  Delete         (red)
─────────────────────────────
  Cancel
```

**Notes:**
- Delete always shows a confirmation dialog before proceeding
- Sold items in the Sold tab: only "Relist as Template" and "Delete" options shown

---

## 9. Create Item Form

**Purpose:** Form for creating a new item. Saves to Unlisted in My Space — not live until user explicitly lists it.

**Layout (scrollable):**

```
[ ← Back ]        Create Item
─────────────────────────────────────────────────────────
  ┌─────────────────────────────────────┐
  │                                     │
  │   + Add Photos  (1–5, max 2MB each) │
  │                                     │
  └─────────────────────────────────────┘
  [ 📷 ] [ 📷 ] [ 📷 ]  ← thumbnails, drag to reorder

─────────────────────────────────────────────────────────
  Title *
  [ _________________________________ ]  0/80

─────────────────────────────────────────────────────────
  Price *  ₦
  [ _________________________________ ]
  [ ] Negotiable

─────────────────────────────────────────────────────────
  Category *
  [ Select category                 › ]  → sub-screen

─────────────────────────────────────────────────────────
  Condition *
  [ Select condition                › ]  → sub-screen

─────────────────────────────────────────────────────────
  Description  (optional)
  [ _________________________________ ]
  [ _________________________________ ]  0/400

─────────────────────────────────────────────────────────
  Receipt Image  (optional)
  [ + Add Receipt ]

─────────────────────────────────────────────────────────
  📍 Yaba, Lagos  (auto-detected, read only)

═════════════════════════════════════════════════════════
[              Save Item                                 ]
```

**Notes:**
- Save button disabled until: at least 1 image, title, price, category, and condition are filled
- Navigating away mid-form shows a confirmation dialog — discard or stay (no auto-save)
- Category and Condition each open a dedicated sub-screen for selection

**Category Sub-screen:**
- App bar: back arrow, *"Select Category"*
- Full list of categories as selectable rows with radio selection
- Selected item shown with a checkmark

**Condition Sub-screen:**
- App bar: back arrow, *"Select Condition"*
- Full list of conditions as selectable rows with short descriptions
- Selected item shown with a checkmark

---

## 10. Edit Item Form

**Purpose:** Edit an existing item. Identical to Create Item Form with the following differences:

- App bar title: *"Edit Item"*
- All fields pre-filled with existing values
- **Title field is locked** — displayed as read-only with a 🔒 lock icon, cannot be changed
- Save button reads **"Save Changes"**

---

## 11. Saved Tab

**Purpose:** Buyer's bookmarked listings.

**Layout:**

```
[ Saved ]                           [ Grid/List Toggle ]
─────────────────────────────────────────────────────────
  8 saved items
─────────────────────────────────────────────────────────
[ Card ]  [ Card ]
[ Card ]  [ Card ]
[ Card ]  [ Card ]
─────────────────────────────────────────────────────────
[ Home ] [ Saved ] [ ⊕ ] [ My Space ] [ Profile ]
```

**Notes:**
- Same card design as Home Feed
- Default grid view (2 columns), toggleable to list
- Tapping a card opens Item Detail (where unsave happens)
- Items removed automatically if seller unlists or deletes them
- Empty state: illustrated screen — *"No saved items yet"*

---

## 12. Profile

**Purpose:** User settings, personal info, and app preferences.

**Layout (scrollable):**

```
[ Profile ]
─────────────────────────────────────────────────────────
  [ Avatar / Photo ]  (tappable → View / Change / Remove)
  Abdul Rahman
  abdulrahman@gmail.com

  12 active listings  →
─────────────────────────────────────────────────────────
  Settings

  Display Name
  [ Abdul Rahman                     ✏️ ]

  WhatsApp Number
  [ +234 801 234 5678                ✏️ ]

  Appearance
  Dark Mode                     [ Toggle ]

─────────────────────────────────────────────────────────
  About

  App Version          1.0.0
  Contact & Support         →
  Terms of Service          →
  Privacy Policy            →

─────────────────────────────────────────────────────────
  [ Log Out ]

  [ Delete Account ]   ← red, destructive
```

**Notes:**
- Display name and WhatsApp number are inline editable fields
- Tapping avatar shows a bottom sheet: View Photo, Change Photo, Remove Photo
- Active listings count is tappable — navigates to My Space (Listed tab)
- Delete account shows a confirmation dialog before proceeding

---

## 13. Notifications Screen

**Purpose:** In-app inbox for past push notifications.

**Layout:**

```
[ ← Back ]   Notifications        [ Mark all as read ]
─────────────────────────────────────────────────────────
  🔔  Your listing "iPhone 11" expires in 3 days
      2 hours ago                                    •

  👤  Someone saved your listing "MacBook Pro"
      Yesterday

  🔖  "Sony Headphones" you saved was unlisted
      2 days ago
─────────────────────────────────────────────────────────
```

**Notes:**
- Sorted newest first
- Unread indicator: filled dot on the right
- Tapping a notification navigates to the relevant item detail screen
- Bell icon on Home Feed shows an unread badge count
- Empty state: illustrated screen — *"No notifications yet"*

---

## 14. Report Form

**Purpose:** Allow users to report a suspicious or inappropriate listing.

**Presentation:** Bottom sheet sliding up from item detail page.

**Layout:**

```
        ─────── (drag handle)
  Report Listing
  Help us keep Platform safe

  ○  Scam
  ○  Fake item
  ○  Prohibited item
  ○  Spam
  ○  Other

  Additional details  (optional)
  [ _________________________________ ]
  [ _________________________________ ]

[ Submit Report                          ]
─────────────────────────────────────────
             Cancel
```

**Notes:**
- Submit button disabled until a reason is selected
- After submission: report button on item detail replaced with *"Reported"*
- One report per user per listing — cannot report twice

---

## 15. Item Unavailable

**Purpose:** Shown when a user follows a deep link to a listing that has been deleted or unlisted.

**Layout:**

```
─────────────────────────────────────────────────────────

        [ Illustration ]

        This listing is no longer
             available

   The item may have been sold or removed
              by the seller.

      [ Browse Listings ]

─────────────────────────────────────────────────────────
```

**Notes:**
- Full screen, no app bar
- "Browse Listings" button navigates to Home Feed

---

## 16. Item Sold State

**Purpose:** Shown when a buyer opens a listing that has been marked as sold.

**Presentation:** Same Item Detail layout, with the following changes:

- Sticky bottom bar replaced with a sold state banner:

```
═════════════════════════════════════════════════════════
  ✅  This item has been sold
═════════════════════════════════════════════════════════
```

- All other item detail content remains visible (images, description, seller info)
- Save button hidden
- Report link still visible

---

## Screen Flow Summary

```
Splash
  ├── Not logged in → Login / Signup → Onboarding → Location Permission → Home Feed
  └── Logged in → Home Feed

Home Feed
  ├── Tap item card → Item Detail
  │     ├── Tap seller name → Seller Public Profile (bottom sheet)
  │     │     └── Tap "View Listings" → Seller Listings Screen
  │     ├── Tap Save → Saved (toggled)
  │     ├── Tap Share → System share sheet
  │     └── Tap Report → Report Form (bottom sheet)
  ├── Tap bell → Notifications Screen
  └── Search / filter → filtered feed (same screen)

Saved
  └── Tap item → Item Detail

My Space
  ├── Tap item card → Item Management Detail
  │     └── Tap "Manage Item" → Bottom sheet actions
  │           └── Tap Edit → Edit Item Form
  └── Tap + Create Item → Create Item Form
        ├── Tap Category row → Category Sub-screen
        └── Tap Condition row → Condition Sub-screen

Profile
  ├── Tap avatar → Bottom sheet (View / Change / Remove)
  ├── Tap active listings count → My Space (Listed tab)
  └── Tap Delete Account → Confirmation → Account deleted
```

---

*End of Platform Screen Layout Specification v1.0*
