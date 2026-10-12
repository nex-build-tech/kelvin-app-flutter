# 🏗️ Architecture & Technical Design

This document details the software architecture, design patterns, directory organization, and state management conventions of the **Kelvin Mech MEP Operations Platform**.

---

## 🏛️ Architectural Overview

The application follows a **Feature-First Clean Architecture** pattern tailored for modern Flutter applications. This provides clear separation of concerns, high testability, and isolated feature modules.

```
┌─────────────────────────────────────────────────────────────┐
│                    Presentation Layer                       │
│  (Screens, Widgets, Bottom Sheets, Dialogs, State Listeners)│
└──────────────────────────────┬──────────────────────────────┘
                               │
┌──────────────────────────────▼──────────────────────────────┐
│                    Business Logic Layer                     │
│  (AuthService, KelvinOpsService, NotificationService)       │
└──────────────────────────────┬──────────────────────────────┘
                               │
┌──────────────────────────────▼──────────────────────────────┐
│                     Domain & Models                         │
│  (UserModel, Project, FollowUp, Approval, Enquiry, Reminder)│
└──────────────────────────────┬──────────────────────────────┘
                               │
┌──────────────────────────────▼──────────────────────────────┐
│                      Data & Storage                         │
│  (SharedPreferences Key-Value Store, Mock Telemetry Data)   │
└─────────────────────────────────────────────────────────────┘
```

---

## 📁 Project Directory Structure

```
lib/
├── main.dart                       # App entry point, services bootstrap
├── app.dart                        # CoreApp widget, ThemeData & Router binding
│
├── core/                           # Application foundation
│   ├── constants/
│   │   ├── app_colors.dart         # Kelvin Mech enterprise blue palette & semantic tokens
│   │   ├── app_dimensions.dart     # Spacing, border radii, paddings
│   │   └── app_strings.dart        # User-facing strings & error messages
│   ├── services/
│   │   ├── kelvin_ops_service.dart # Singleton live ops engine (KPIs, feed, timers)
│   │   └── notification_service.dart # Real-time in-app notification & alert engine
│   ├── theme/
│   │   ├── app_theme.dart          # Light and Dark Material 3 theme configurations
│   │   └── theme_controller.dart   # Reactive theme & push alert preferences controller
│   └── utils/
│       └── validators.dart         # Form validation utilities
│
├── models/                         # Domain Entities
│   ├── user_model.dart             # Authenticated user persona & clearance
│   ├── hvac_project_model.dart     # MEP projects, status, phase & % progress
│   ├── follow_up_model.dart        # CRM follow-ups, communication channels, SLA
│   ├── approval_model.dart         # Purchase order requisitions, ₹Lakhs value, urgency
│   ├── enquiry_model.dart          # Inbound sales enquiries & lead source tracking
│   ├── reminder_model.dart         # Operational checklists & reminder schedules
│   ├── hvac_task_model.dart        # Operational task items & checklist flags
│   └── feed_activity_model.dart    # Live telemetry feed stream items
│
├── navigation/
│   └── app_router.dart             # Central route coordinator & auth route guards
│
├── components/                     # Reusable UI Primitives
│   ├── app_button.dart             # Accessible button with loading state & variants
│   ├── app_text_field.dart         # Form inputs with floating labels & error handling
│   ├── app_drawer.dart             # Side navigation drawer with module shortcuts
│   ├── notification_bell.dart      # Animated wiggle bell with dynamic unread badge
│   └── ...                         # Notification sheets, modals, cards
│
└── features/                       # Modular Feature Packages
    ├── splash/
    │   └── splash_screen.dart      # Brand splash, pulsing rings, auto-routing
    ├── auth/
    │   ├── login_screen.dart       # Split-pane/hero card login, demo drawer, Google 1-click
    │   └── auth_service.dart       # Session persistence & user credential authentication
    ├── dashboard/
    │   └── dashboard_screen.dart   # Live KPI cards, My Tasks checklist, Pulse tracker, Feed
    ├── followups/
    │   └── followups_screen.dart   # Search filter, WhatsApp/Call/Email actions, Snooze
    ├── quick_actions/
    │   └── quick_actions_screen.dart # Center tab: PO approvals modal & enquiries manager
    ├── reminders/
    │   └── reminders_screen.dart   # Categorized reminders & custom add reminder sheet
    ├── profile/
    │   └── profile_screen.dart     # Executive clearance stats, notification toggles, sign out
    ├── settings/
    │   └── settings_screen.dart    # Appearance, diagnostics, active session, logout button
    └── main_wrapper.dart           # 5-tab bottom navigation with backstack interceptor
```

---

## ⚡ State Management Pattern

The codebase avoids heavy external state management boilerplate in favor of Flutter's native, lightweight, and high-performance **`ChangeNotifier` + `ListenableBuilder`** architecture:

1. **`AuthService`**: Manages current user state, login validation, Google OAuth bypass, and persistent session disk cache.
2. **`ThemeController`**: Manages light/dark mode toggling, push alert flags, and maintenance notifications.
3. **`KelvinOpsService`**: Acts as the centralized MEP operations data bus. Maintains live counters, projects list, follow-ups, PO approvals, enquiries, and real-time activity feed events.

### Why ListenableBuilder?
- Native to Flutter SDK (no extra runtime dependencies required).
- Rebuilds **only** the necessary subtrees listening to state mutations.
- Zero memory leaks when paired with proper widget lifecycle management.

---

## 🧭 Navigation & Routing

Routing is centralized in [AppRouter](file:///c:/Users/Tushal/Desktop/HVAC/lib/navigation/app_router.dart):

```dart
static const String rootRoute = '/';
static const String loginRoute = '/login';
static const String mainRoute = '/main';
static const String notificationsRoute = '/notifications';
static const String settingsRoute = '/settings';
```

### Route Protection (Auth Guard)
- If an unauthenticated user attempts to access `/main`, the router automatically redirects to `/login`.
- Upon successful login, `Navigator.pushNamedAndRemoveUntil(mainRoute, (r) => false)` flushes the backstack so the user cannot pop back into the login screen.
- Upon logout (from Settings or Profile), the session cache is invalidated and the user is redirected to `/login` with an empty backstack.

---

## 📡 Live Telemetry & Simulation Engine

[KelvinOpsService](file:///c:/Users/Tushal/Desktop/HVAC/lib/core/services/kelvin_ops_service.dart) simulates high-frequency industrial IoT and MEP field operations:

- **KPI Tick (every 3.5s)**: Fluctuate active tasks, approvals, SLA breaches, and enquiries within realistic operational ranges.
- **Project Progress Tick (every 5.0s)**: Increments milestone percentage on active construction projects.
- **Live Activity Feed (every 7.0s)**: Injects dynamic telemetry events (PO deliveries, SLA resolutions, client messages) into the top of the feed with pulsing indicators.
- **Background Alert Dispatcher (every 22.0s)**: Dispatches high-priority system banners with haptic feedback.
- **Lifecycle Cleanliness**: Provides `stopSimulation()` to cancel background timers when tearing down or running automated test suites.
