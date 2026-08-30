-- ============================================================
-- Gym3D Seed Data
-- Run AFTER 001_initial_schema.sql and 002_rls_policies.sql
-- ============================================================

-- ============================================================
-- MUSCLES (19 muscles)
-- ============================================================
INSERT INTO muscles (name, slug, muscle_group, body_region, description, sort_order) VALUES
  ('Chest', 'chest', 'Chest', 'upper', 'The pectoralis major, the primary muscle of the chest responsible for pushing movements.', 1),
  ('Upper Chest', 'upper-chest', 'Chest', 'upper', 'The clavicular head of the pectoralis major, targeted by incline movements.', 2),
  ('Lower Chest', 'lower-chest', 'Chest', 'upper', 'The sternal head of the pectoralis major, targeted by decline and flat movements.', 3),
  ('Front Deltoid', 'front-deltoid', 'Shoulders', 'upper', 'The anterior head of the deltoid, involved in pressing and front raising movements.', 4),
  ('Side Deltoid', 'side-deltoid', 'Shoulders', 'upper', 'The lateral head of the deltoid, responsible for shoulder abduction.', 5),
  ('Rear Deltoid', 'rear-deltoid', 'Shoulders', 'upper', 'The posterior head of the deltoid, involved in pulling and external rotation.', 6),
  ('Biceps', 'biceps', 'Arms', 'upper', 'The biceps brachii, responsible for elbow flexion and forearm supination.', 7),
  ('Triceps', 'triceps', 'Arms', 'upper', 'The triceps brachii, the primary elbow extensor located at the back of the upper arm.', 8),
  ('Forearms', 'forearms', 'Arms', 'upper', 'The forearm muscles responsible for grip strength and wrist movements.', 9),
  ('Lats', 'lats', 'Back', 'upper', 'The latissimus dorsi, the widest muscle of the back responsible for pulling movements.', 10),
  ('Traps', 'traps', 'Back', 'upper', 'The trapezius muscle spanning the upper back and neck, involved in scapular movement.', 11),
  ('Rhomboids', 'rhomboids', 'Back', 'upper', 'Deep muscles between the shoulder blades responsible for scapular retraction.', 12),
  ('Lower Back', 'lower-back', 'Back', 'core', 'The erector spinae group running along the spine, critical for posture and spinal extension.', 13),
  ('Abs', 'abs', 'Core', 'core', 'The rectus abdominis, the primary muscle of the anterior core responsible for trunk flexion.', 14),
  ('Obliques', 'obliques', 'Core', 'core', 'The internal and external obliques, responsible for trunk rotation and lateral flexion.', 15),
  ('Glutes', 'glutes', 'Legs', 'lower', 'The gluteus maximus, the largest muscle in the body responsible for hip extension.', 16),
  ('Quadriceps', 'quadriceps', 'Legs', 'lower', 'The four-headed muscle group on the front of the thigh responsible for knee extension.', 17),
  ('Hamstrings', 'hamstrings', 'Legs', 'lower', 'The muscle group on the posterior thigh responsible for knee flexion and hip extension.', 18),
  ('Calves', 'calves', 'Legs', 'lower', 'The gastrocnemius and soleus muscles of the lower leg responsible for ankle plantarflexion.', 19);

-- ============================================================
-- EQUIPMENT (10 items)
-- ============================================================
INSERT INTO equipment (name, slug, category, description) VALUES
  ('Barbell', 'barbell', 'free_weights', 'A long bar designed to hold weight plates on each end for bilateral exercises.'),
  ('Dumbbells', 'dumbbells', 'free_weights', 'Short-handled weights used individually or in pairs for unilateral and bilateral exercises.'),
  ('Bodyweight', 'bodyweight', 'bodyweight', 'No equipment required — exercises performed using only body resistance.'),
  ('Cable Machine', 'cable-machine', 'cables', 'A pulley-based machine providing constant tension throughout the range of motion.'),
  ('Pull-up Bar', 'pull-up-bar', 'bodyweight', 'A horizontal bar mounted at height for hanging and pulling exercises.'),
  ('Bench', 'bench', 'other', 'A flat or adjustable bench used for pressing, rowing, and support exercises.'),
  ('Leg Press Machine', 'leg-press-machine', 'machines', 'A seated machine for lower body pressing movements.'),
  ('Leg Extension Machine', 'leg-extension-machine', 'machines', 'An isolation machine targeting the quadriceps through knee extension.'),
  ('Lat Pulldown Machine', 'lat-pulldown-machine', 'machines', 'A cable-based machine for vertical pulling movements targeting the lats.'),
  ('EZ Curl Bar', 'ez-curl-bar', 'free_weights', 'A curved barbell designed to reduce wrist strain during curling movements.');

-- ============================================================
-- EXERCISES (21 exercises)
-- ============================================================

