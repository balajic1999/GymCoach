# Database Schema

## Overview

The database is hosted on Supabase (PostgreSQL) with Row-Level Security (RLS) enabled on all tables containing user data.

## Tables

### profiles

User profile and fitness preferences. Created automatically on auth signup via trigger.

| Column | Type | Constraints |
|--------|------|-------------|
| id | uuid | PK, FK → auth.users(id) |
| full_name | text | |
| avatar_url | text | |
| fitness_goal | text | CHECK (value IN goals) |
| experience_level | text | CHECK (value IN levels) |
| available_equipment | text[] | |
| workout_frequency | int | |
| preferred_duration_min | int | |
| training_location | text | |
| age_range | text | |
| subscription_tier | text | DEFAULT 'free' |
| onboarding_completed | boolean | DEFAULT false |
| created_at | timestamptz | DEFAULT now() |
| updated_at | timestamptz | DEFAULT now() |

### muscles

Standardized muscle taxonomy.

| Column | Type | Constraints |
|--------|------|-------------|
| id | uuid | PK, DEFAULT gen_random_uuid() |
| name | text | UNIQUE, NOT NULL |
| slug | text | UNIQUE, NOT NULL |
| muscle_group | text | NOT NULL |
| body_region | text | NOT NULL |
| description | text | |
| sort_order | int | DEFAULT 0 |

### equipment

Exercise equipment catalog.

| Column | Type | Constraints |
|--------|------|-------------|
| id | uuid | PK, DEFAULT gen_random_uuid() |
| name | text | UNIQUE, NOT NULL |
| slug | text | UNIQUE, NOT NULL |
| category | text | |
| description | text | |
| icon_url | text | |

### exercises

Core exercise catalog.

| Column | Type | Constraints |
|--------|------|-------------|
| id | uuid | PK, DEFAULT gen_random_uuid() |
| name | text | NOT NULL |
| slug | text | UNIQUE, NOT NULL |
| description | text | |
| category | text | NOT NULL |
| difficulty | text | CHECK (value IN difficulties) |
| instructions | text[] | |
| breathing | text | |
| common_mistakes | text[] | |
| safety_notes | text[] | |
| thumbnail_url | text | |
| animation_asset_url | text | |
| character_asset_url | text | |
| video_url | text | |
| default_sets | int | DEFAULT 3 |
| default_reps | int | DEFAULT 10 |
| default_rest_seconds | int | DEFAULT 60 |
| is_free | boolean | DEFAULT false |
| status | text | DEFAULT 'draft' |
| created_at | timestamptz | DEFAULT now() |
| updated_at | timestamptz | DEFAULT now() |

### exercise_muscles

Junction table: exercises ↔ muscles.

| Column | Type | Constraints |
|--------|------|-------------|
| id | uuid | PK |
| exercise_id | uuid | FK → exercises(id) ON DELETE CASCADE |
| muscle_id | uuid | FK → muscles(id) ON DELETE CASCADE |
| role | text | CHECK (value IN ('primary', 'secondary')) |

UNIQUE(exercise_id, muscle_id)

### exercise_equipment

Junction table: exercises ↔ equipment.

| Column | Type | Constraints |
|--------|------|-------------|
| id | uuid | PK |
| exercise_id | uuid | FK → exercises(id) ON DELETE CASCADE |
| equipment_id | uuid | FK → equipment(id) ON DELETE CASCADE |
| is_primary | boolean | DEFAULT true |

### workouts

User-created or AI-generated workout plans.

| Column | Type | Constraints |
|--------|------|-------------|
| id | uuid | PK |
| user_id | uuid | FK → auth.users(id) ON DELETE CASCADE |
| name | text | NOT NULL |
| description | text | |
| type | text | |
| difficulty | text | |
| estimated_duration_min | int | |
| is_ai_generated | boolean | DEFAULT false |
| created_at | timestamptz | DEFAULT now() |
| updated_at | timestamptz | DEFAULT now() |

### workout_exercises

Exercises within a workout plan.

