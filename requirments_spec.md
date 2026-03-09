# Platform — Product Requirements Specification

**Version:** 1.0
**Last Updated:** March 2026

---

## Table of Contents

1. App Overview
2. Tech Stack
3. Authentication
4. Location
5. User Profile
6. My Space (Item Management)
7. Item Creation & Editing
8. Listing Lifecycle
9. Home Feed & Browsing
10. Item Detail Page
11. Seller Public Profile
12. Contact Seller (WhatsApp)
13. Saved / Bookmarks
14. Reporting
15. Notifications
16. Navigation
17. Onboarding
18. UI & Design System
19. Data Models (Firestore)
20. Error & Edge Case Handling

---

## 1. App Overview

**Platform** is a mobile marketplace app where anyone can list and buy used items. It connects buyers and sellers directly — no in-app payments, no delivery. All transactions happen offline between the two parties.

**Core principles:**
- Minimalist and fast — users can create a listing in under one minute
- Everyone must be logged in to use the app
- No payment processing, no delivery coordination
- English only, currency in Nigerian Naira (₦)

---

## 2. Tech Stack

| Layer | Technology |
|---|---|
| Mobile App | Flutter |
| Authentication | Firebase Authentication |
| Database | Cloud Firestore |
| File Storage | Firebase Storage |
| Push Notifications | Firebase Cloud Messaging (FCM) |
| Deep Linking | Firebase Dynamic Links + share_plus |

---

## 3. Authentication

### 3.1 Login Methods
- **Google Sign-In** — uses Google OAuth
- **Email + Password** — standard Firebase email/password auth

### 3.2 Display Name
- Auto-generated from email on signup: `abdulrahman@gmail.com` → `abdulrahman`
- If Google login: uses Google display name
- Editable by user at any time from Profile

### 3.3 Password Reset
- Standard Firebase email reset link
- Accessible from the login screen

### 3.4 Account Deletion
- User can delete their account from Profile
- Confirmation dialog shown before deletion
- On deletion: account removed AND all items in their space (listed, unlisted) are permanently deleted
- Sold history items are also deleted
- Firebase Auth record removed

### 3.5 Session
- User stays logged in unless they explicitly log out
- No anonymous browsing — app requires login to access any screen

---

## 4. Location

### 4.1 Permission Request
- Location permission is requested on **first launch after login**
- Uses device GPS to derive: city, area, latitude, longitude

### 4.2 If Permission Denied or Disabled
- App still functions — user can browse and use all features
- A persistent warning banner is shown: *"Location disabled — results may be inaccurate"*
- Location is **required** when listing an item — if location is unavailable at listing time, user is prompted to enable it

### 4.3 Location Data
- Location is device-detected only — no manual city entry
- App captures last known location
- Location is stored on the user profile and attached to each listing
- City is used as the default feed filter

---

## 5. User Profile

### 5.1 Profile Fields

| Field | Editable | Notes |
|---|---|---|
| Display name | Yes | Auto-generated, user can change |
| Email | No | Read only |
| WhatsApp number | Yes | Required before first listing |
| Profile photo | Yes | Initials avatar by default, user can upload |
| City | No | Auto-derived from location |
| Member since | No | Auto-set on signup |
| Active listings count | No | Auto-calculated, links to My Space |

### 5.2 Profile Photo
- Default: coloured circle with user's initials
- User can upload a photo from their device
- Stored in Firebase Storage

### 5.3 WhatsApp Number
- Not required at signup
- Collected the first time a user tries to **list** an item (not create)
- Saved to user profile after first entry
- Editable any time from Profile
- Used as the contact number for all their listings

### 5.4 About Section
- App version number
- Contact/support link
- Terms of Service
- Privacy Policy

### 5.5 Other Profile Actions
- Edit display name
- Upload/change profile photo
- Change WhatsApp number
- Toggle dark/light mode
- Log out
- Delete account

---

## 6. My Space

My Space is the user's personal item management area. It is accessible from the bottom navigation bar.

### 6.1 Sections

| Section | Description |
|---|---|
| **Listed** | Items currently live on the public feed |
| **Unlisted** | Items created but not published, or manually unlisted, or expired |
| **Sold** | Permanent history of sold items |

### 6.2 Space Limits

- **Space cap:** Maximum 20 items across Listed + Unlisted combined
- Sold items do **not** count toward the cap — they are a separate history log
- **Listing cap:** Maximum 7 items in Listed status at one time
- Both counters are visible in My Space:
  - Space counter: e.g. *"12/20 items in space"*
  - Listing counter: e.g. *"5/7 listed"*

### 6.3 Hitting the Space Cap
- User is blocked from creating new items
- Clear message shown: *"You've reached your 20-item limit. Delete an item to make space."*
- User must delete an item from Listed or Unlisted to free a slot

