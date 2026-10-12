# 🎨 Design System & UI Specifications

This document outlines the visual language, design tokens, color palette, typography hierarchy, and UI component standards of the **Kelvin Mech MEP Operations Platform**.

---

## 🎯 Design Philosophy

1. **Mission-Critical Clarity**: High information density without clutter. Project managers, procurement executives, and on-site engineers need immediate, actionable visibility on SLA breaches, pending approvals, and project progress.
2. **Industrial Premium Aesthetics**: Moving away from generic flat dashboards toward rich, authoritative enterprise styling featuring deep navy blue gradients, soft translucent card surfaces, subtle borders, and vivid status accents.
3. **Responsive Tactility**: Micro-animations, live telemetry indicators, and haptic feedback triggers provide a responsive, alive tactile experience.

---

## 🎨 Color Palette & Design Tokens

### Primary Brand Palette
```
#071448  ████  Primary Dark Navy (Deep Banner Gradient Start)
#0B1F68  ████  Brand Navy (App Bar, Dark Surface Headers)
#1A56DB  ████  Kelvin Royal Blue (Primary Buttons, Active Tabs, Highlights)
#3B82F6  ████  Vibrant Accent Blue (Badges, Active Toggles)
#60A5FA  ████  Soft Light Blue (Subtitles, Borders in Dark Mode)
```

### Semantic Status Colors
| Status Token | Hex Code | Light Tint BG | Usage |
| :--- | :--- | :--- | :--- |
| **Success** | `#10B981` | `#F0FDF4` | On-track projects, approved POs, completed tasks |
| **Warning** | `#F59E0B` | `#FEF3C7` | Approvals pending, medium urgency, SLA warnings |
| **Danger / SLA** | `#EF4444` | `#FEF2F2` | Overdue follow-ups, SLA breaches, high urgency POs |
| **Info / Telemetry** | `#0284C7` | `#F0F9FF` | Enquiries, client communications, system messages |

### Surfaces & Backgrounds
| Theme Mode | Scaffold Background | Card / Container Surface | Card Border |
| :--- | :--- | :--- | :--- |
| **Dark Theme** | `#090D16` | `#111D3C` / `#131B2E` | `#1E2D54` (0.8 opacity) |
| **Light Theme** | `#F8FAFC` | `#FFFFFF` | `#E2E8F0` |

---

## ✍️ Typography Scale

The application uses standard platform system typography optimized for high legibility on mobile devices:

| Style Role | Font Size | Weight | Letter Spacing | Example Context |
| :--- | :---: | :---: | :---: | :--- |
| **Display Large** | `26.0` | `900` | `-0.4px` | Splash screen brand title |
| **Headline Medium** | `22.0` | `900` | `-0.3px` | Module headers (Dashboard, Follow-ups) |
| **Title Medium** | `18.0` | `800` | `-0.2px` | Section titles ("Live Activity", "My Tasks") |
| **Body Bold** | `14.0` | `700` | `0.0px` | Card primary labels, PO reference numbers |
| **Body Medium** | `13.0` | `500` | `0.0px` | Client names, task descriptions, subtext |
| **Caption / Badge** | `11.0` | `700` | `+0.2px` | Timestamp tags, status pill badges, SLA indicators |

---

## 🧩 Reusable Component Standards

### 1. Primary Action Button (`AppButton`)
- **Height**: `48.0` px
- **Corner Radius**: `14.0` px
- **Elevation**: `2.0` (with soft shadow `#1A56DB` at 35% opacity)
- **Loading State**: Automatic spinner indicator without layout jump

### 2. Operational Surface Card
- **Corner Radius**: `16.0` px (uniform `Border.all` ensures 100% Flutter painting compliance)
- **Padding**: `14.0` px to `16.0` px
- **Box Shadow**: Offset `(0, 3)`, blur `10.0`, opacity `0.04` (light) / `0.25` (dark)

### 3. Status Badges & Pills
- **Corner Radius**: `10.0` px to `12.0` px
- **Padding**: `horizontal: 8px, vertical: 3px`
- **Color**: Semantic accent at 12-18% opacity with solid text color

### 4. Interactive Bottom Sheets
- **Corner Radius**: `24.0` px on top edges
- **Drag Handle**: Centered pill `40x4px` in muted grey
- **Backdrop**: Translucent black scrim (`0.54` opacity) with blur

---

## 🌓 Dark Mode & Light Mode Theme Support

The app supports dynamic runtime theme switching via [ThemeController](file:///c:/Users/Tushal/Desktop/HVAC/lib/core/theme/theme_controller.dart):
- Accessible from both the side navigation drawer and the **Settings Screen**.
- Automatically adapts all icon contrast, border shades, surface cards, and font colors.
- Preserves battery life on OLED displays with deep dark `#090D16` tones.