| Column | Type | Constraints |
|--------|------|-------------|
| id | uuid | PK |
| workout_id | uuid | FK → workouts(id) ON DELETE CASCADE |
| exercise_id | uuid | FK → exercises(id) |
| sort_order | int | NOT NULL |
| sets | int | DEFAULT 3 |
| reps | int | DEFAULT 10 |
| rest_seconds | int | DEFAULT 60 |
| notes | text | |

### workout_sessions

Records of completed workout executions.

| Column | Type | Constraints |
|--------|------|-------------|
| id | uuid | PK |
| user_id | uuid | FK → auth.users(id) ON DELETE CASCADE |
| workout_id | uuid | FK → workouts(id) |
| started_at | timestamptz | NOT NULL |
| completed_at | timestamptz | |
| duration_seconds | int | |
| status | text | DEFAULT 'in_progress' |
| notes | text | |

### workout_sets

Individual set records within a session.

| Column | Type | Constraints |
|--------|------|-------------|
| id | uuid | PK |
| session_id | uuid | FK → workout_sessions(id) ON DELETE CASCADE |
| exercise_id | uuid | FK → exercises(id) |
| set_number | int | NOT NULL |
| weight_kg | float | |
| reps_completed | int | |
| duration_seconds | int | |
| is_warmup | boolean | DEFAULT false |
| notes | text | |
| completed_at | timestamptz | DEFAULT now() |

### favorites

User exercise favorites.

| Column | Type | Constraints |
|--------|------|-------------|
| id | uuid | PK |
| user_id | uuid | FK → auth.users(id) ON DELETE CASCADE |
| exercise_id | uuid | FK → exercises(id) ON DELETE CASCADE |
| created_at | timestamptz | DEFAULT now() |

UNIQUE(user_id, exercise_id)

### ai_conversations

AI Coach conversation threads.

| Column | Type | Constraints |
|--------|------|-------------|
| id | uuid | PK |
| user_id | uuid | FK → auth.users(id) ON DELETE CASCADE |
| title | text | |
| created_at | timestamptz | DEFAULT now() |
| updated_at | timestamptz | DEFAULT now() |

### ai_messages

Individual messages within AI conversations.

| Column | Type | Constraints |
|--------|------|-------------|
| id | uuid | PK |
| conversation_id | uuid | FK → ai_conversations(id) ON DELETE CASCADE |
| role | text | CHECK (value IN ('user', 'assistant', 'system')) |
| content | text | NOT NULL |
| metadata | jsonb | |
| created_at | timestamptz | DEFAULT now() |

### subscriptions

Subscription records synced from RevenueCat.

| Column | Type | Constraints |
|--------|------|-------------|
| id | uuid | PK |
| user_id | uuid | FK → auth.users(id) ON DELETE CASCADE |
| provider_id | text | |
| plan_id | text | |
| status | text | NOT NULL |
| started_at | timestamptz | |
| expires_at | timestamptz | |
| cancelled_at | timestamptz | |
| created_at | timestamptz | DEFAULT now() |

## Row-Level Security Policies

All user-data tables enforce RLS:

- **profiles**: Users can only read/update their own profile
- **workouts**: Users can only CRUD their own workouts
- **workout_sessions**: Users can only CRUD their own sessions
- **workout_sets**: Users can only CRUD sets in their own sessions
- **favorites**: Users can only CRUD their own favorites
- **ai_conversations**: Users can only CRUD their own conversations
- **ai_messages**: Users can only CRUD messages in their own conversations
- **subscriptions**: Users can only read their own subscription
- **exercises**: All authenticated users can read published exercises
- **muscles**: All authenticated users can read
- **equipment**: All authenticated users can read

## Indexes

- `exercises(category)` — Category filter
- `exercises(difficulty)` — Difficulty filter
- `exercises(status)` — Status filter (published only)
- `exercises(slug)` — Unique slug lookup
- `exercise_muscles(exercise_id)` — Join performance
- `exercise_muscles(muscle_id)` — Reverse lookup
- `workout_sessions(user_id, started_at)` — User history
- `workout_sets(session_id)` — Session sets lookup
- `favorites(user_id)` — User favorites
- `ai_messages(conversation_id, created_at)` — Message ordering
