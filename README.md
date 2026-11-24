# RTCI Connect 🌟

The official community mobile application for the **Redeemed Transformation Chapel International (RTCI)**. Built with Flutter, Dart, Firebase, and Riverpod with a warm, accessible Material 3 interface, bundled typography, adaptive layouts and a custom church-seal loader.

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
- **📖 Bible & Bible Studies**: Bible reading paired with curated study materials. New chapter content requires a connection.
- **🖼️ Service Gallery**: Image upload and view stream of recent service highlights.
- **👥 Admin Controls**: User account management and role-based permissions (Member, Department Head, Admin).
- **🎨 Obsidian Theme**: Unified adaptive styling supporting persisted system, light, and dark modes with solid, readable cards.

---

## 🛠️ Architecture & Tech Stack

This project follows clean architecture principles to ensure robustness, testability, and YAGNI simplicity:

- **State Management**: [Riverpod](https://riverpod.dev) (`flutter_riverpod` + `riverpod_annotation`). Legacy MultiProvider structures have been completely removed for clean dependencies.
- **Backend / Database**: Cloud Firestore, Firebase Auth, and Firebase Storage.
- **UI & Animations**: Shared solid cards, native controls, responsive navigation and reduced-motion-aware loading states. Legacy widget names are retained for compatibility.
- **Fonts & Styling**: Semantic theme colors and bundled Inter typography (OFL license included).

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

## Design and release status

The current visual system, library assessment and screenshot commands are documented in [docs/DESIGN.md](docs/DESIGN.md).

Read [docs/RELEASE_READINESS.md](docs/RELEASE_READINESS.md) before deploying. The repository now includes secured rules, a verified giving backend and a Bible proxy. These require the coordinated staging migration, secret configuration, deployment and real-device checks described in [docs/BACKEND_ROLLOUT.md](docs/BACKEND_ROLLOUT.md) before production release.
