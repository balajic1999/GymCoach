import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/widgets/common_widgets.dart';
import '../../../exercises/data/models/exercise.dart';
import '../../../exercises/presentation/providers/exercise_providers.dart';
import '../../../workout/data/repositories/workout_repository.dart';
import '../../../workout/presentation/providers/workout_providers.dart';
import '../../data/services/ai_coach_service.dart';

/// Bottom sheet modal to generate personalized workouts using AI.
class AiWorkoutGeneratorSheet extends ConsumerStatefulWidget {
  const AiWorkoutGeneratorSheet({super.key});

  @override
  ConsumerState<AiWorkoutGeneratorSheet> createState() =>
      _AiWorkoutGeneratorSheetState();
}

class _AiWorkoutGeneratorSheetState
    extends ConsumerState<AiWorkoutGeneratorSheet> {
  String _targetFocus = 'Full Body';
  int _durationMin = 45;
  String _difficulty = 'Intermediate';

  bool _isGenerating = false;
  bool _isSaving = false;
  GeneratedWorkoutPlan? _generatedPlan;

  static const _focusOptions = [
    'Full Body',
    'Chest & Push',
    'Back & Pull',
    'Legs & Glutes',
  ];

  static const _durationOptions = [30, 45, 60];
  static const _difficultyOptions = ['Beginner', 'Intermediate', 'Advanced'];

  Future<void> _generatePlan() async {
    setState(() {
      _isGenerating = true;
      _generatedPlan = null;
    });

    try {
      final aiService = ref.read(aiCoachServiceProvider);
      final plan = await aiService.generateWorkoutPlan(
        targetFocus: _targetFocus,
        durationMin: _durationMin,
        difficulty: _difficulty,
      );

      setState(() {
        _generatedPlan = plan;
      });
    } finally {
      if (mounted) {
        setState(() => _isGenerating = false);
      }
    }
  }

  Future<void> _savePlanToWorkouts() async {
    if (_generatedPlan == null) return;
    setState(() => _isSaving = true);

    try {
      final repo = ref.read(workoutRepositoryProvider);
      final workoutData = await repo.createWorkout(
        name: _generatedPlan!.name,
        description: _generatedPlan!.description,
        type: _targetFocus,
        difficulty: _generatedPlan!.difficulty,
        estimatedDurationMin: _generatedPlan!.estimatedDurationMin,
        isAiGenerated: true,
      );

      final workoutId = workoutData['id'] as String;

      // Match generated exercise names with database exercises
      final allExercises =
          await ref.read(exerciseListProvider(const ExerciseFilterParams()).future);

      final exerciseRows = <Map<String, dynamic>>[];
      for (final gEx in _generatedPlan!.exercises) {
        final match = allExercises.firstWhere(
          (ex) =>
              ex.name.toLowerCase().contains(gEx.exerciseName.toLowerCase()) ||
              gEx.exerciseName.toLowerCase().contains(ex.name.toLowerCase()),
          orElse: () => allExercises.isNotEmpty
              ? allExercises.first
              : const Exercise(
                  id: 'demo',
                  name: 'Demo Exercise',
                  slug: 'demo',
                  category: 'chest',
                  difficulty: 'intermediate',
                ),
        );

        exerciseRows.add({
          'exercise_id': match.id,
          'sets': gEx.sets,
          'reps': gEx.reps,
          'rest_seconds': gEx.restSeconds,
        });
      }

      await repo.addExercisesToWorkout(workoutId, exerciseRows);

      // Refresh workouts list
      ref.invalidate(workoutListProvider);

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${_generatedPlan!.name} saved to My Workouts!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save workout: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      decoration: const BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.borderDark,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Header
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  gradient: AppColors.gradientAccent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'AI Workout Generator',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ],
          ),
          const SizedBox(height: 16),

          if (_generatedPlan == null) ...[
            // Focus Selection
            Text(
              'TARGET FOCUS',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.textTertiaryDark,
                    letterSpacing: 1.0,
                  ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _focusOptions.map((focus) {
                final isSelected = _targetFocus == focus;
                return CategoryChip(
                  label: focus,
                  isSelected: isSelected,
                  onTap: () => setState(() => _targetFocus = focus),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Duration & Difficulty
            Row(
              children: [
                // Duration
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'DURATION',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: AppColors.textTertiaryDark,
                              letterSpacing: 1.0,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: _durationOptions.map((d) {
                          final isSelected = _durationMin == d;
                          return Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => _durationMin = d),
                              child: Container(
                                margin: const EdgeInsets.only(right: 6),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.primary.withValues(alpha: 0.2)
                                      : AppColors.surfaceHighDark,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: isSelected
                                        ? AppColors.primary
                                        : AppColors.borderDark,
                                    width: 0.5,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    '${d}m',
                                    style: TextStyle(
                                      color: isSelected
                                          ? AppColors.primary
                                          : AppColors.textSecondaryDark,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                // Difficulty
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'LEVEL',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: AppColors.textTertiaryDark,
                              letterSpacing: 1.0,
                            ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        initialValue: _difficulty,
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 10, vertical: 8),
                        ),
                        items: _difficultyOptions
                            .map((d) => DropdownMenuItem(
                                  value: d,
                                  child: Text(d,
                                      style: const TextStyle(fontSize: 12)),
                                ))
                            .toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() => _difficulty = val);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Generate Button
            GradientButton(
              label: _isGenerating ? 'Designing Routine...' : 'Generate Workout',
              icon: Icons.auto_awesome_rounded,
              onPressed: _isGenerating ? null : _generatePlan,
            ),
          ] else ...[
            // Generated Plan Preview
            Expanded(
              child: ListView(
                children: [
                  GlassCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _generatedPlan!.name,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.accent,
                                  ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceHighDark,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '${_generatedPlan!.estimatedDurationMin} min',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textSecondaryDark,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _generatedPlan!.description,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.textSecondaryDark,
                                  ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  Text(
                    'ROUTINE EXERCISES (${_generatedPlan!.exercises.length})',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColors.textTertiaryDark,
                          letterSpacing: 1.0,
                        ),
                  ),
                  const SizedBox(height: 8),

                  ..._generatedPlan!.exercises.asMap().entries.map((entry) {
                    final index = entry.key;
                    final ex = entry.value;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: GlassCard(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        child: Row(
                          children: [
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color:
                                    AppColors.primary.withValues(alpha: 0.2),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  '${index + 1}',
                                  style: const TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    ex.exerciseName,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleSmall
                                        ?.copyWith(fontWeight: FontWeight.w700),
                                  ),
                                  Text(
                                    '${ex.sets} sets × ${ex.reps} reps • Rest: ${ex.restSeconds}s',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                          color: AppColors.textTertiaryDark,
                                          fontSize: 11,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => setState(() => _generatedPlan = null),
                    child: const Text('Re-Generate'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GradientButton(
                    label: _isSaving ? 'Saving...' : 'Save to Workouts',
                    icon: Icons.check_circle_outline_rounded,
                    onPressed: _isSaving ? null : _savePlanToWorkouts,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