### 6.4 Hitting the Listing Cap
- User is blocked from listing an additional item
- Clear message shown: *"You've reached your 7 listing limit. Unlist or sell an item to list another."*

### 6.5 Item Card in My Space
Each item card shows:
- Main image (thumbnail)
- Title
- Price
- Current status (Listed / Unlisted / Sold)
- Expiry countdown for Listed items (e.g. *"Expires in 12 days"*)

### 6.6 Actions Per Item

| Action | Listed | Unlisted | Sold |
|---|---|---|---|
| Edit | Yes (title locked) | Yes | No |
| List | — | Yes | — |
| Unlist | Yes | — | — |
| Renew (extend 20 days) | Yes | — | — |
| Mark as Sold | Yes | Yes | — |
| Relist (move back to Unlisted) | — | — | Yes (as template) |
| Delete | Yes | Yes | Yes |

### 6.7 Sold as Template
- Tapping "Relist" on a sold item opens the Create Item form pre-filled with that item's details
- This creates a **new editable item template** in Unlisted — the original sold record is preserved

### 6.8 Delete Confirmation
- All deletions require a confirmation dialog: *"Delete this item? This cannot be undone."*

### 6.9 Floating Button
- A prominent **+ Create Item** floating action button is visible in My Space

---

## 7. Item Creation & Editing

### 7.1 Creating an Item
- Accessed via the **+ Create Item** button (bottom nav center or My Space FAB)
- Creating an item saves it to **Unlisted** in My Space — it is not live on the feed until the user chooses to list it
- If user navigates away mid-creation, a confirmation dialog warns of unsaved changes — if confirmed, changes are discarded (no auto-save)

### 7.2 Item Fields

| Field | Required | Constraints |
|---|---|---|
| Photos | Yes | Min 1, max 5 images. Max 2MB per image. First image = cover/thumbnail |
| Title | Yes | Max 80 characters. Locked after creation — cannot be edited |
| Price | Yes | Any amount including ₦0 (free). Naira only |
| Price Negotiable | No | Toggle. Display: *"₦50,000 (Negotiable)"* |
| Category | Yes | See categories below |
| Condition | Yes | See condition options below |
| Description | No | Max 400 characters |
| Receipt Image | No | Optional single image |
| Location | Auto | Derived from device — cannot be manually set |
| WhatsApp Contact | Required to list | Pre-filled from profile if available |

### 7.3 Categories
- Phones & Tablets
- Books & Textbooks
- Bags & Accessories
- Gadgets & Electronics
- Clothing
- Home & Furniture
- Other

### 7.4 Condition Options
- Still New
- Fairly Used
- Old
- Fairly Old
- Needs Repair

### 7.5 Image Handling
- Minimum 1 image required to save/create the item
- Maximum 5 images
- First image is the cover photo shown in feed cards and at the top of the detail page
- Seller can reorder images after uploading (drag to reorder)
- Images stored in Firebase Storage

### 7.6 Editing an Item
- All fields are editable **except the title**, which is locked after creation
- Editing a listed item keeps it live — no re-approval needed
- Edited items show an **"Edited [date & time]"** label visible to buyers on the detail page
- `edited: true` and `updated_at` stored in Firestore

### 7.7 Listing an Item
- From Unlisted in My Space, user taps "List"
- If no WhatsApp number is saved: user is prompted to add one before proceeding
- If listing cap (7) is reached: blocked with a clear message
- On successful listing: item moves to Listed, `status = active`, `expires_at = now + 20 days`

---

## 8. Listing Lifecycle

### 8.1 Status Types
Items have three possible statuses:

| Status | Visible on Feed | Description |
|---|---|---|
| `active` (Listed) | Yes | Publicly visible, within expiry window |
| `unlisted` | No | In seller's space but not published |
| `sold` | No | Marked as sold, permanent history |

### 8.2 Expiry
- All listed items expire **20 days** after being listed: `expires_at = created_at + 20 days`
- Expired items are **silently hidden** from the public feed — no visible expiry info shown to buyers
- Buyers only see the **posted date** on item detail
- When a listing expires, it automatically moves to **Unlisted** in My Space
- Seller receives a push notification **3 days before** expiry

### 8.3 Renewal
- Seller can renew a listed item — extends expiry by 20 days from the renewal date
- Renewal is available from My Space

---

## 9. Home Feed & Browsing

### 9.1 Feed Rules
- Only shows items where `status = active` AND `expires_at > now`
- Seller's own items are hidden from their own feed
- Sorted: same-city items first (newest first within group), then all other items (newest first)

### 9.2 Default Filter
- Feed defaults to user's city on open
- City filter is easily clearable to show all listings nationwide

### 9.3 Filters Available
- **Category** — filter by any single category
- **City** — filter by city