-- CHEST
INSERT INTO exercises (name, slug, category, difficulty, description, instructions, breathing, common_mistakes, safety_notes, default_sets, default_reps, default_rest_seconds, is_free) VALUES
(
  'Bench Press', 'bench-press', 'chest', 'intermediate',
  'The bench press is a fundamental upper body compound exercise targeting the chest, shoulders, and triceps. It is one of the most effective exercises for building upper body pressing strength.',
  ARRAY['Lie flat on the bench with your eyes under the bar.', 'Grip the bar slightly wider than shoulder-width apart.', 'Unrack the bar and position it directly above your chest.', 'Lower the bar with control to your mid-chest.', 'Press the bar back up to the starting position, fully extending your arms.'],
  'Inhale as you lower the bar to your chest. Exhale forcefully as you press the bar upward.',
  ARRAY['Bouncing the bar off the chest — lower with control.', 'Flaring elbows to 90 degrees — keep them at roughly 45-75 degrees.', 'Lifting hips off the bench — maintain contact with the bench.', 'Not using a spotter for heavy sets.'],
  ARRAY['Always use a spotter when lifting heavy.', 'Use collars to secure weight plates.', 'Start with lighter weight to warm up.'],
  3, 10, 90, true
),
(
  'Incline Bench Press', 'incline-bench-press', 'chest', 'intermediate',
  'The incline bench press targets the upper portion of the chest and front deltoids. Setting the bench to approximately 30-45 degrees emphasizes the clavicular head of the pectoralis major.',
  ARRAY['Set the bench to a 30-45 degree incline.', 'Lie back and grip the bar slightly wider than shoulder-width.', 'Unrack and position the bar above your upper chest.', 'Lower the bar to your upper chest with control.', 'Press the bar back up to full extension.'],
  'Inhale as you lower the bar. Exhale as you press up.',
  ARRAY['Setting the incline too steep — this shifts work to shoulders.', 'Not retracting shoulder blades — squeeze them together.', 'Pressing the bar too far forward over your face.'],
  ARRAY['Use a spotter for heavy sets.', 'Ensure the bench is securely locked at the desired angle.'],
  3, 10, 90, false
),
(
  'Push Up', 'push-up', 'chest', 'beginner',
  'The push-up is a bodyweight compound exercise that builds chest, shoulder, and tricep strength. It also engages the core for stability. No equipment is needed, making it accessible anywhere.',
  ARRAY['Start in a high plank position with hands slightly wider than shoulder-width.', 'Keep your body in a straight line from head to heels.', 'Lower your body by bending your elbows until your chest nearly touches the floor.', 'Push through your palms to return to the starting position.', 'Keep your core tight throughout the movement.'],
  'Inhale as you lower your body down. Exhale as you push back up.',
  ARRAY['Sagging hips — engage your core to maintain a straight line.', 'Flaring elbows out to the sides — keep them at 45 degrees.', 'Not going through full range of motion.', 'Leading with your chin instead of your chest.'],
  ARRAY['If standard push-ups are too difficult, start with knee push-ups or incline push-ups.'],
  3, 12, 60, true
),
(
  'Dumbbell Fly', 'dumbbell-fly', 'chest', 'intermediate',
  'The dumbbell fly is an isolation exercise that stretches and contracts the chest muscles through a wide arc of motion. It effectively targets the pectoralis major with emphasis on the stretch.',
  ARRAY['Lie on a flat bench holding a dumbbell in each hand above your chest.', 'Keep a slight bend in your elbows throughout the movement.', 'Lower the dumbbells out to your sides in a wide arc until you feel a stretch in your chest.', 'Squeeze your chest to bring the dumbbells back together above your chest.', 'Maintain the same elbow angle throughout.'],
  'Inhale as you open your arms. Exhale as you bring the dumbbells together.',
  ARRAY['Using too much weight — this is an isolation movement, control matters.', 'Straightening the arms completely — maintain a slight elbow bend.', 'Going too deep — stop when you feel a comfortable stretch.'],
  ARRAY['Use a weight you can control through the full range of motion.', 'Avoid excessive depth if you have shoulder issues.'],
  3, 12, 60, false
);

