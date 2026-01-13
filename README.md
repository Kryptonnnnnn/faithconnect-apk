# FaithConnect 📱

FaithConnect is a Flutter mobile app that helps **Worshipers** connect with their **Religious Leaders** through posts, short video reels, and private messaging.

This repo contains the submission build for the hackathon.

---

## 🌟 Core Features

### 👤 Worshiper Flow

- **Sign up / Login** as Worshiper
- **Explore Leaders**: browse a list of religious leaders
- **Follow Leaders**: follow / unfollow leaders
- **Feed Tabs**:
  - **Explore** – see posts from all leaders
  - **Following** – see posts only from leaders you follow
  - **Reels** – vertical, swipeable short‑video reels
- **Engagement on Posts**:
  - Like / Unlike
  - Comment (bottom sheet with real‑time Firestore comments)
  - Save / Unsave (bookmarks)
  - Share (placeholder snackbar)
- **Messaging**:
  - Open a leader’s profile and tap **Message** to start a chat
  - Real‑time messaging via Firestore

### ✝️ Leader Flow

- **Sign up / Login** as Religious Leader
- **Leader Dashboard**:
  - Create text **Posts**
  - Create short **Reels** (video)
- **Content Creation**:
  - Posts stored in `posts` collection (Firestore)
  - Reels stored in `reels` collection  
    - For hackathon demo, reels use a **public sample MP4 URL** (no Firebase Storage billing)
- **Messaging**:
  - Leaders can view all conversations in the **Messages** screen
  - Reply to worshipers in real time

---

## 🧱 Tech Stack

- **Framework**: Flutter
- **Language**: Dart
- **Backend**: Firebase
  - `firebase_auth` – user authentication
  - `cloud_firestore` – users, posts, follows, chats, reels, likes, comments, saved items
  - (Optional) `firebase_storage` – not required for this build; reels use a sample video URL
- **Media**:
  - `video_player` – play vertical reels
  - `image_picker` – pick video from gallery for reel creation (file is ignored in demo; URL is mocked)

---

## 📂 Main Collections (Firestore)

- **`users`**
  - `uid`, `name`, `email`, `role` (`worshiper` / `leader`), `faith`, `bio`, `photoUrl`, `createdAt`
- **`posts`**
  - `title`, `content`, `leaderId`, `createdAt`, `likesCount`
- **`follows`**
  - `worshiperId`, `leaderId`, `createdAt`
- **`chats`**
  - Chat documents with participants and subcollection `messages`
- **`reels`**
  - `videoUrl` (public sample MP4), `caption`, `leaderId`, `createdAt`, `likesCount`
- **Engagement Collections**
  - `postLikes` – per‑user likes on posts
  - `savedPosts` – bookmarks for posts
  - `reelLikes` – per‑user likes on reels
  - `savedReels` – bookmarks for reels
  - `posts/{postId}/comments` – comments on posts
  - `reels/{reelId}/comments` – comments on reels

---

## 📥 APK (Android Build)

A release APK has been generated using:

```bash
flutter build apk --release
```

Output path:

```text
build/app/outputs/flutter-apk/app-release.apk
```

This APK is attached in the hackathon submission.  
You can also rebuild it locally with the command above.

---

## 🚀 Running the App Locally

### 1. Prerequisites

- Flutter SDK (3.10.x or compatible)
- Android Studio or Xcode (for emulators)
- Firebase project set up with:
  - Authentication (Email/Password)
  - Cloud Firestore
  - (Optional) Storage – not required for this prototype

### 2. Clone the Repo

```bash
git clone https://github.com/Kryptonnnnnn/faithconnect-apk.git
cd faithconnect-apk
```

### 3. Install Dependencies

```bash
flutter pub get
```

### 4. Firebase Configuration

Add your own Firebase config files (these are **not** committed to git):

- Android: `android/app/google-services.json`
- iOS: `ios/Runner/GoogleService-Info.plist` (if you run on iOS)

Then, ensure `main.dart` initializes Firebase with your `firebase_options.dart`.

### 5. Run on Emulator / Device

```bash
flutter run
```

---

## 🧪 How to Test the Flows

### A. As a Leader

1. Sign up and choose **Religious Leader** role.
2. On the dashboard:
   - Create 1–2 text **Posts**.
   - Create a **Reel** (any local video is accepted; backend uses a sample MP4 URL).
3. Open **Messages** – conversations appear once worshipers message you.

### B. As a Worshiper

1. Sign up with **Worshiper** role.
2. On the home screen:
   - Tap the **group icon** to explore leaders and follow them.
   - Tap the **star icon** to see “My Leaders”.
3. Use home tabs:
   - **Explore** – see all leaders’ posts, like/comment/save/share.
   - **Following** – only posts from leaders you follow.
   - **Reels** – vertical video feed with like/comment/save/share.
4. Tap a leader to open **Leader Profile**:
   - View their posts & reels list.
   - Tap **Message** to chat.

---

## ⚠️ Notes / Limitations

- **Reels Storage**: For hackathon / free tier, reels use a **public sample video URL** instead of uploading to Firebase Storage, to avoid billing.
- **Share Buttons**: Currently implemented as a simple snackbar (“Share is not implemented in this demo.”) so no extra packages are required.
- **Security Rules**: For demo, permissive Firestore rules are used (`request.auth != null`). These should be tightened for production.

---

## 🧑‍💻 Development

### Tech Versions (at submission time)

- Flutter: `3.10.x`
- Dart: `^3.10.7`
- firebase_core: `^2.27.0`
- firebase_auth: `^4.17.0`
- cloud_firestore: `^4.15.0`
- firebase_storage: `^11.7.0`
- video_player: `^2.8.2`
- image_picker: `^1.0.7`

---

## 🙏 Credits

- Built by: **[Nikhil]** (`@Kryptonnnnnn` on GitHub)  
- Submission for: **[Hackathon / AI x Faith / etc.]**

Feel free to open issues or suggestions in the GitHub repo.
