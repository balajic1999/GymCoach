-- ============================================================
-- Gym3D Row-Level Security Policies
-- Run AFTER 001_initial_schema.sql
-- ============================================================

-- Enable RLS on all user-data tables
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE workouts ENABLE ROW LEVEL SECURITY;
ALTER TABLE workout_exercises ENABLE ROW LEVEL SECURITY;
ALTER TABLE workout_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE workout_sets ENABLE ROW LEVEL SECURITY;
ALTER TABLE favorites ENABLE ROW LEVEL SECURITY;
ALTER TABLE ai_conversations ENABLE ROW LEVEL SECURITY;
ALTER TABLE ai_messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE subscriptions ENABLE ROW LEVEL SECURITY;

-- Public read tables (no RLS needed for read, but enable for safety)
ALTER TABLE exercises ENABLE ROW LEVEL SECURITY;
ALTER TABLE muscles ENABLE ROW LEVEL SECURITY;
ALTER TABLE equipment ENABLE ROW LEVEL SECURITY;
ALTER TABLE exercise_muscles ENABLE ROW LEVEL SECURITY;
ALTER TABLE exercise_equipment ENABLE ROW LEVEL SECURITY;

-- ============================================================
-- PROFILES
-- ============================================================
CREATE POLICY "Users can view own profile"
  ON profiles FOR SELECT
  USING (auth.uid() = id);

CREATE POLICY "Users can update own profile"
  ON profiles FOR UPDATE
  USING (auth.uid() = id)
  WITH CHECK (auth.uid() = id);

-- Profile is created by trigger, no INSERT policy needed for users

-- ============================================================
-- EXERCISES (public read for authenticated users)
-- ============================================================
CREATE POLICY "Authenticated users can view published exercises"
  ON exercises FOR SELECT
  TO authenticated
  USING (status = 'published');

-- ============================================================
-- MUSCLES (public read)
-- ============================================================
CREATE POLICY "Authenticated users can view muscles"
  ON muscles FOR SELECT
  TO authenticated
  USING (true);

-- ============================================================
-- EQUIPMENT (public read)
-- ============================================================
CREATE POLICY "Authenticated users can view equipment"
  ON equipment FOR SELECT
  TO authenticated
  USING (true);

-- ============================================================
-- EXERCISE_MUSCLES (public read)
-- ============================================================
CREATE POLICY "Authenticated users can view exercise muscles"
  ON exercise_muscles FOR SELECT
  TO authenticated
  USING (true);

-- ============================================================
-- EXERCISE_EQUIPMENT (public read)
-- ============================================================
CREATE POLICY "Authenticated users can view exercise equipment"
  ON exercise_equipment FOR SELECT
  TO authenticated
  USING (true);

-- ============================================================
-- WORKOUTS
-- ============================================================
CREATE POLICY "Users can view own workouts"
  ON workouts FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can create own workouts"
  ON workouts FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own workouts"
  ON workouts FOR UPDATE
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete own workouts"
  ON workouts FOR DELETE
  USING (auth.uid() = user_id);

-- ============================================================
-- WORKOUT_EXERCISES
-- ============================================================
CREATE POLICY "Users can view exercises in own workouts"
  ON workout_exercises FOR SELECT
  USING (EXISTS (
    SELECT 1 FROM workouts WHERE workouts.id = workout_exercises.workout_id AND workouts.user_id = auth.uid()
  ));

CREATE POLICY "Users can add exercises to own workouts"
  ON workout_exercises FOR INSERT
  WITH CHECK (EXISTS (
    SELECT 1 FROM workouts WHERE workouts.id = workout_exercises.workout_id AND workouts.user_id = auth.uid()
  ));

CREATE POLICY "Users can update exercises in own workouts"
  ON workout_exercises FOR UPDATE
  USING (EXISTS (
    SELECT 1 FROM workouts WHERE workouts.id = workout_exercises.workout_id AND workouts.user_id = auth.uid()
  ));

CREATE POLICY "Users can remove exercises from own workouts"
  ON workout_exercises FOR DELETE
  USING (EXISTS (
    SELECT 1 FROM workouts WHERE workouts.id = workout_exercises.workout_id AND workouts.user_id = auth.uid()
  ));

-- ============================================================
-- WORKOUT_SESSIONS
-- ============================================================
CREATE POLICY "Users can view own sessions"
  ON workout_sessions FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can create own sessions"
  ON workout_sessions FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own sessions"
  ON workout_sessions FOR UPDATE
  USING (auth.uid() = user_id);

-- ============================================================
-- WORKOUT_SETS
-- ============================================================
CREATE POLICY "Users can view own sets"
  ON workout_sets FOR SELECT
  USING (EXISTS (
    SELECT 1 FROM workout_sessions WHERE workout_sessions.id = workout_sets.session_id AND workout_sessions.user_id = auth.uid()
  ));

CREATE POLICY "Users can create own sets"
  ON workout_sets FOR INSERT
  WITH CHECK (EXISTS (
    SELECT 1 FROM workout_sessions WHERE workout_sessions.id = workout_sets.session_id AND workout_sessions.user_id = auth.uid()
  ));

CREATE POLICY "Users can update own sets"
  ON workout_sets FOR UPDATE
  USING (EXISTS (
    SELECT 1 FROM workout_sessions WHERE workout_sessions.id = workout_sets.session_id AND workout_sessions.user_id = auth.uid()
  ));

-- ============================================================
-- FAVORITES
-- ============================================================
CREATE POLICY "Users can view own favorites"
  ON favorites FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can create own favorites"
  ON favorites FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete own favorites"
  ON favorites FOR DELETE
  USING (auth.uid() = user_id);

-- ============================================================
-- AI_CONVERSATIONS
-- ============================================================
CREATE POLICY "Users can view own conversations"
  ON ai_conversations FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can create own conversations"
  ON ai_conversations FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete own conversations"
  ON ai_conversations FOR DELETE
  USING (auth.uid() = user_id);

-- ============================================================
-- AI_MESSAGES
-- ============================================================
CREATE POLICY "Users can view messages in own conversations"
  ON ai_messages FOR SELECT
  USING (EXISTS (
    SELECT 1 FROM ai_conversations WHERE ai_conversations.id = ai_messages.conversation_id AND ai_conversations.user_id = auth.uid()
  ));

CREATE POLICY "Users can create messages in own conversations"
  ON ai_messages FOR INSERT
  WITH CHECK (EXISTS (
    SELECT 1 FROM ai_conversations WHERE ai_conversations.id = ai_messages.conversation_id AND ai_conversations.user_id = auth.uid()
  ));

-- ============================================================
-- SUBSCRIPTIONS
-- ============================================================
CREATE POLICY "Users can view own subscription"
  ON subscriptions FOR SELECT
  USING (auth.uid() = user_id);

-- Subscription INSERT/UPDATE only via Edge Functions (service role)