-- BACK
INSERT INTO exercises (name, slug, category, difficulty, description, instructions, breathing, common_mistakes, safety_notes, default_sets, default_reps, default_rest_seconds, is_free) VALUES
(
  'Deadlift', 'deadlift', 'back', 'advanced',
  'The deadlift is one of the most effective full-body compound exercises. It primarily targets the posterior chain including the lower back, glutes, and hamstrings while also engaging the traps, lats, and grip.',
  ARRAY['Stand with feet hip-width apart, bar over mid-foot.', 'Hinge at the hips and grip the bar just outside your knees.', 'Keep your chest up, shoulders back, and spine neutral.', 'Drive through your heels, extending your hips and knees simultaneously.', 'Stand fully upright, squeezing your glutes at the top.', 'Lower the bar by hinging at the hips first, then bending the knees.'],
  'Take a deep breath and brace your core before the pull. Exhale at the top of the movement.',
  ARRAY['Rounding the lower back — maintain a neutral spine throughout.', 'Jerking the bar off the floor — build tension before pulling.', 'Leaning back excessively at the top — stand straight, do not hyperextend.', 'Letting the bar drift away from the body — keep it close.'],
  ARRAY['Master the hip hinge pattern with lighter weight before going heavy.', 'Consider using a belt for heavy sets.', 'If you have lower back issues, consult a professional before deadlifting.'],
  3, 5, 120, true
),
(
  'Lat Pulldown', 'lat-pulldown', 'back', 'beginner',
  'The lat pulldown is a machine-based exercise that targets the latissimus dorsi. It mimics the motion of a pull-up and is excellent for building back width.',
  ARRAY['Sit at the lat pulldown machine and adjust the thigh pad.', 'Grip the bar wider than shoulder-width with an overhand grip.', 'Lean back slightly and pull the bar down to your upper chest.', 'Squeeze your shoulder blades together at the bottom.', 'Slowly return the bar to the starting position with control.'],
  'Exhale as you pull the bar down. Inhale as you return to the start.',
  ARRAY['Pulling the bar behind the neck — always pull to the front.', 'Using momentum and swinging the body.', 'Gripping too narrow — use a wide grip for lat emphasis.', 'Not fully extending the arms at the top.'],
  ARRAY['Adjust the thigh pad to prevent your body from lifting.'],
  3, 12, 60, false
),
(
  'Pull Up', 'pull-up', 'back', 'intermediate',
  'The pull-up is a bodyweight compound exercise and one of the best indicators of relative upper body strength. It primarily targets the lats, rhomboids, and biceps.',
  ARRAY['Grip the bar with an overhand grip, hands slightly wider than shoulder-width.', 'Hang with arms fully extended, engaging your shoulders.', 'Pull your body up by driving your elbows down toward your hips.', 'Continue until your chin clears the bar.', 'Lower yourself with control to the starting position.'],
  'Exhale as you pull up. Inhale as you lower down.',
  ARRAY['Using excessive kipping or swinging — maintain control.', 'Not going through full range of motion.', 'Shrugging shoulders to ears — keep them pulled down.', 'Crossing legs excessively — keep your body relatively straight.'],
  ARRAY['If you cannot do a full pull-up, use an assisted pull-up machine or resistance bands.'],
  3, 8, 90, true
),
(
  'Barbell Row', 'barbell-row', 'back', 'intermediate',
  'The barbell row is a compound pulling exercise that builds thickness in the upper and middle back. It targets the lats, rhomboids, traps, and rear deltoids.',
  ARRAY['Stand with feet hip-width apart, holding the barbell with an overhand grip.', 'Hinge forward at the hips until your torso is roughly 45 degrees to the floor.', 'Let the bar hang at arms length below your shoulders.', 'Pull the bar toward your lower chest, squeezing your shoulder blades together.', 'Lower the bar with control to the starting position.'],
  'Exhale as you row the bar up. Inhale as you lower it.',
  ARRAY['Rounding the lower back — maintain a neutral spine.', 'Standing too upright — maintain the hip hinge position.', 'Using momentum to swing the weight.', 'Pulling to the wrong position — aim for lower chest.'],
  ARRAY['Keep the weight manageable to maintain proper form.', 'Brace your core throughout the movement.'],
  3, 10, 90, false
);

-- LEGS
INSERT INTO exercises (name, slug, category, difficulty, description, instructions, breathing, common_mistakes, safety_notes, default_sets, default_reps, default_rest_seconds, is_free) VALUES
(
  'Squat', 'squat', 'legs', 'intermediate',
  'The barbell back squat is the king of lower body exercises. It targets the quadriceps, glutes, and hamstrings while engaging the core and lower back for stability.',
  ARRAY['Position the barbell on your upper traps, standing with feet shoulder-width apart.', 'Unrack the bar and step back into your squat stance.', 'Push your hips back and bend your knees to lower your body.', 'Keep your chest up, core braced, and knees tracking over your toes.', 'Descend until your thighs are at least parallel to the floor.', 'Drive through your full foot to stand back up to the starting position.'],
  'Inhale and brace your core as you lower down. Exhale as you drive up through your heels.',
  ARRAY['Knees caving inward — actively push knees out over toes.', 'Rounding the lower back — maintain a neutral spine.', 'Rising on toes — keep weight distributed across the full foot.', 'Not reaching adequate depth — aim for at least parallel.', 'Looking up or down excessively — keep a neutral head position.'],
  ARRAY['Use a squat rack with safety bars set at the appropriate height.', 'Start with lighter weight to perfect your form.', 'Consider using a belt for heavy sets.', 'Have a spotter for near-maximal attempts.'],
  4, 8, 120, true
),
(
  'Leg Press', 'leg-press', 'legs', 'beginner',
  'The leg press is a machine-based compound exercise that targets the quadriceps, glutes, and hamstrings. It allows you to load the legs heavily with reduced spinal load compared to squats.',
  ARRAY['Sit in the leg press machine with your back flat against the pad.', 'Place your feet shoulder-width apart on the platform.', 'Release the safety handles and lower the platform by bending your knees.', 'Lower until your knees are at approximately 90 degrees.', 'Push through your heels to extend your legs back to the starting position.', 'Do not fully lock out your knees at the top.'],
  'Inhale as you lower the platform. Exhale as you press up.',
  ARRAY['Locking out knees completely at the top — keep a slight bend.', 'Lifting hips off the seat — maintain contact with the backrest.', 'Placing feet too high or too low — shoulder width, middle of platform.', 'Going too deep and letting the lower back round.'],
  ARRAY['Always use the safety catches.', 'Start with a moderate weight to learn the machine.'],
  3, 12, 90, false
),
(
  'Lunges', 'lunges', 'legs', 'beginner',
  'Lunges are a unilateral lower body exercise that develops leg strength, balance, and coordination. They target the quadriceps, glutes, and hamstrings while challenging single-leg stability.',
  ARRAY['Stand upright with feet hip-width apart.', 'Step forward with one foot, landing heel first.', 'Lower your body until both knees are at approximately 90 degrees.', 'Your back knee should nearly touch the floor.', 'Push through your front heel to return to the standing position.', 'Alternate legs or complete all reps on one side.'],
  'Inhale as you step forward and lower. Exhale as you push back up.',
  ARRAY['Knee extending past the toes excessively — take a longer stride.', 'Leaning the torso too far forward — stay upright.', 'Not going deep enough — aim for 90-degree angles at both knees.'],
  ARRAY['Hold onto a wall or rack for balance if needed.', 'Start with bodyweight before adding dumbbells.'],
  3, 10, 60, true
),
(
  'Leg Extension', 'leg-extension', 'legs', 'beginner',
  'The leg extension is an isolation exercise that specifically targets the quadriceps. It is performed on a machine and is excellent for developing knee extension strength.',
  ARRAY['Sit on the leg extension machine with your back against the pad.', 'Adjust the pad so it rests on your lower shins, just above the ankles.', 'Grip the side handles for stability.', 'Extend your legs until they are almost straight.', 'Squeeze your quadriceps at the top for a moment.', 'Lower the weight with control back to the starting position.'],
  'Exhale as you extend your legs. Inhale as you lower.',
  ARRAY['Using momentum to swing the weight — control the movement.', 'Locking out the knees aggressively at the top.', 'Going too heavy and losing form.'],
  ARRAY['Avoid this exercise if you have existing knee issues without professional guidance.', 'Use a controlled tempo throughout.'],
  3, 12, 60, false
);