### 9.4 Search
- Search bar at the top of the Home screen
- Searches across: title and description
- Real-time or on-submit search (implementation decision)

### 9.5 Feed Layout
- Toggle between two layouts:
  - **Grid view** — 2 columns
  - **List view** — 1 column, larger cards

### 9.6 Item Card (Grid)
- Main image
- Title
- Price (+ Negotiable tag if applicable)
- Condition
- Area
- Popular badge (if applicable)

### 9.7 Popular Badge
- Shown on listings that have been saved by **10 or more** users
- Displayed as a small badge/label on the item card

### 9.8 Pagination
- 20 items loaded per batch
- Infinite scroll — next batch loads as user approaches the bottom

### 9.9 Loading State
- Skeleton screens shown while feed loads (not a spinner)

### 9.10 Empty States
- If search or filters return no results: a well-designed illustrated empty state screen is shown
- Empty states are shown throughout the app wherever applicable (e.g. empty Saved, empty My Space)

---

## 10. Item Detail Page

### 10.1 Sections
1. **Image gallery** — swipeable, up to 5 images
2. **Item information** — title, price, negotiable tag, condition, category, location (area, city), posted date, edited timestamp (if applicable)
3. **Description** — shown if provided
4. **Receipt image** — shown if provided
5. **Seller information** — seller name, city, member since, listing count
6. **Actions** — Contact on WhatsApp, Save/Unsave, Share, Report

### 10.2 Edited Label
- If item has been edited: shows *"Edited [date & time]"* below the posted date

