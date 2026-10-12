# 🚀 Getting Started with Kelvin Mech (Flutter)

Welcome to the **Kelvin Mech MEP Operations Platform** mobile application codebase. This guide walks you through setting up your local environment, running the application across platforms, running automated tests, and building production releases.

---

## 📋 Prerequisites

Before starting, ensure your workstation meets the following minimum requirements:

1. **Flutter SDK**: Version `3.24.0` or higher (Channel `stable`)
2. **Dart SDK**: Version `3.5.0` or higher (bundled with Flutter)
3. **Android Studio** / **VS Code** with Flutter and Dart extensions
4. **Android SDK & Build Tools**:
   - Android SDK Platform `34` (Android 14) or `35`
   - Android NDK & CMake (optional, standard Flutter Android toolchain)
   - Java Development Kit (JDK): JDK `17` or `21`
5. **Git**: Installed and configured on your machine

Verify your environment by running:
```bash
flutter doctor -v
```
Ensure there are no blocking issues reported for your target deployment platform.

---

## 🛠️ Step-by-Step Installation

### 1. Clone the Repository
```bash
git clone https://github.com/nex-build-tech/kelvin-app-flutter.git
cd kelvin-app-flutter
```

### 2. Fetch Dependencies
Install all project dependencies declared in `pubspec.yaml`:
```bash
flutter pub get
```

### 3. Verify Code Health
Run Flutter analysis to ensure zero static analysis or syntax errors:
```bash
flutter analyze
```
*Expected output: `No issues found!`*

### 4. Run Automated Test Suites
Run the unit, validator, and widget integration tests:
```bash
flutter test
```
*Expected output: `All tests passed!`*

---

## ▶️ Running the Application

### Running on an Android Emulator or Physical Device
1. Connect your Android device via USB (with **USB Debugging** enabled) or launch an Android Virtual Device (AVD) from Android Studio.
2. List available connected devices:
   ```bash
   flutter devices
   ```
3. Run the app in debug mode:
   ```bash
   flutter run
   ```

### Running on Chrome / Web
```bash
flutter run -d chrome
```

### Running on Windows Desktop
```bash
flutter run -d windows
```

---

## 🔐 Demo User Credentials & Quick Sign-In

For testing and demonstration, Kelvin Mech includes **4 pre-configured demo operational accounts** and a **1-click Google OAuth simulation**:

| Name | Role | Email | Password | Primary Clearance |
| :--- | :--- | :--- | :--- | :--- |
| **Suresh Iyer** | Procurement Manager | `suresh@kelvinmech.com` | `kelvin123` | PO Approvals, Vendor Quotes |
| **Priya Shah** | Project Manager | `priya@kelvinmech.com` | `kelvin123` | Project Pulse, Field Checklists |
| **Sachin G** | Lead Architect / Admin | `admin@kelvinmech.com` | `admin123` | Full Operations & SLA Admin |
| **Demo User** | Viewer / Operations Trainee | `demo@kelvinmech.com` | `demo` | Read-only Monitoring |

> 💡 **Quick Sign-In Tip**: On the Login screen, you can also tap the **"Sign in with Google"** button to instantly authenticate with 1-click bypass, or expand **"Use a demo account"** to auto-fill any demo persona with a single tap.

---

## 📦 Building for Production

### Build Android Release APK
To compile an optimized, tree-shaken, standalone release APK:
```bash
flutter build apk --release
```
- **Output Artifact**: `build/app/outputs/flutter-apk/app-release.apk`
- **Typical Size**: ~20 MB (with all native libs and optimized vector assets)

### Build Android App Bundle (for Google Play Store)
```bash
flutter build appbundle --release
```
- **Output Artifact**: `build/app/outputs/bundle/release/app-release.aab`

### Build Web Release
```bash
flutter build web --release
```
- **Output Directory**: `build/web/`

---

## 🔧 Useful Development Commands

| Command | Description |
| :--- | :--- |
| `r` in terminal | Hot Reload (updates UI state in sub-second time) |
| `R` in terminal | Hot Restart (re-initializes app state & timers) |
| `flutter clean` | Cleans temporary build directories and caches |
| `flutter pub get` | Re-installs packages after dependency changes |
| `flutter pub outdated` | Checks for newer package versions |
| `flutter test --coverage` | Generates code coverage report |

---

## ❓ Troubleshooting & FAQs

### Gradle Build Failure / Execution failed for task `:app:compileFlutterBuildRelease`
- Ensure you have run `flutter clean` followed by `flutter pub get`.
- Verify your Java version (`java -version`). Flutter currently recommends JDK 17 or 21.

### Device Not Detected
- On Android, ensure **Developer Options** and **USB Debugging** are turned ON.
- Run `adb devices` to check ADB connection.
- For wireless debugging: `adb connect <device-ip>:5555`.

### Session Cache Reset
- If you wish to clear local user session storage completely, tap **Settings > Log Out from Kelvin Mech** inside the app, or clear app storage in Android device settings.
