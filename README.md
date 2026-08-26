# Gym3D AI Personal Trainer

An AI-powered fitness application combining interactive 3D exercise demonstrations, personalized workout plans, AI coaching, and progress tracking.

## Features

- **3D Exercise Library** — Interactive 3D models with rotation, zoom, playback controls
- **AI Coach** — Personalized exercise explanations, workout generation, training guidance
- **Workout System** — Create, execute, and track workouts with set/rep logging
- **Progress Tracking** — Charts, personal records, volume tracking, consistency metrics
- **Muscle Visualization** — Highlighted muscle groups for each exercise
- **Subscription Model** — Free tier with upgrade to Pro for full features

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Mobile | Flutter + Dart |
| 3D Engine | flutter_3d_controller (GLB/glTF) |
| Backend | Supabase (PostgreSQL, Auth, Storage, Edge Functions) |
| AI | Gemini API via Supabase Edge Functions |
| Subscriptions | RevenueCat |
| State Management | Riverpod |
| Routing | GoRouter |
| Analytics | Firebase Analytics |

## Project Structure

```
gym3d/
├── mobile/          # Flutter application
├── backend/         # Supabase configuration, migrations, edge functions
├── assets/          # Source 3D assets (pre-optimization)
├── documentation/   # Architecture and design documents
└── README.md
```

## Getting Started

### Prerequisites

- Flutter SDK (stable channel)
- Android SDK (API 34+)
- Supabase project
- Gemini API key (for AI Coach)
- RevenueCat account (for subscriptions)

### Development Setup

```bash
# Clone the repository
git clone <repo-url>

# Navigate to Flutter project
cd gym3d/mobile

# Install dependencies
flutter pub get

# Run on Android
flutter run

# Run tests
flutter test
```

## Documentation

- [ARCHITECTURE.md](documentation/ARCHITECTURE.md) — System architecture and design decisions
- [PROJECT_SETUP.md](documentation/PROJECT_SETUP.md) — Environment setup guide
- [DATABASE.md](documentation/DATABASE.md) — Database schema and ERD
- [3D_PIPELINE.md](documentation/3D_PIPELINE.md) — 3D asset pipeline
- [AI_ARCHITECTURE.md](documentation/AI_ARCHITECTURE.md) — AI Coach architecture
- [SUBSCRIPTIONS.md](documentation/SUBSCRIPTIONS.md) — Monetization model
- [SECURITY.md](documentation/SECURITY.md) — Security practices
- [3D_ASSET_LICENSES.md](documentation/3D_ASSET_LICENSES.md) — 3D asset licensing

## Development Phases

See [PROJECT_ROADMAP.md](documentation/PROJECT_ROADMAP.md) for the full implementation roadmap.

## License

Proprietary. All rights reserved.