### 10.3 Seller Info Block
- Seller name (tappable — links to seller's public profile)
- City
- Member since
- Number of active listings
- "View Other Listings" button — links to seller's public profile

### 10.4 Actions
- **Contact on WhatsApp** — primary CTA button
- **Save / Unsave** — bookmark toggle (hidden if viewing own listing)
- **Share** — share deep link via system share sheet
- **Report** — report the listing (hidden if viewing own listing)

### 10.5 Sold Item View
- If buyer opens a listing that has been marked as sold: shows a *"This item has been sold"* message
- The item detail is still visible but the WhatsApp button is replaced with the sold message

### 10.6 Unavailable Item View
- If a deep link leads to a deleted or unlisted item: shows a *"This listing is no longer available"* page with a button to return to the feed

---

## 11. Seller Public Profile

Accessible by tapping a seller's name on any item detail page.

### 11.1 Contents
- Profile photo (or initials avatar)
- Display name
- City
- Member since
- Number of active listings (with a link to view all)
- Active listings are not shown inline — just the count and a "View Listings" button which opens a filtered feed of that seller's active items

---

## 12. Contact Seller (WhatsApp)

### 12.1 Flow
- Buyer taps "Contact on WhatsApp" on item detail page
- App opens WhatsApp with a prefilled message
- Assumes buyer has WhatsApp installed

### 12.2 Prefilled Message Format
```
Hi, I saw your listing for "{title}". Item ID: {item_id}. Is it still available?
```

### 12.3 Link Format
```
https://wa.me/{phone_number}?text={encoded_message}
```

---

## 13. Saved / Bookmarks

### 13.1 Access
- Accessible via **Saved** tab in bottom navigation
- Also toggled directly from item detail page

### 13.2 Behaviour
- Save is instant on tap — no undo window
- Users cannot save their own listings (save button hidden on own listings)
- If a saved listing is unlisted by the seller: buyer receives a push notification and the item is removed from their Saved list

### 13.3 Saved Tab
- Shows all currently bookmarked active listings
- If a saved item is sold or deleted, it is removed from the list automatically
- Empty state shown if no saved items

---

## 14. Reporting

### 14.1 Access
- Report button on item detail page
- Hidden on user's own listings — cannot report yourself

### 14.2 One Report Per User Per Listing
- A user can only report a listing once
- After reporting, the button is replaced with *"Reported"*

### 14.3 Report Form
- **Reason** (required, single select):
  - Scam
  - Fake item
  - Prohibited item
  - Spam
  - Other
- **Additional details** (optional, free text)

### 14.4 Storage
Reports stored in Firestore under `reports/{report_id}`:
- `item_id`
- `reporter_id`
- `reason`
- `details` (optional)
- `created_at`

No admin moderation panel in v1 — reports are stored for future review.

---

## 15. Notifications

All notifications delivered via **Firebase Cloud Messaging (FCM)**.

| Trigger | Recipient | Tap Action |
|---|---|---|
| Listing expires in 3 days | Seller | Opens listing detail in My Space |
| Someone saved your listing | Seller | Opens listing detail in My Space |
| A saved listing has been unlisted | Buyer | Opens item detail page (unavailable state) |

---

## 16. Navigation

### 16.1 Bottom Navigation Bar (5 tabs)

| Tab | Icon | Description |
|---|---|---|
| Home | House | Main browse feed |
| Saved | Bookmark | Bookmarked listings |
| Create Item | + (prominent, center) | Opens item creation form |
| My Space | Grid/box | User's item management area |
| Profile | Person | User settings and profile |

### 16.2 Notes
- Create Item tab is the center tab, visually prominent (e.g. elevated or filled button style)
- All tabs require login — no unauthenticated access

---

## 17. Onboarding

- Shown **once** on first login — never shown again
- 2–3 screens introducing the app's core concept
- Suggested screens:
  1. *"Welcome to Platform — Buy and sell used items easily"*
  2. *"List your items in under a minute"*
  3. *"Connect with sellers directly on WhatsApp"*
- Skip button available on all onboarding screens
- After onboarding: location permission is requested, then user lands on Home feed

---

## 18. UI & Design System

### 18.1 Theme
- Supports **light mode** and **dark mode**
- Toggle available in Profile
- Follows system default on first launch

### 18.2 Loading States
- **Skeleton screens** used throughout the app (feed, item detail, My Space, Saved)
- No generic spinners for primary content loading

### 18.3 Empty States
- Custom illustrated empty state screens for:
  - Empty home feed (no results / no listings in city)
  - Empty search results
  - Empty Saved tab
  - Empty My Space sections (Listed, Unlisted, Sold)

### 18.4 Language & Currency
- English only
- Nigerian Naira (₦) only — no currency selector

### 18.5 Image Upload UX
- Images are reorderable after upload (drag to reorder)
- First image is always the cover
- Max 2MB per image — show a clear error if exceeded

---

## 19. Data Models (Firestore)

### 19.1 Users — `users/{user_id}`

| Field | Type | Notes |
|---|---|---|
| `email` | string | |
| `display_name` | string | Editable |
| `whatsapp_contact` | string | Optional until first listing |
| `photo_url` | string | Firebase Storage URL |
| `city` | string | Auto-derived |
| `area` | string | Auto-derived |
| `latitude` | number | |
| `longitude` | number | |
| `member_since` | timestamp | |
| `listing_count` | number | Active listings only |
| `space_count` | number | Listed + Unlisted |
| `fcm_token` | string | For push notifications |

### 19.2 Items — `items/{item_id}`

| Field | Type | Notes |
|---|---|---|
| `title` | string | Max 80 chars. Locked after creation |
| `price` | number | ₦, min 0 |
| `price_negotiable` | boolean | |
| `category` | string | |
| `condition` | string | |
| `description` | string | Optional, max 400 chars |
| `image_urls` | array | Ordered — first is cover |
| `receipt_image_url` | string | Optional |
| `status` | string | `active`, `unlisted`, `sold` |
| `seller_id` | string | |
| `seller_name` | string | Denormalized |
| `whatsapp_contact` | string | Seller's WhatsApp at time of listing |
| `city` | string | |
| `area` | string | |
| `latitude` | number | |
| `longitude` | number | |
| `save_count` | number | Total saves |
| `is_popular` | boolean | True when save_count >= 10 |
| `edited` | boolean | |
| `created_at` | timestamp | |
| `updated_at` | timestamp | |
| `listed_at` | timestamp | When first listed or relisted |
| `expires_at` | timestamp | listed_at + 20 days |

### 19.3 Reports — `reports/{report_id}`

| Field | Type |
|---|---|
| `item_id` | string |
| `reporter_id` | string |
| `reason` | string |
| `details` | string (optional) |
| `created_at` | timestamp |

### 19.4 Saved Items — `users/{user_id}/saved/{item_id}`

| Field | Type |
|---|---|
| `item_id` | string |
| `saved_at` | timestamp |

---

## 20. Error & Edge Case Handling

| Scenario | Behaviour |
|---|---|
| Buyer opens a sold listing | Shows "This item has been sold" message |
| Deep link to deleted or unlisted item | Shows "This listing is no longer available" page with a back-to-feed button |
| User hits 20-item space cap | Blocked from creating — clear message shown |
| User hits 7-listing cap | Blocked from listing — clear message shown |
| User tries to list without WhatsApp number | Prompted to add WhatsApp number before proceeding |
| User tries to save their own listing | Save button hidden |
| User tries to report their own listing | Report button hidden |
| User tries to report the same listing twice | Blocked — button replaced with "Reported" |
| Image exceeds 2MB | Clear error message on upload |
| No images uploaded on item creation | Cannot save item — at least 1 image required |
| Location denied | App works with warning banner; listing requires location re-enable |
| User navigates away mid-creation | Confirmation dialog — discard or stay |
| No internet connection | Standard Flutter connectivity error handling |

---

*End of Platform Requirements Specification v1.0*
