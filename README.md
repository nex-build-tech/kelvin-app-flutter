# ❄️ Kelvin Mech — MEP Operations Platform (Flutter)

[![Flutter](https://img.shields.io/badge/Flutter-3.24%2B-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.5%2B-0175C2?logo=dart&logoColor=white)](https://dart.dev)
[![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS%20%7C%20Web%20%7C%20Windows-blue)](#)
[![Design](https://img.shields.io/badge/Design-Material%203%20%2B%20Dark%20Navy-1A56DB)](#)
[![License](https://img.shields.io/badge/License-Proprietary-red)](#)

> **Kelvin Mech** is an enterprise-grade mobile operations and field telemetry suite tailored for Mechanical, Electrical, and Plumbing (MEP) contractors, HVAC engineers, procurement officers, and project directors.

---

## 📑 Table of Contents

- [Overview & Value Proposition](#-overview--value-proposition)
- [Key Features & Modules](#-key-features--modules)
- [Live Telemetry Engine](#-live-telemetry-engine)
- [Local MySQL Database & Backend](#-local-mysql-database--backend)
- [Quick Start Guide](#-quick-start-guide)
- [Building Release APK](#-building-release-apk)
- [Pre-configured Demo Accounts](#-pre-configured-demo-accounts)
- [Architecture & Tech Stack](#-architecture--tech-stack)
- [Documentation Index](#-documentation-index)
- [Testing & Quality Assurance](#-testing--quality-assurance)

---

## 🌟 Overview & Value Proposition

In commercial HVAC and MEP contracting, operational friction directly damages profit margins. Delays in purchase order approvals, untracked on-site follow-ups, and unmonitored SLA breaches lead to project penalties and idle labor.

**Kelvin Mech** consolidates all critical MEP field and procurement workflows into an intuitive, high-density, mission-critical mobile application:
- **Instant PO Sign-offs**: Approve or reject vendor requisitions with ₹Lakhs value calculations.
- **Client & Vendor Follow-ups**: Direct 1-tap WhatsApp, phone call, or email triggers.
- **Live Operational Pulse**: Real-time KPI counters and automated construction site progress simulation.
- **Session Security**: Offline-first persistent storage with one-tap logout and account switching.

---

## 📱 Key Features & Modules

### 1. 🏠 Executive Operations Dashboard
- **Personalized Greeting**: Dynamic time-of-day greeting (*Good morning / afternoon / evening*) with date display.
- **Critical Alert Strips**: Immediate high-visibility banners for overdue tasks and active SLA breaches.
- **Live KPI Horizontal Cards**: Real-time counters for *Tasks Today*, *SLA Breaches*, *Approvals Pending*, and *Open Enquiries*.
- **My Tasks Today**: Interactive checklist with priority pill badges and project site tags.
- **Project Pulse**: Milestone completion progress bars for major contracts (*Airport Terminal T3, ABC Tower, Metro Station, DLF Cybercity*).
- **Live Activity Feed**: Real-time telemetry event stream with pulsing activity indicator.

### 2. 📞 Follow-ups CRM & Communication
- **Channel Actions**: Direct launch triggers for **WhatsApp**, **Direct Phone Call**, and **Email**.
- **Real-Time Search & Filtering**: Instant filter chips for *All*, *Overdue*, *Due Today*, and *Upcoming*.
- **Quick Actions**: Mark Done or open the interactive **Snooze Sheet** (4 hours, tomorrow morning, or next week).

### 3. ⚡ Quick Actions (Center Lightning Tab)
- **Purchase Order (PO) Approvals**:
  - Total pending value summation (*e.g., ₹83.7L pending*).
  - High/Medium urgency color indicators and vendor tags (*Daikin, Carrier, ABB, Voltas*).
  - Modal approval dialog with custom engineering remarks and sign-off confirmation.
  - Rejection with reason modal.
- **Client Enquiries**:
  - Lead sources: WhatsApp, Email, Phone, Direct Walk-in.
  - Scope details, estimated contract value, and quick team member assignment.

### 4. ⏰ Operational Reminders
- Grouped views: *Due Today*, *Upcoming*, and *Completed*.
- **Add Reminder Sheet**: Custom title, date-time selector, repeat frequency (None, Daily, Weekly, Monthly), and urgency tier.

### 5. 👤 Executive Profile & Diagnostics
- **Hero Card**: User avatar with online indicator and verified clearance badge.
- **Performance Metrics**: *47 Tasks Done* | *23 POs Approved* | *94% SLA score*.
- **Clearance Level**: Department clearance and system role summary.
- **6 Notification Preferences**: Granular switches for SLA alerts, PO sign-offs, Follow-up pings, and Daily digests.
- **Sign Out Action**: Direct logout confirmation dialog.

### 6. ⚙️ App Settings & Session Management
- **Appearance**: Instant toggle between Deep Navy Dark Mode (`#090D16`) and Clean Light Mode (`#F8FAFC`).
- **Push Alerts Engine**: Real-time in-app notification dispatcher for testing telemetry.
- **Account & Session**: Displays active user initials, corporate email, and position badge.
- **Prominent Logout Button**: High-contrast, red-accented **"Log Out from Kelvin Mech"** button with confirmation modal and session cache flushing.

---

## 📡 Live Telemetry Engine

Kelvin Mech includes an embedded, high-frequency operations simulation engine ([KelvinOpsService](file:///c:/Users/Tushal/Desktop/HVAC/lib/core/services/kelvin_ops_service.dart)):
- **3.5s KPI Tick**: Live fluctuation of active tasks and open enquiries.
- **5.0s Project Milestone Tick**: Progress percentage increments on live construction contracts.
- **7.0s Activity Feed Stream**: Injects new deliveries, quotes, and SLA updates.
- **22.0s Telemetry Alert**: Dispatches high-priority system alerts with haptic vibration.

---

## 🚀 Quick Start Guide

### 1. Clone & Setup
```bash
git clone https://github.com/nex-build-tech/kelvin-app-flutter.git
cd kelvin-app-flutter
flutter pub get
```

### 2. Run the Application
```bash
# Android Device / Emulator
flutter run

# Web Browser
flutter run -d chrome

# Windows Desktop
flutter run -d windows
```

For full setup instructions, see [docs/GETTING_STARTED.md](docs/GETTING_STARTED.md).

---

## 📦 Building Release APK

To build a standalone production release APK for Android:
```bash
flutter build apk --release
```
- **Output Artifact**: `build/app/outputs/flutter-apk/app-release.apk`
- **Build Status**: Verified and tested (~20.3 MB release binary).

---

## 🔐 Pre-configured Demo Accounts

| User | Role | Email | Password |
| :--- | :--- | :--- | :--- |
| **Suresh Iyer** | Procurement Manager | `suresh@kelvinmech.com` | `kelvin123` |
| **Priya Shah** | Project Manager | `priya@kelvinmech.com` | `kelvin123` |
| **Sachin G** | Lead Architect / Admin | `admin@kelvinmech.com` | `admin123` |
| **Demo User** | Viewer | `demo@kelvinmech.com` | `demo` |

> ⚡ **Quick Bypass**: You can also tap **"Sign in with Google"** on the Login screen for 1-click instant login simulation.

---

## 🏗️ Architecture & Tech Stack

- **Framework**: Flutter `3.24+` / Dart `3.5+`
- **Design System**: Material 3 + Custom Kelvin Mech Enterprise Design System
- **State Management**: Reactive `ChangeNotifier` + `ListenableBuilder`
- **Persistence**: Encrypted `SharedPreferences` session cache
- **Routing**: Named Route Guarding with backstack flushing ([AppRouter](file:///c:/Users/Tushal/Desktop/HVAC/lib/navigation/app_router.dart))

For deep architectural details, see [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md).

---

## 🗄️ Local MySQL Database & Backend

Kelvin Mech integrates with a local **MySQL 8.0** database (`kelvin_mech_db`) bridged by a lightweight Node.js Express REST API in `backend/`:

### 1-Command Database Setup:
```bash
cd backend
npm install
node setup_database.js
```
*Creates `kelvin_mech_db`, applies 8 tables (`users`, `projects`, `tasks`, `follow_ups`, `approvals`, `enquiries`, `reminders`, `activity_logs`), and seeds initial MEP operations data.*

### Start Backend API:
```bash
npm start
# Server listens on http://localhost:5000 (Android Emulator: http://10.0.2.2:5000)
```

For complete step-by-step instructions, table schemas, and network configuration, see **[docs/MYSQL_SETUP.md](docs/MYSQL_SETUP.md)**.

---

## 📚 Documentation Index

| Document | Purpose |
| :--- | :--- |
| [docs/MYSQL_SETUP.md](docs/MYSQL_SETUP.md) | **Local MySQL 8.0 setup**, REST API bridge, table schemas, and phone/emulator connection guide. |
| [docs/DATABASE_SCRIPTS.md](docs/DATABASE_SCRIPTS.md) | **Database migrations**, rollbacks, automated backup & restore, seed data, and health check. |
| [docs/GETTING_STARTED.md](docs/GETTING_STARTED.md) | Local developer environment setup, running across platforms, and troubleshooting. |
| [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) | Technical architecture, directory structure, state management, and routing. |
| [docs/DATABASE_AND_MODELS.md](docs/DATABASE_AND_MODELS.md) | Local storage, domain models schemas, ER diagram, and cloud DB migration roadmap. |
| [docs/DESIGN_SYSTEM.md](docs/DESIGN_SYSTEM.md) | Color tokens, typography, dark/light themes, and UI component standards. |

---

## 🧪 Testing & Quality Assurance

The codebase includes comprehensive automated tests covering unit logic, validators, and complete user journeys:

```bash
# Run code analysis (0 warnings / 0 errors guaranteed)
flutter analyze

# Run all automated test suites
flutter test
```

- **Static Analysis**: `No issues found!`
- **Unit & Widget Test Coverage**: `12/12 test suites passed!`

---

## 📄 License & Attribution

Copyright © 2026 NexBuild Technologies / Kelvin Mech Operations. All rights reserved.
