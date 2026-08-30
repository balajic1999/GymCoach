-- ============================================================
-- Gym3D Database Migration
-- Version: 001_initial_schema
-- Description: Complete database schema for Gym3D AI Personal Trainer
-- ============================================================

-- Enable UUID generation
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================================
-- MUSCLES TABLE
-- ============================================================
CREATE TABLE muscles (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT UNIQUE NOT NULL,
  slug TEXT UNIQUE NOT NULL,
  muscle_group TEXT NOT NULL,
  body_region TEXT NOT NULL CHECK (body_region IN ('upper', 'core', 'lower')),
  description TEXT,
  sort_order INT DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT now() NOT NULL
);

CREATE INDEX idx_muscles_muscle_group ON muscles(muscle_group);
CREATE INDEX idx_muscles_body_region ON muscles(body_region);

-- ============================================================
-- EQUIPMENT TABLE
-- ============================================================
CREATE TABLE equipment (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT UNIQUE NOT NULL,
  slug TEXT UNIQUE NOT NULL,
  category TEXT CHECK (category IN ('free_weights', 'machines', 'bodyweight', 'cables', 'bands', 'other')),
  description TEXT,
  icon_url TEXT,
  created_at TIMESTAMPTZ DEFAULT now() NOT NULL
);

-- ============================================================
-- EXERCISES TABLE
-- ============================================================
CREATE TABLE exercises (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL,
  slug TEXT UNIQUE NOT NULL,
  description TEXT,
  category TEXT NOT NULL CHECK (category IN ('chest', 'back', 'legs', 'shoulders', 'arms', 'core', 'cardio', 'full_body', 'mobility')),
  difficulty TEXT NOT NULL CHECK (difficulty IN ('beginner', 'intermediate', 'advanced')),
  instructions TEXT[] DEFAULT '{}',
  breathing TEXT,
  common_mistakes TEXT[] DEFAULT '{}',
  safety_notes TEXT[] DEFAULT '{}',
  thumbnail_url TEXT,
  animation_asset_url TEXT,
  character_asset_url TEXT,
  video_url TEXT,
  default_sets INT DEFAULT 3,
  default_reps INT DEFAULT 10,
  default_rest_seconds INT DEFAULT 60,
  is_free BOOLEAN DEFAULT false,
  status TEXT DEFAULT 'published' CHECK (status IN ('draft', 'review', 'approved', 'published', 'rejected')),
  created_at TIMESTAMPTZ DEFAULT now() NOT NULL,
  updated_at TIMESTAMPTZ DEFAULT now() NOT NULL
);

CREATE INDEX idx_exercises_category ON exercises(category);
CREATE INDEX idx_exercises_difficulty ON exercises(difficulty);
CREATE INDEX idx_exercises_status ON exercises(status);
CREATE INDEX idx_exercises_slug ON exercises(slug);

-- ============================================================
-- EXERCISE_MUSCLES JUNCTION TABLE
-- ============================================================
CREATE TABLE exercise_muscles (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  exercise_id UUID NOT NULL REFERENCES exercises(id) ON DELETE CASCADE,
  muscle_id UUID NOT NULL REFERENCES muscles(id) ON DELETE CASCADE,
  role TEXT NOT NULL CHECK (role IN ('primary', 'secondary')),
  UNIQUE(exercise_id, muscle_id)
);

CREATE INDEX idx_exercise_muscles_exercise ON exercise_muscles(exercise_id);
CREATE INDEX idx_exercise_muscles_muscle ON exercise_muscles(muscle_id);

-- ============================================================
-- EXERCISE_EQUIPMENT JUNCTION TABLE
-- ============================================================
CREATE TABLE exercise_equipment (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  exercise_id UUID NOT NULL REFERENCES exercises(id) ON DELETE CASCADE,
  equipment_id UUID NOT NULL REFERENCES equipment(id) ON DELETE CASCADE,
  is_primary BOOLEAN DEFAULT true,
  UNIQUE(exercise_id, equipment_id)
);

CREATE INDEX idx_exercise_equipment_exercise ON exercise_equipment(exercise_id);

-- ============================================================
-- PROFILES TABLE (extends auth.users)
-- ============================================================
CREATE TABLE profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  full_name TEXT,
  avatar_url TEXT,
  fitness_goal TEXT CHECK (fitness_goal IN ('build_muscle', 'lose_fat', 'improve_strength', 'general_fitness', 'improve_endurance', 'mobility')),
  experience_level TEXT CHECK (experience_level IN ('beginner', 'intermediate', 'advanced')),
  available_equipment TEXT[] DEFAULT '{}',
  workout_frequency INT CHECK (workout_frequency >= 0 AND workout_frequency <= 7),
  preferred_duration_min INT CHECK (preferred_duration_min >= 10 AND preferred_duration_min <= 180),
  training_location TEXT CHECK (training_location IN ('home', 'gym', 'outdoor', 'mixed')),
  age_range TEXT CHECK (age_range IN ('18-24', '25-34', '35-44', '45-54', '55-64', '65+')),
  subscription_tier TEXT DEFAULT 'free' CHECK (subscription_tier IN ('free', 'pro')),
  onboarding_completed BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT now() NOT NULL,
  updated_at TIMESTAMPTZ DEFAULT now() NOT NULL
);

