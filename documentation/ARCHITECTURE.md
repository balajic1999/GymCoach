# Architecture

## System Overview

Gym3D AI Personal Trainer is a cross-platform mobile application built with Flutter targeting Android and iOS. The system follows a layered architecture with clean separation between presentation, domain, and data layers.

## Architecture Decisions

### ADR-001: Flutter over Native

**Decision**: Use Flutter for cross-platform development.

**Rationale**: Single codebase for Android/iOS, mature 3D rendering support via platform views, strong typing with Dart, rapid development cycle.

### ADR-002: flutter_3d_controller over Unity

**Decision**: Use `flutter_3d_controller` (Google model-viewer) for 3D rendering instead of Unity.

**Rationale**:
- Eliminates 80-150MB build size overhead
- No Unity license costs
- Simpler build pipeline
- GLB/glTF is the web-standard 3D format
- Sufficient for exercise demonstration (not a game)
- Unity integration can be added later as a separate module if needed

### ADR-003: Riverpod for State Management

**Decision**: Use `flutter_riverpod` over BLoC or Provider.

**Rationale**:
- Compile-safe dependency injection
- No BuildContext dependency for state access
- Auto-dispose for 3D asset memory management
- Excellent testability
- Type-safe providers

### ADR-004: Feature-First Organization

**Decision**: Organize code by feature rather than by layer.

**Rationale**: Each feature (exercises, workouts, AI coach) is self-contained with its own data/domain/presentation layers. Reduces coupling, improves discoverability, scales well.

### ADR-005: Supabase Backend

**Decision**: Use Supabase for backend services.

**Rationale**: PostgreSQL with RLS for security, built-in auth, storage, edge functions, real-time capabilities. Avoids building custom backend infrastructure.

### ADR-006: Server-Side AI

**Decision**: Route all AI requests through Supabase Edge Functions.

**Rationale**: Keeps API keys server-side, enables rate limiting, allows provider switching without app updates, enables content filtering.

### ADR-007: RevenueCat for Subscriptions

**Decision**: Use RevenueCat for subscription management.

**Rationale**: Handles cross-platform subscription complexity, receipt validation, entitlement management, analytics. Industry standard for Flutter apps.

## Layer Architecture

```
┌──────────────────────────────────────────────┐
│              Presentation Layer               │
│  Screens │ Widgets │ Riverpod Providers       │
├──────────────────────────────────────────────┤
│                Domain Layer                   │
│  Services │ Entities │ Business Logic         │
├──────────────────────────────────────────────┤
│                 Data Layer                    │
│  Repositories │ Data Sources │ Models (DTO)   │
├──────────────────────────────────────────────┤
│              Infrastructure                   │
│  Supabase │ Local Storage │ 3D Engine │ AI    │
└──────────────────────────────────────────────┘
```

## Data Flow

1. **UI** dispatches action via Riverpod provider
2. **Provider** calls service method
3. **Service** executes business logic, calls repository
4. **Repository** fetches from remote (Supabase) or local (Hive) data source
5. **Data Source** returns raw data
6. **Repository** maps DTO to domain entity
7. **Provider** updates state
8. **UI** rebuilds

## Navigation

GoRouter with shell routes for bottom navigation:

```
/                    → Home
/exercises           → Exercise Library
/exercises/:id       → Exercise Detail (with 3D viewer)
/workouts            → Workout List
/workouts/create     → Create Workout
/workouts/:id/run    → Workout Execution
/progress            → Progress Dashboard
/ai-coach            → AI Coach Chat
/profile             → User Profile
/onboarding          → Onboarding Flow
/auth                → Authentication
/paywall             → Subscription Paywall
```

## Module Dependency Rules

1. Features may depend on `core/` but NOT on other features
2. `presentation/` depends on `domain/` but NOT on `data/`
3. `domain/` has NO dependencies on `presentation/` or `data/`
4. `data/` implements interfaces defined in `domain/`
5. Cross-feature communication happens through shared services in `core/`
