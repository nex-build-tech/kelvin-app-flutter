# Kelvin Mech App — Handoff Notes
> Last updated: 16 May 2026 | Session: BuildFlow / kelvinmech-app prototype

---

## What This Is
A **React Native (Expo)** prototype app for **Kelvin Mech**, an MEP (Mechanical, Electrical, Plumbing) operations company. Built as a demo/prototype to show the Kelvin Mech team what their internal ops platform could look like on Android. Not connected to any real backend yet — all data is mocked and live-looking via intervals.

**Built by:** Ayu Ventures  
**Stack:** React Native + Expo (blank template), @react-navigation, expo-linear-gradient, AsyncStorage

---

## Project Location
```
D:\ayuventures\BuildFlow\kelvinmech-app\
```

---

## Demo Credentials (Login Screen)

| Role                | Email                       | Password    |
|---------------------|-----------------------------|-------------|
| Procurement Manager | suresh@kelvinmech.com       | kelvin123   |
| Project Manager     | priya@kelvinmech.com        | kelvin123   |
| Admin / Architect   | admin@kelvinmech.com        | admin123    |
| Demo Viewer         | demo@kelvinmech.com         | demo        |
| Google bypass       | tap "Sign in with Google"   | (no password needed) |

---

## App Flow
```
Splash Screen (2.6s animated)
    ↓
[AsyncStorage check]
    ├── Already logged in → Main Tabs (skip login)
    └── Not logged in    → Login Screen
                              ↓
                         Main Tabs
                         ├── Home
                         ├── Follow-ups
                         ├── ⚡ Quick Actions (floating button)
                         ├── Reminders
                         └── Profile
                              ↓ (bell icon in Home header)
                         Notifications Screen
```

---

## File Structure
```
kelvinmech-app/
├── App.js                          ← Root: AuthProvider + NotificationProvider + nav
├── src/
│   ├── theme/index.js              ← Colors, spacing, radius, fontSize, shadow tokens
│   ├── data/mock.js                ← All mock data (ME, KPI_CARDS, PROJECTS, TASKS, etc.)
│   ├── context/
│   │   ├── AuthContext.js          ← Login/logout/Google, AsyncStorage persistence
│   │   └── NotificationContext.js  ← 8 seed notifs + live pool every 20s, markRead/clearAll
│   ├── hooks/
│   │   └── useLiveData.js          ← useLiveKpis, useLiveProjects, useLiveFeed
│   ├── components/
│   │   ├── Card.js                 ← Card with shadow/flat variants
│   │   ├── Badge.js                ← Badge (6 color variants, dot option)
│   │   ├── Header.js               ← App header with back button
│   │   └── NotificationBell.js     ← Bell icon + live badge + wiggle animation
│   └── screens/
│       ├── SplashScreen.js         ← Animated splash (rings, spring logo, loading bar)
│       ├── LoginScreen.js          ← Branded login + demo hints + Google bypass
│       ├── HomeScreen.js           ← Live KPIs, live feed, live projects, notif bell
│       ├── FollowUpsScreen.js      ← Filter tabs, search, WhatsApp/Call/Email/Snooze
│       ├── QuickActionsScreen.js   ← Approvals + Enquiries tabs, approve/reject flows
│       ├── RemindersScreen.js      ← Today/Upcoming/Completed, add reminder modal
│       ├── ProfileScreen.js        ← User info, notif switches, sign out
│       └── NotificationsScreen.js  ← Full notif centre, filter by type, mark/clear
```

---

## What's Live / Animated

| Widget              | Updates every | Notes |
|---------------------|--------------|-------|
| KPI counters (Home) | 3 seconds    | Smooth animated count from current → new value |
| Project % bars      | 5 seconds    | One random project ticks up |
| Activity feed       | 6 seconds    | New item prepended with NEW badge |
| Notifications       | 20 seconds   | New notification arrives, bell wiggles |
| Splash loading bar  | Once         | Animates to 55% over 1.4s on open |
| Live dot (Home)     | Always       | Pulsing green dot next to "Live Activity" |

---

## Packages Installed
```json
"expo-linear-gradient"
"expo-haptics"
"expo-notifications"
"@react-native-async-storage/async-storage"
"@react-navigation/native"
"@react-navigation/bottom-tabs"
"@react-navigation/native-stack"
"dayjs"
"react-native-safe-area-context"
"react-native-screens"
"@expo/vector-icons"
```

---

## What's Pending / Next Steps

### Immediate (next session)
- [ ] Connect to **ProjectBase ERP** (Kelvin's real data) — user needs to connect Chrome extension first
- [ ] Read real projects, tasks, POs from ProjectBase and replace mock data
- [ ] Test on a real Android device via `expo go` or `eas build`

### Short term
- [ ] **SLA Detail screen** — drill into a specific breach with timeline
- [ ] **Project Detail screen** — team, milestones, PO list per project
- [ ] **PO Detail screen** — vendor info, approval chain, docs
- [ ] **Enquiry Detail screen** — full conversation history + status timeline
- [ ] **Search** — global search across tasks, POs, enquiries

### Medium term (real backend)
- [ ] Connect to real API (AWS EC2 + RDS PostgreSQL — cost plan already done)
- [ ] Real push notifications via FCM
- [ ] WhatsApp integration via Meta Cloud API (direct)
- [ ] SMS via MSG91 (India)
- [ ] Auth via real email/password or Google OAuth
- [ ] Role-based access (Admin sees everything, Viewer read-only)

### Nice to have
- [ ] Dark mode (tokens already designed, just needs a theme toggle)
- [ ] Biometric login (Face ID / fingerprint)
- [ ] Offline mode with AsyncStorage cache

---

## TV Wall Dashboard (separate)
There's also a **TV wall display** built in Next.js at:
```
D:\ayuventures\BuildFlow\demo\src\app\pages\kelvinmech\tv\index.jsx
```
- Light/Dark toggle
- All data live (master 1-second tick)
- Staggered KPI counter animation (delay + smooth re-animation)
- Shows: KPIs, SLA breaches, projects, vendor status, team, approvals, live feed

---

## Cost Plan (already discussed)
- **1-month MVP:** ~₹6.8–7.2L total (1 Sr Eng + 2 Jr Eng + 1 PM part-time)
- **2-month MVP:** ~₹11.5–12.5L total (same team, more features)
- **Infra (AWS):** ~$180–220/month (EC2 t3.medium, RDS, Redis, S3, CloudFront)
- **APIs:** FCM free, MSG91 ~₹3k/mo, Resend ~$20/mo, Gemini Flash cheapest AI option

---

## How to Run
```bash
cd D:\ayuventures\BuildFlow\kelvinmech-app
npx expo start
# Scan QR with Expo Go app on Android
```

---

*Handoff created by Claude (Ayu Ventures session) — continue in same thread or new session referencing this file.*