-- ============================================================
-- WORKOUTS TABLE
-- ============================================================
CREATE TABLE workouts (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  description TEXT,
  type TEXT CHECK (type IN ('strength', 'hypertrophy', 'endurance', 'cardio', 'flexibility', 'custom')),
  difficulty TEXT CHECK (difficulty IN ('beginner', 'intermediate', 'advanced')),
  estimated_duration_min INT,
  is_ai_generated BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT now() NOT NULL,
  updated_at TIMESTAMPTZ DEFAULT now() NOT NULL
);

CREATE INDEX idx_workouts_user ON workouts(user_id);

-- ============================================================
-- WORKOUT_EXERCISES TABLE
-- ============================================================
CREATE TABLE workout_exercises (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  workout_id UUID NOT NULL REFERENCES workouts(id) ON DELETE CASCADE,
  exercise_id UUID NOT NULL REFERENCES exercises(id),
  sort_order INT NOT NULL,
  sets INT DEFAULT 3,
  reps INT DEFAULT 10,
  rest_seconds INT DEFAULT 60,
  notes TEXT
);

CREATE INDEX idx_workout_exercises_workout ON workout_exercises(workout_id);

-- ============================================================
-- WORKOUT_SESSIONS TABLE
-- ============================================================
CREATE TABLE workout_sessions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  workout_id UUID REFERENCES workouts(id),
  started_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  completed_at TIMESTAMPTZ,
  duration_seconds INT,
  status TEXT DEFAULT 'in_progress' CHECK (status IN ('in_progress', 'completed', 'cancelled')),
  notes TEXT
);

CREATE INDEX idx_workout_sessions_user ON workout_sessions(user_id, started_at DESC);

-- ============================================================
-- WORKOUT_SETS TABLE
-- ============================================================
CREATE TABLE workout_sets (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  session_id UUID NOT NULL REFERENCES workout_sessions(id) ON DELETE CASCADE,
  exercise_id UUID NOT NULL REFERENCES exercises(id),
  set_number INT NOT NULL,
  weight_kg REAL,
  reps_completed INT,
  duration_seconds INT,
  is_warmup BOOLEAN DEFAULT false,
  notes TEXT,
  completed_at TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX idx_workout_sets_session ON workout_sets(session_id);

-- ============================================================
-- FAVORITES TABLE
-- ============================================================
CREATE TABLE favorites (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  exercise_id UUID NOT NULL REFERENCES exercises(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ DEFAULT now() NOT NULL,
  UNIQUE(user_id, exercise_id)
);

CREATE INDEX idx_favorites_user ON favorites(user_id);

-- ============================================================
-- AI_CONVERSATIONS TABLE
-- ============================================================
CREATE TABLE ai_conversations (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  title TEXT,
  created_at TIMESTAMPTZ DEFAULT now() NOT NULL,
  updated_at TIMESTAMPTZ DEFAULT now() NOT NULL
);

CREATE INDEX idx_ai_conversations_user ON ai_conversations(user_id);

-- ============================================================
-- AI_MESSAGES TABLE
-- ============================================================
CREATE TABLE ai_messages (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  conversation_id UUID NOT NULL REFERENCES ai_conversations(id) ON DELETE CASCADE,
  role TEXT NOT NULL CHECK (role IN ('user', 'assistant', 'system')),
  content TEXT NOT NULL,
  metadata JSONB,
  created_at TIMESTAMPTZ DEFAULT now() NOT NULL
);

CREATE INDEX idx_ai_messages_conversation ON ai_messages(conversation_id, created_at);

-- ============================================================
-- SUBSCRIPTIONS TABLE
-- ============================================================
CREATE TABLE subscriptions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  provider_id TEXT,
  plan_id TEXT,
  status TEXT NOT NULL CHECK (status IN ('active', 'expired', 'cancelled', 'trial', 'grace_period')),
  started_at TIMESTAMPTZ,
  expires_at TIMESTAMPTZ,
  cancelled_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT now() NOT NULL
);

CREATE INDEX idx_subscriptions_user ON subscriptions(user_id);

-- ============================================================
-- AUTO-CREATE PROFILE ON SIGNUP
-- ============================================================
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id)
  VALUES (NEW.id);
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- ============================================================
-- AUTO-UPDATE updated_at
-- ============================================================
CREATE OR REPLACE FUNCTION public.update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_profiles_updated_at
  BEFORE UPDATE ON profiles FOR EACH ROW EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER update_exercises_updated_at
  BEFORE UPDATE ON exercises FOR EACH ROW EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER update_workouts_updated_at
  BEFORE UPDATE ON workouts FOR EACH ROW EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER update_ai_conversations_updated_at
  BEFORE UPDATE ON ai_conversations FOR EACH ROW EXECUTE FUNCTION update_updated_at();
