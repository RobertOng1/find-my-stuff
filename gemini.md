# Project Context: FindMyStuff - Smart Lost & Found Assistant

## 1. Project Overview
**FindMyStuff** is a premium community-based mobile application developed in **Flutter** backed by **Firebase**. It helps users report lost items and return found items through a gamified, trustworthy platform.

* **Core Concept:** A mix of a utility feed (Lost & Found) and a gamified claim system (Points, Badges, Verification).
* **Target UX:** Elegant, Full-Screen (Immersive), and Responsive.
* **Platforms:** iOS & Android.

## 2. Tech Stack & Architecture

### Backend (Firebase)
* **Auth:** `firebase_auth`, `google_sign_in` (Google & Email/Pass).
* **Database:** `cloud_firestore` (NoSQL).
* **Storage:** `firebase_storage` (For item photos & user avatars).
* **Functions (Optional):** For push notifications.

### Frontend (Flutter)
* **State Management:** Provider / Riverpod / Bloc (Choose one).
* **Animations:** `flutter_animate` (Crucial for Splash & Rewards).
* **Maps/Location:** `geolocator`, `geocoding`.
* **Utilities:** `image_picker`, `permission_handler`, `intl`.

---

## 3. Design System & Assets

### Color Palette
* **Primary Blue:** `#2D9CDB` (Brand Color).
* **Deep Navy:** `#0E3F6C` (Buttons, Headers - Premium feel).
* **Accent Gold:** `#C5A059` (For Logo, Badges, Trophies, Highlighting).
* **Background White:** `#FFFFFF`.
* **Input Grey:** `#F5F6FA`.
* **Success Green:** `#27AE60`.
* **Error Red:** `#EB5757`.

### Typography
* **Font Family:** *Poppins* or *Inter*.
* **Styles:** Clean, readable, with bold headlines for impact.

### Global Layout Rules (CRITICAL)
* **Full Screen (Immersive):** All screens with background graphics (Login, Profile, Rewards) must use a `Stack` structure.
    * Background elements must use `Positioned(bottom: 0, left: 0, right: 0)` to eliminate whitespace on tall devices.
* **Safe Areas:** Content must be wrapped in `SafeArea` to avoid system overlaps.

---

## 4. Firestore Database Schema

### `users` Collection
* `uid` (String)
* `displayName`, `email`, `photoUrl`
* `trustScore` (int): E.g., 4.8
* `points` (int): Total gamification points.
* `badges` (List<String>): IDs of earned badges (e.g., ['golden_hand', 'pillar_trust']).
* `itemsReturned` (int).

### `posts` Collection (Lost/Found Items)
* `id` (String)
* `userId` (String)
* `type` (String): "LOST" or "FOUND"
* `title`, `description`, `category` (Electronics, Keys, etc.)
* `imageUrls` (List<String>)
* `location` (Map): {lat, lng, address}
* `status` (String): "OPEN", "PENDING_CLAIM", "RESOLVED"
* `createdAt` (Timestamp)

### `claims` Collection (The Verification Logic)
* `id` (String)
* `postId` (String)
* `claimantId` (String)
* `proofDescription` (String)
* `proofImages` (List<String>)
* `status` (String): "PENDING", "VERIFIED", "REJECTED", "ACCEPTED"
* `chatId` (String): Link to a chat room between Finder and Claimant.

---

## 5. Screen Modules & Implementation Details

### A. Splash & Onboarding
* **Splash Screen:**
    * **Asset:** Gold Logo (`logo.jpg`).
    * **Animation:** Use `flutter_animate`. Logo scales up + "Shimmer" effect on gold + Fade in "FindMyStuff".
    * **Logic:** Check Auth -> Navigate to Home or Login.

### B. Authentication (Ref: `Login Page - Claudio.png`)
* **Login & Register:**
    * **Structure:** `Scaffold` > `Stack`.
    * **Decorations:** Wave shapes at Top and Bottom (Pinned to `bottom: 0`).
    * **Form:** Email, Password, Social Login (Google).
    * **Logic:** Create Firestore User document upon registration.

### C. Dashboard / Discovery (Ref: `Dashboard - Robert.png`)
* **Home Screen:**
    * **Header:** Search Bar + Category Chips (Electronics, Wallet, etc.).
    * **Body:** `StreamBuilder` fetching `posts`.
    * **Card Design:** Image, Title, Location, "Chat" or "Claim" button.
* **Add Report Screen:**
    * Form to upload Image, Title, Description, and Auto-detect Location.

### D. Claim & Communication Flow (The Core Feature)
* **1. Chat Interface:**
    * Standard chat bubble UI.
    * **System Bubble:** "Please submit proof of ownership" (Button triggers `ProofForm`).
* **2. Proof Form:**
    * Inputs: Date Lost, Where, Distinguishing Features.
    * Action: "Submit Claim" (Creates document in `claims` collection).
* **3. Verify Claimant (Finder's View):**
    * **UI:** Shows Claimant's Profile (Trust Score, Badges) vs. Item Details.
    * **Actions:** "Reject" (Red) or "Accept Claim" (Blue).
* **4. Reward Screen (Gamification):**
    * **Trigger:** When a claim is successfully closed/accepted.
    * **UI:** **Full Screen Page** (Not Dialog).
    * **Content:** Trophy Icon, "Great Job!", Points calculation (+50 Base, +15 Speed), "Back to Home".

### E. Profile & Settings (Ref: `Profile.png`)
* **Main View:**
    * **Header:** `Stack` with Blue Curve background. Avatar centered.
    * **Stats:** Grid/Row showing Points, Items Returned.
    * **Badges:** Horizontal scroll of earned badges.
    * **Menu:** Edit Profile, Change Password, Logout.
* **Edit Pages:** Simple forms for updating user data.

---

## 6. Execution Instructions for AI Agent
1.  **Analyze Context:** Always check if a relevant image exists for the screen you are building.
2.  **Structure First:** Setup the folder structure (`features/auth`, `features/home`, `core/services`).
3.  **UI Integrity:** Adhere strictly to the **Full Screen/Stack** guidelines. No bottom whitespace allowed on background screens.
4.  **Backend Integration:** Connect UI actions directly to the Firestore Services defined in Section 4.

---

## 7. Pain Points & Resolutions (Lessons Learned)
* **Layout Consistency:** Authentication screens had whitespace issues due to improper `Stack` usage.
    * *Resolution:* Enforced `StackFit.expand` and `Positioned.fill` for all full-screen backgrounds.
* **UX Flow:** Critical flows like "Reward" were buried in dialogs, reducing impact.
    * *Resolution:* Promoted "Reward" and "Success" states to dedicated full-screen widgets.
* **Information Density:** Verification screens lacked sufficient context for decision making.
    * *Resolution:* Added detailed "Claim Details" comparison cards and "Proof Photos" grids.
* **Navigation Gaps:** Placeholder buttons (Edit Profile, Change Password) frustrated testing.
    * *Resolution:* Wired up all profile and claim flow actions to functional screens.
* **Missing Features:** Home screen lacked filtering, and forms lacked validation.
    * *Resolution:* Implemented `ChoiceChip` filters and input validation logic.