# Gym3D — Running and Testing Guide

This guide provides comprehensive instructions on how to set up, run, debug, and test the **Gym3D** cross-platform 3D fitness application.

---

## 1. Prerequisites & Environment Setup

### 1.1 Development Tools
- **Flutter SDK**: Installed at `C:\flutter` (Dart 3.7+ included).
- **Node.js / npm**: Node 20+ for Supabase CLI and tools.
- **Java**: OpenJDK / Amazon Corretto 17+.
- **Android Studio / Command-Line Tools**: For building Android APKs / Running on Android devices.
- **Web Browser**: Google Chrome or Microsoft Edge.

### 1.2 Verify Flutter Installation
In PowerShell or Terminal, verify your setup:

```powershell
# Add Flutter to your session PATH if not permanently added
$env:PATH += ";C:\flutter\bin"

# Verify Flutter and system dependencies
flutter doctor
```

---

## 2. Configuration & Environment Variables

Copy the example environment file into `mobile/.env`:

```powershell
cd D:\Personal\gym3d\mobile
Copy-Item .env.example .env
```

Edit `mobile/.env` with your project keys:

```env
# Supabase Configuration
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-supabase-anon-key

# RevenueCat Monetization (Optional for dev/demo mode)
REVENUECAT_API_KEY_ANDROID=your-revenuecat-android-key
REVENUECAT_API_KEY_IOS=your-revenuecat-ios-key

# Gemini AI (Deployed to Supabase Edge Function secrets)
# GEMINI_API_KEY=your-gemini-api-key
```

> [!NOTE]
> **Demo & Offline Fallback**: The app includes built-in offline simulation mode for local development. If Supabase or Gemini API keys are not provided, Gym3D seamlessly uses local domain mock engines for workouts, 3D exercises, and AI coaching.

---

## 3. How to Run the Application

Navigate to the `mobile/` directory:

```powershell
cd D:\Personal\gym3d\mobile
flutter pub get
```

### 3.1 Check Available Devices

```powershell
flutter devices
```

Output example:
```
Found connected devices:
  Chrome (web)      • chrome  • web-javascript • Google Chrome
  Edge (web)        • edge    • web-javascript • Microsoft Edge
  Android (mobile)  • emulator-5554 / physical device
```

---

### 3.2 Running on Web (Chrome / Edge)

Run in Chrome:
```powershell
flutter run -d chrome
```

Run in Microsoft Edge:
```powershell
flutter run -d edge
```

Run in Chrome with rendering optimizations:
```powershell
flutter run -d chrome --web-renderer canvaskit
```

---

### 3.3 Running on Android

#### A. Physical Android Device (Recommended)
1. Enable **Developer Options** and **USB Debugging** on your phone.
2. Connect phone via USB.
3. Run:
```powershell
flutter run -d android
```

#### B. Android Emulator
1. Start an AVD (Android Virtual Device) from Android Studio.
2. Run:
```powershell
flutter run
```

---

### 3.4 Useful Run Shortcuts (Interactive Terminal)
While the app is running in debug mode:
- Press `r` — **Hot Reload** (instant UI update without losing state).
- Press `R` — **Hot Restart** (full app restart).
- Press `p` — Toggle visual debug paint.
- Press `q` — Quit and stop the application.

---

## 4. How to Test the Application

### 4.1 Running All Automated Tests

Run the complete test suite:

```powershell
cd D:\Personal\gym3d\mobile
flutter test
```

### 4.2 Running Specific Test Suites

| Test Suite | File | What it Validates |
|---|---|---|
| **App Smoke Test** | `test/widget_test.dart` | App initialization, navigation shell, and theme |
| **3D Viewer & Muscles** | `test/exercise_3d_viewer_test.dart` | Camera angles, speed selector, and muscle engagement overlay |
| **Workout Builder & Live Tracker** | `test/workout_screens_test.dart` | Routine creation, set logger, stopwatch, and rest timer |
| **AI Coach & Generator** | `test/ai_coach_test.dart` | Chat bubbles, typing indicator, suggestions, and AI workout generator sheet |
| **Progress & Paywall** | `test/progress_and_paywall_test.dart` | `fl_chart` Volume & Days charts, PR cards, and Pro paywall sheet |

Run individual test files:

```powershell
flutter test test/widget_test.dart
flutter test test/exercise_3d_viewer_test.dart
flutter test test/workout_screens_test.dart
flutter test test/ai_coach_test.dart
flutter test test/progress_and_paywall_test.dart
```

---

### 4.3 Static Analysis & Code Quality

Run the Flutter Dart analyzer to verify 0 warnings / 0 errors:

```powershell
cd D:\Personal\gym3d\mobile
flutter analyze
```

Check code formatting:

```powershell
dart format --output=none --set-exit-if-changed .
```

---

## 5. Backend & Supabase Setup (Optional for Cloud Sync)

### 5.1 Applying SQL Migrations
If connecting to a live Supabase project:
1. Open your Supabase Dashboard SQL Editor.
2. Run the migration scripts in order:
   - `backend/supabase/migrations/001_initial_schema.sql` (Creates tables: `profiles`, `muscles`, `equipment`, `exercises`, `workouts`, `workout_logs`, `ai_conversations`, `subscriptions`).
   - `backend/supabase/migrations/002_rls_policies.sql` (Row-Level Security rules).
   - `backend/supabase/migrations/003_seed_data.sql` (Seeds 19 muscles, 10 equipment items, and 21 standard exercises).

### 5.2 Deploying AI Coach Edge Function
Deploy the Deno Edge Function with your Gemini API key:

```bash
# Login to Supabase
supabase login

# Set Gemini API Key secret
supabase secrets set GEMINI_API_KEY="your-gemini-api-key"

# Deploy function
supabase functions deploy ai-coach
```

---

## 6. Manual Feature Walkthrough Checklist

| Feature | How to Test in the App |
|---|---|
| 🏋️ **3D Exercise Viewer** | Go to **Exercises** tab → Tap **Barbell Squat** → Rotate 360°, tap `Front`/`45°`/`Side`/`Back` camera buttons, test `0.5x`/`1.0x`/`1.5x` playback speed. |
| 💪 **Muscle Engagement** | View muscle activation cards below the 3D model (Primary: Quadriceps & Glutes, Secondary: Hamstrings & Lower Back). |
| ⚡ **Live Workout Tracker** | Go to **Workouts** tab → Tap **Quick Start** or any routine → Tap sets to mark complete, observe rest timer popup (+30s/Skip), tap **Finish** to see celebration summary. |
| 🛠️ **Custom Workout Builder** | Go to **Workouts** tab → Tap **`+`** icon → Name your routine, add exercises with custom sets/reps/rest, reorder exercises, and tap **Save**. |
| 🤖 **AI Fitness Coach** | Tap the AI sparkles icon on **Home** or navigate to `/ai-coach` → Ask *"How do I squat with proper form?"* or tap quick suggestion chips. |
| 🎯 **AI Workout Generator** | On **Workouts** screen, tap **AI Workout Generator** → Select *Chest & Push* or *Full Body*, duration (*45m*), tap **Generate Workout** → Tap **Save to Workouts**. |
| 📊 **Progress Analytics** | Go to **Progress** tab → Toggle between **Volume Progression** (LineChart) and **Weekly Frequency** (BarChart) → View **Personal Records (PRs)** cards. |
| 👑 **Monetization & Pro Paywall** | Go to **Profile** tab → Tap **Upgrade to Pro** → View benefits, select **Annual (Save 33%)** or **Monthly**, tap **Start 7-Day Free Trial** → Observe user badge update to **PRO**. |
