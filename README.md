# RTCI Connect 🌟

The official community mobile application for the **Redeemed Transformation Chapel International (RTCI)**. Built with Flutter, Dart, Firebase, and Riverpod using modern, clean UI/UX standards (such as HSL adaptive styling, Glassmorphism, and smooth animations).

---

## 📱 Features

- **🔐 Auth & Registration**: Firebase Auth integration supporting email/password and Google Sign-in.
- **🏛️ Dashboard**: Comprehensive feed featuring daily insights, recent sermons, and upcoming events.
- **📂 Member Directory & Groups**: Discover, join, and track departments, home cells, and volunteer lists.
- **📊 Service Attendance**: Simple entry UI for logging service headcounts and department registries.
- **💰 Financial Ledger**: Track contributions, revenue, and expenses in real-time.
- **📝 Church Archive Applications**: Step-by-step digital application form to join official ministries.
- **🧒 Children Ministry**: Secure Check-in registry for kids and parents during services.
- **🙏 Prayer Petitions**: Public or private prayer request logging with status tracking (Praying, Answered).
- **📖 Bible & Bible Studies**: Offline/online Bible reading paired with curated study materials.
- **🖼️ Service Gallery**: Image upload and view stream of recent service highlights.
- **👥 Admin Controls**: User account management and role-based permissions (Member, Department Head, Admin).
- **🎨 Obsidian Theme**: Unified adaptive styling supporting dynamic system, light, and dark modes with glassmorphic cards.

---

## 🛠️ Architecture & Tech Stack

This project follows clean architecture principles to ensure robustness, testability, and YAGNI simplicity:

- **State Management**: [Riverpod](https://riverpod.dev) (`flutter_riverpod` + `riverpod_annotation`). Legacy MultiProvider structures have been completely removed for clean dependencies.
- **Backend / Database**: Cloud Firestore, Firebase Auth, and Firebase Storage.
- **UI & Animations**: Custom glassmorphic cards (`GlassCard`), mesh gradients (`MeshGradientBackground`), and micro-animations via `flutter_animate`.
- **Fonts & Styling**: Adaptive colors (`AdaptiveColor`) and typography from Google Fonts (`Inter`, `Cinzel`, `Plus Jakarta Sans`).

---

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (v3.11.4 or higher)
- Dart SDK
- Android SDK / Xcode (for iOS build)

### Installation

1. **Clone the Repository**:
   ```bash
   git clone https://github.com/1mos-droid/rtci-mobile.git
   cd rtc_mobile
   ```

2. **Install Dependencies**:
   ```bash
   flutter pub get
   ```

3. **Firebase Configuration**:
   Ensure you have your `google-services.json` (Android) and `GoogleService-Info.plist` (iOS) placed in the appropriate folders, or configure them using the FlutterFire CLI:
   ```bash
   flutterfire configure
   ```

4. **Run the Application**:
   ```bash
   flutter run
   ```

---

## 🤝 Contributing

We welcome contributions to help make RTCI Connect even better! Feel free to open issues or submit pull requests.

---

## 📄 License

This project is private and proprietary. All rights reserved.