-- SHOULDERS
INSERT INTO exercises (name, slug, category, difficulty, description, instructions, breathing, common_mistakes, safety_notes, default_sets, default_reps, default_rest_seconds, is_free) VALUES
(
  'Shoulder Press', 'shoulder-press', 'shoulders', 'intermediate',
  'The overhead shoulder press is a compound pressing movement that develops shoulder strength and size. It targets all three heads of the deltoid with emphasis on the front and side deltoids.',
  ARRAY['Stand or sit with the barbell or dumbbells at shoulder height.', 'Grip the bar just outside shoulder-width.', 'Press the weight directly overhead until your arms are fully extended.', 'Keep your core tight and avoid excessive arching of the lower back.', 'Lower the weight back to shoulder height with control.'],
  'Exhale as you press overhead. Inhale as you lower the weight.',
  ARRAY['Arching the lower back excessively — brace your core.', 'Pressing the bar forward instead of straight up.', 'Not using full range of motion — press to full extension.', 'Flaring the elbows too wide.'],
  ARRAY['Consider a seated position to reduce lower back stress.', 'Start with lighter weight to master the movement pattern.'],
  3, 10, 90, true
),
(
  'Lateral Raise', 'lateral-raise', 'shoulders', 'beginner',
  'The lateral raise is an isolation exercise targeting the side deltoid. It is essential for building wider, more defined shoulders and creating the classic V-taper appearance.',
  ARRAY['Stand with feet shoulder-width apart, a dumbbell in each hand at your sides.', 'Keep a slight bend in your elbows throughout.', 'Raise the dumbbells out to your sides until your arms are parallel to the floor.', 'Hold briefly at the top, feeling the contraction in your side deltoids.', 'Lower the dumbbells slowly back to your sides.'],
  'Exhale as you raise the dumbbells. Inhale as you lower them.',
  ARRAY['Using too much weight and swinging — use a weight you can control.', 'Raising the dumbbells too high above shoulder level.', 'Shrugging the shoulders up — keep them depressed.', 'Leading the raise with the thumbs up — keep wrists neutral or slightly internally rotated.'],
  ARRAY['Start with light weight to learn proper form.'],
  3, 15, 60, false
),
(
  'Front Raise', 'front-raise', 'shoulders', 'beginner',
  'The front raise isolates the anterior (front) head of the deltoid. It is a straightforward exercise for building front shoulder definition.',
  ARRAY['Stand with feet shoulder-width apart holding dumbbells in front of your thighs.', 'Keep a slight bend in your elbows.', 'Raise one or both dumbbells directly in front of you to shoulder height.', 'Hold briefly at the top.', 'Lower with control back to the starting position.'],
  'Exhale as you raise the weight. Inhale as you lower it.',
  ARRAY['Swinging the body to generate momentum.', 'Raising the weight above shoulder height.', 'Using too much weight for proper form.'],
  ARRAY['This exercise places stress on the shoulder joint — use moderate weight.'],
  3, 12, 60, false
);

