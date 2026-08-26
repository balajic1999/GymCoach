# Project Setup

## Development Environment

| Component | Version | Status |
|-----------|---------|--------|
| OS | Windows 11 Pro (NT 10.0.26200.0) | ✅ |
| Git | 2.54.0 | ✅ |
| Node.js | 24.19.0 | ✅ |
| npm | 11.17.0 | ✅ |
| Java | OpenJDK Corretto 17.0.19 | ✅ |
| Flutter SDK | Latest stable | ✅ Installed at `C:\flutter` |
| Android SDK | API 34+ | Required |
| Dart | Bundled with Flutter | ✅ |

## Prerequisites

### Flutter SDK

Flutter is installed at `C:\flutter`. Ensure it is on your PATH:

```powershell
$env:PATH += ";C:\flutter\bin"
# Or add permanently via System Environment Variables
```

Verify:

```bash
flutter --version
flutter doctor
```

### Android SDK

Install Android command-line tools and required SDK components:

```bash
flutter doctor --android-licenses
```

### Supabase

1. Create a Supabase project at https://supabase.com
2. Copy the project URL and anon key
3. Create a `.env` file in `mobile/` (never commit this):

```env
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key
```

### Gemini API

1. Get an API key from https://aistudio.google.com/apikey
2. Add to Supabase Edge Function secrets (NOT in mobile app)

### RevenueCat

1. Create account at https://www.revenuecat.com
2. Configure Google Play and App Store apps
3. Add API key to `.env`:

```env
REVENUECAT_API_KEY=your-api-key
```

## iOS Development

iOS builds require macOS with Xcode. Options for Windows development:

1. **Codemagic CI/CD** — Cloud-based iOS builds
2. **GitHub Actions** — macOS runners for CI
3. **Physical Mac** — Local development

The Flutter codebase is fully cross-platform. iOS-specific configuration is in `mobile/ios/`.

## Running the Application

```bash
cd mobile

# Install dependencies
flutter pub get

# Run code generation (Freezed models)
dart run build_runner build --delete-conflicting-outputs

# Run on connected Android device
flutter run

# Run on Android emulator
flutter emulators --launch <emulator_id>
flutter run

# Run tests
flutter test

# Static analysis
flutter analyze
```

## Environment Variables

Environment variables are managed via the `envied` package. See `mobile/lib/core/env/` for configuration.

**Never commit `.env` files or API keys to version control.**