-- ARMS
INSERT INTO exercises (name, slug, category, difficulty, description, instructions, breathing, common_mistakes, safety_notes, default_sets, default_reps, default_rest_seconds, is_free) VALUES
(
  'Bicep Curl', 'bicep-curl', 'arms', 'beginner',
  'The bicep curl is the most popular isolation exercise for the biceps brachii. It builds arm size and strength through elbow flexion.',
  ARRAY['Stand with feet shoulder-width apart holding dumbbells at your sides with palms facing forward.', 'Keep your upper arms stationary against your body.', 'Curl the dumbbells up by flexing your elbows.', 'Squeeze your biceps at the top of the movement.', 'Lower the dumbbells with control back to the starting position.'],
  'Exhale as you curl up. Inhale as you lower.',
  ARRAY['Swinging the body or using momentum — keep your torso still.', 'Moving the elbows forward — keep upper arms pinned to your sides.', 'Not fully extending at the bottom — use complete range of motion.', 'Curling the wrists at the top — keep wrists neutral.'],
  ARRAY['Start with a weight you can curl with strict form.'],
  3, 12, 60, true
),
(
  'Hammer Curl', 'hammer-curl', 'arms', 'beginner',
  'The hammer curl targets the brachialis and brachioradialis in addition to the biceps. The neutral grip emphasizes different parts of the arm compared to standard curls.',
  ARRAY['Stand with feet shoulder-width apart holding dumbbells at your sides with palms facing each other (neutral grip).', 'Keep your upper arms stationary.', 'Curl the dumbbells up while maintaining the neutral grip throughout.', 'Squeeze at the top.', 'Lower with control.'],
  'Exhale as you curl up. Inhale as you lower.',
  ARRAY['Swinging the body — maintain strict form.', 'Rotating the wrists — keep the neutral grip.', 'Using elbows for momentum.'],
  ARRAY['Use appropriate weight for controlled repetitions.'],
  3, 12, 60, false
),
(
  'Tricep Pushdown', 'tricep-pushdown', 'arms', 'beginner',
  'The tricep pushdown is a cable isolation exercise that effectively targets all three heads of the triceps. It is a staple arm exercise in most training programs.',
  ARRAY['Stand facing a cable machine with a straight or V-bar attachment at the top.', 'Grip the bar with an overhand grip, hands shoulder-width apart.', 'Keep your upper arms pinned to your sides and elbows close to your body.', 'Push the bar down by extending your elbows until your arms are straight.', 'Squeeze your triceps at the bottom.', 'Slowly return to the starting position, controlling the weight.'],
  'Exhale as you push down. Inhale as you return to start.',
  ARRAY['Flaring elbows out — keep them tight to your body.', 'Leaning over the bar — stand upright.', 'Using body weight to push the bar down.', 'Not fully extending the arms at the bottom.'],
  ARRAY['Use a weight that allows full range of motion with control.'],
  3, 12, 60, false
),
(
  'Skull Crusher', 'skull-crusher', 'arms', 'intermediate',
  'The skull crusher, also known as the lying tricep extension, is an effective isolation exercise for building tricep mass. It targets all three heads of the triceps.',
  ARRAY['Lie flat on a bench holding an EZ bar or dumbbells with arms extended above your chest.', 'Keep your upper arms perpendicular to the floor.', 'Lower the weight toward your forehead by bending only at the elbows.', 'Stop just before the bar reaches your forehead.', 'Extend your elbows to press the weight back to the starting position.'],
  'Inhale as you lower the weight. Exhale as you extend.',
  ARRAY['Moving the upper arms — keep them stationary and vertical.', 'Going too heavy and losing control.', 'Lowering the weight to the wrong position.'],
  ARRAY['Use a spotter when using heavy weight.', 'Consider using an EZ curl bar to reduce wrist strain.', 'Start with lighter weight to master the movement.'],
  3, 10, 60, false
);

-- CORE
INSERT INTO exercises (name, slug, category, difficulty, description, instructions, breathing, common_mistakes, safety_notes, default_sets, default_reps, default_rest_seconds, is_free) VALUES
(
  'Crunch', 'crunch', 'core', 'beginner',
  'The crunch is a fundamental core exercise that isolates the rectus abdominis. It involves a controlled trunk flexion without the full sit-up range of motion.',
  ARRAY['Lie on your back with knees bent and feet flat on the floor.', 'Place your hands behind your head or cross them over your chest.', 'Engage your core and lift your shoulder blades off the floor.', 'Focus on squeezing your abs rather than pulling with your hands.', 'Hold briefly at the top.', 'Lower back down with control — do not simply drop.'],
  'Exhale as you crunch up. Inhale as you lower.',
  ARRAY['Pulling on the neck with your hands — support, do not pull.', 'Using momentum — perform each rep with control.', 'Coming up too high — you only need to lift the shoulder blades.', 'Relaxing completely at the bottom — maintain tension.'],
  ARRAY['If you experience neck discomfort, try placing your tongue on the roof of your mouth.'],
  3, 15, 45, true
),
(
  'Plank', 'plank', 'core', 'beginner',
  'The plank is an isometric core exercise that builds endurance and stability throughout the entire core musculature. It engages the abs, obliques, lower back, and shoulders simultaneously.',
  ARRAY['Start in a forearm plank position with elbows directly under your shoulders.', 'Keep your body in a straight line from head to heels.', 'Engage your core by pulling your belly button toward your spine.', 'Keep your hips level — do not let them sag or pike up.', 'Hold the position for the prescribed time.', 'Focus on maintaining perfect form throughout.'],
  'Breathe steadily and naturally throughout the hold. Do not hold your breath.',
  ARRAY['Hips sagging toward the floor — squeeze your glutes and core.', 'Hips piking up too high — lower them to maintain a straight line.', 'Looking forward and straining the neck — keep your gaze between your hands.', 'Holding breath — maintain steady breathing.'],
  ARRAY['Start with shorter holds and progress gradually.', 'Stop if you feel lower back pain.'],
  3, 1, 60, true
);

-- ============================================================
-- EXERCISE-MUSCLE RELATIONSHIPS
-- ============================================================

-- Bench Press
INSERT INTO exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, m.id, 'primary' FROM exercises e, muscles m WHERE e.slug = 'bench-press' AND m.slug = 'chest'
UNION ALL
SELECT e.id, m.id, 'secondary' FROM exercises e, muscles m WHERE e.slug = 'bench-press' AND m.slug = 'front-deltoid'
UNION ALL
SELECT e.id, m.id, 'secondary' FROM exercises e, muscles m WHERE e.slug = 'bench-press' AND m.slug = 'triceps';

-- Incline Bench Press
INSERT INTO exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, m.id, 'primary' FROM exercises e, muscles m WHERE e.slug = 'incline-bench-press' AND m.slug = 'upper-chest'
UNION ALL
SELECT e.id, m.id, 'primary' FROM exercises e, muscles m WHERE e.slug = 'incline-bench-press' AND m.slug = 'front-deltoid'
UNION ALL
SELECT e.id, m.id, 'secondary' FROM exercises e, muscles m WHERE e.slug = 'incline-bench-press' AND m.slug = 'triceps';

-- Push Up
INSERT INTO exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, m.id, 'primary' FROM exercises e, muscles m WHERE e.slug = 'push-up' AND m.slug = 'chest'
UNION ALL
SELECT e.id, m.id, 'secondary' FROM exercises e, muscles m WHERE e.slug = 'push-up' AND m.slug = 'front-deltoid'
UNION ALL
SELECT e.id, m.id, 'secondary' FROM exercises e, muscles m WHERE e.slug = 'push-up' AND m.slug = 'triceps'
UNION ALL
SELECT e.id, m.id, 'secondary' FROM exercises e, muscles m WHERE e.slug = 'push-up' AND m.slug = 'abs';

-- Dumbbell Fly
INSERT INTO exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, m.id, 'primary' FROM exercises e, muscles m WHERE e.slug = 'dumbbell-fly' AND m.slug = 'chest'
UNION ALL
SELECT e.id, m.id, 'secondary' FROM exercises e, muscles m WHERE e.slug = 'dumbbell-fly' AND m.slug = 'front-deltoid';

-- Deadlift
INSERT INTO exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, m.id, 'primary' FROM exercises e, muscles m WHERE e.slug = 'deadlift' AND m.slug = 'lower-back'
UNION ALL
SELECT e.id, m.id, 'primary' FROM exercises e, muscles m WHERE e.slug = 'deadlift' AND m.slug = 'glutes'
UNION ALL
SELECT e.id, m.id, 'primary' FROM exercises e, muscles m WHERE e.slug = 'deadlift' AND m.slug = 'hamstrings'
UNION ALL
SELECT e.id, m.id, 'secondary' FROM exercises e, muscles m WHERE e.slug = 'deadlift' AND m.slug = 'traps'
UNION ALL
SELECT e.id, m.id, 'secondary' FROM exercises e, muscles m WHERE e.slug = 'deadlift' AND m.slug = 'lats'
UNION ALL
SELECT e.id, m.id, 'secondary' FROM exercises e, muscles m WHERE e.slug = 'deadlift' AND m.slug = 'forearms';

-- Lat Pulldown
INSERT INTO exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, m.id, 'primary' FROM exercises e, muscles m WHERE e.slug = 'lat-pulldown' AND m.slug = 'lats'
UNION ALL
SELECT e.id, m.id, 'secondary' FROM exercises e, muscles m WHERE e.slug = 'lat-pulldown' AND m.slug = 'biceps'
UNION ALL
SELECT e.id, m.id, 'secondary' FROM exercises e, muscles m WHERE e.slug = 'lat-pulldown' AND m.slug = 'rhomboids';

-- Pull Up
INSERT INTO exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, m.id, 'primary' FROM exercises e, muscles m WHERE e.slug = 'pull-up' AND m.slug = 'lats'
UNION ALL
SELECT e.id, m.id, 'secondary' FROM exercises e, muscles m WHERE e.slug = 'pull-up' AND m.slug = 'biceps'
UNION ALL
SELECT e.id, m.id, 'secondary' FROM exercises e, muscles m WHERE e.slug = 'pull-up' AND m.slug = 'rhomboids'
UNION ALL
SELECT e.id, m.id, 'secondary' FROM exercises e, muscles m WHERE e.slug = 'pull-up' AND m.slug = 'abs';

-- Barbell Row
INSERT INTO exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, m.id, 'primary' FROM exercises e, muscles m WHERE e.slug = 'barbell-row' AND m.slug = 'lats'
UNION ALL
SELECT e.id, m.id, 'primary' FROM exercises e, muscles m WHERE e.slug = 'barbell-row' AND m.slug = 'rhomboids'
UNION ALL
SELECT e.id, m.id, 'secondary' FROM exercises e, muscles m WHERE e.slug = 'barbell-row' AND m.slug = 'rear-deltoid'
UNION ALL
SELECT e.id, m.id, 'secondary' FROM exercises e, muscles m WHERE e.slug = 'barbell-row' AND m.slug = 'biceps'
UNION ALL
SELECT e.id, m.id, 'secondary' FROM exercises e, muscles m WHERE e.slug = 'barbell-row' AND m.slug = 'traps';

-- Squat
INSERT INTO exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, m.id, 'primary' FROM exercises e, muscles m WHERE e.slug = 'squat' AND m.slug = 'quadriceps'
UNION ALL
SELECT e.id, m.id, 'primary' FROM exercises e, muscles m WHERE e.slug = 'squat' AND m.slug = 'glutes'
UNION ALL
SELECT e.id, m.id, 'secondary' FROM exercises e, muscles m WHERE e.slug = 'squat' AND m.slug = 'hamstrings'
UNION ALL
SELECT e.id, m.id, 'secondary' FROM exercises e, muscles m WHERE e.slug = 'squat' AND m.slug = 'abs'
UNION ALL
SELECT e.id, m.id, 'secondary' FROM exercises e, muscles m WHERE e.slug = 'squat' AND m.slug = 'lower-back';

-- Leg Press
INSERT INTO exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, m.id, 'primary' FROM exercises e, muscles m WHERE e.slug = 'leg-press' AND m.slug = 'quadriceps'
UNION ALL
SELECT e.id, m.id, 'secondary' FROM exercises e, muscles m WHERE e.slug = 'leg-press' AND m.slug = 'glutes'
UNION ALL
SELECT e.id, m.id, 'secondary' FROM exercises e, muscles m WHERE e.slug = 'leg-press' AND m.slug = 'hamstrings';

-- Lunges
INSERT INTO exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, m.id, 'primary' FROM exercises e, muscles m WHERE e.slug = 'lunges' AND m.slug = 'quadriceps'
UNION ALL
SELECT e.id, m.id, 'primary' FROM exercises e, muscles m WHERE e.slug = 'lunges' AND m.slug = 'glutes'
UNION ALL
SELECT e.id, m.id, 'secondary' FROM exercises e, muscles m WHERE e.slug = 'lunges' AND m.slug = 'hamstrings';

-- Leg Extension
INSERT INTO exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, m.id, 'primary' FROM exercises e, muscles m WHERE e.slug = 'leg-extension' AND m.slug = 'quadriceps';

-- Shoulder Press
INSERT INTO exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, m.id, 'primary' FROM exercises e, muscles m WHERE e.slug = 'shoulder-press' AND m.slug = 'front-deltoid'
UNION ALL
SELECT e.id, m.id, 'primary' FROM exercises e, muscles m WHERE e.slug = 'shoulder-press' AND m.slug = 'side-deltoid'
UNION ALL
SELECT e.id, m.id, 'secondary' FROM exercises e, muscles m WHERE e.slug = 'shoulder-press' AND m.slug = 'triceps'
UNION ALL
SELECT e.id, m.id, 'secondary' FROM exercises e, muscles m WHERE e.slug = 'shoulder-press' AND m.slug = 'traps';

-- Lateral Raise
INSERT INTO exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, m.id, 'primary' FROM exercises e, muscles m WHERE e.slug = 'lateral-raise' AND m.slug = 'side-deltoid'
UNION ALL
SELECT e.id, m.id, 'secondary' FROM exercises e, muscles m WHERE e.slug = 'lateral-raise' AND m.slug = 'front-deltoid'
UNION ALL
SELECT e.id, m.id, 'secondary' FROM exercises e, muscles m WHERE e.slug = 'lateral-raise' AND m.slug = 'traps';

-- Front Raise
INSERT INTO exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, m.id, 'primary' FROM exercises e, muscles m WHERE e.slug = 'front-raise' AND m.slug = 'front-deltoid'
UNION ALL
SELECT e.id, m.id, 'secondary' FROM exercises e, muscles m WHERE e.slug = 'front-raise' AND m.slug = 'side-deltoid';

-- Bicep Curl
INSERT INTO exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, m.id, 'primary' FROM exercises e, muscles m WHERE e.slug = 'bicep-curl' AND m.slug = 'biceps'
UNION ALL
SELECT e.id, m.id, 'secondary' FROM exercises e, muscles m WHERE e.slug = 'bicep-curl' AND m.slug = 'forearms';

-- Hammer Curl
INSERT INTO exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, m.id, 'primary' FROM exercises e, muscles m WHERE e.slug = 'hammer-curl' AND m.slug = 'biceps'
UNION ALL
SELECT e.id, m.id, 'primary' FROM exercises e, muscles m WHERE e.slug = 'hammer-curl' AND m.slug = 'forearms';

-- Tricep Pushdown
INSERT INTO exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, m.id, 'primary' FROM exercises e, muscles m WHERE e.slug = 'tricep-pushdown' AND m.slug = 'triceps';

-- Skull Crusher
INSERT INTO exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, m.id, 'primary' FROM exercises e, muscles m WHERE e.slug = 'skull-crusher' AND m.slug = 'triceps';

-- Crunch
INSERT INTO exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, m.id, 'primary' FROM exercises e, muscles m WHERE e.slug = 'crunch' AND m.slug = 'abs'
UNION ALL
SELECT e.id, m.id, 'secondary' FROM exercises e, muscles m WHERE e.slug = 'crunch' AND m.slug = 'obliques';

-- Plank
INSERT INTO exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, m.id, 'primary' FROM exercises e, muscles m WHERE e.slug = 'plank' AND m.slug = 'abs'
UNION ALL
SELECT e.id, m.id, 'primary' FROM exercises e, muscles m WHERE e.slug = 'plank' AND m.slug = 'obliques'
UNION ALL
SELECT e.id, m.id, 'secondary' FROM exercises e, muscles m WHERE e.slug = 'plank' AND m.slug = 'lower-back'
UNION ALL
SELECT e.id, m.id, 'secondary' FROM exercises e, muscles m WHERE e.slug = 'plank' AND m.slug = 'front-deltoid';

-- ============================================================
-- EXERCISE-EQUIPMENT RELATIONSHIPS
-- ============================================================
INSERT INTO exercise_equipment (exercise_id, equipment_id, is_primary)
SELECT e.id, eq.id, true FROM exercises e, equipment eq WHERE e.slug = 'bench-press' AND eq.slug = 'barbell'
UNION ALL SELECT e.id, eq.id, true FROM exercises e, equipment eq WHERE e.slug = 'bench-press' AND eq.slug = 'bench'
UNION ALL SELECT e.id, eq.id, true FROM exercises e, equipment eq WHERE e.slug = 'incline-bench-press' AND eq.slug = 'barbell'
UNION ALL SELECT e.id, eq.id, true FROM exercises e, equipment eq WHERE e.slug = 'incline-bench-press' AND eq.slug = 'bench'
UNION ALL SELECT e.id, eq.id, true FROM exercises e, equipment eq WHERE e.slug = 'push-up' AND eq.slug = 'bodyweight'
UNION ALL SELECT e.id, eq.id, true FROM exercises e, equipment eq WHERE e.slug = 'dumbbell-fly' AND eq.slug = 'dumbbells'
UNION ALL SELECT e.id, eq.id, true FROM exercises e, equipment eq WHERE e.slug = 'dumbbell-fly' AND eq.slug = 'bench'
UNION ALL SELECT e.id, eq.id, true FROM exercises e, equipment eq WHERE e.slug = 'deadlift' AND eq.slug = 'barbell'
UNION ALL SELECT e.id, eq.id, true FROM exercises e, equipment eq WHERE e.slug = 'lat-pulldown' AND eq.slug = 'lat-pulldown-machine'
UNION ALL SELECT e.id, eq.id, true FROM exercises e, equipment eq WHERE e.slug = 'pull-up' AND eq.slug = 'pull-up-bar'
UNION ALL SELECT e.id, eq.id, true FROM exercises e, equipment eq WHERE e.slug = 'barbell-row' AND eq.slug = 'barbell'
UNION ALL SELECT e.id, eq.id, true FROM exercises e, equipment eq WHERE e.slug = 'squat' AND eq.slug = 'barbell'
UNION ALL SELECT e.id, eq.id, true FROM exercises e, equipment eq WHERE e.slug = 'leg-press' AND eq.slug = 'leg-press-machine'
UNION ALL SELECT e.id, eq.id, true FROM exercises e, equipment eq WHERE e.slug = 'lunges' AND eq.slug = 'bodyweight'
UNION ALL SELECT e.id, eq.id, true FROM exercises e, equipment eq WHERE e.slug = 'leg-extension' AND eq.slug = 'leg-extension-machine'
UNION ALL SELECT e.id, eq.id, true FROM exercises e, equipment eq WHERE e.slug = 'shoulder-press' AND eq.slug = 'barbell'
UNION ALL SELECT e.id, eq.id, true FROM exercises e, equipment eq WHERE e.slug = 'lateral-raise' AND eq.slug = 'dumbbells'
UNION ALL SELECT e.id, eq.id, true FROM exercises e, equipment eq WHERE e.slug = 'front-raise' AND eq.slug = 'dumbbells'
UNION ALL SELECT e.id, eq.id, true FROM exercises e, equipment eq WHERE e.slug = 'bicep-curl' AND eq.slug = 'dumbbells'
UNION ALL SELECT e.id, eq.id, true FROM exercises e, equipment eq WHERE e.slug = 'hammer-curl' AND eq.slug = 'dumbbells'
UNION ALL SELECT e.id, eq.id, true FROM exercises e, equipment eq WHERE e.slug = 'tricep-pushdown' AND eq.slug = 'cable-machine'
UNION ALL SELECT e.id, eq.id, true FROM exercises e, equipment eq WHERE e.slug = 'skull-crusher' AND eq.slug = 'ez-curl-bar'
UNION ALL SELECT e.id, eq.id, true FROM exercises e, equipment eq WHERE e.slug = 'skull-crusher' AND eq.slug = 'bench'
UNION ALL SELECT e.id, eq.id, true FROM exercises e, equipment eq WHERE e.slug = 'crunch' AND eq.slug = 'bodyweight'
UNION ALL SELECT e.id, eq.id, true FROM exercises e, equipment eq WHERE e.slug = 'plank' AND eq.slug = 'bodyweight';
