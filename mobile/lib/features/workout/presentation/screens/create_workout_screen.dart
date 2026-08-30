import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/widgets/common_widgets.dart';
import '../../../exercises/data/models/exercise.dart';
import '../../../exercises/presentation/providers/exercise_providers.dart';
import '../../data/repositories/workout_repository.dart';
import '../providers/workout_providers.dart';

class _WorkoutExerciseDraft {
  final Exercise exercise;
  int sets;
  int reps;
  int restSeconds;

  _WorkoutExerciseDraft({
    required this.exercise,
    this.sets = 3,
    this.reps = 10,
    this.restSeconds = 60,
  });
}

class CreateWorkoutScreen extends ConsumerStatefulWidget {
  const CreateWorkoutScreen({super.key});

  @override
  ConsumerState<CreateWorkoutScreen> createState() =>
      _CreateWorkoutScreenState();
}

class _CreateWorkoutScreenState extends ConsumerState<CreateWorkoutScreen> {
  final _nameController = TextEditingController(text: 'Full Body Routine');
  final _descController = TextEditingController();
  String _selectedType = 'Strength';
  String _selectedDifficulty = 'Intermediate';
  final int _estimatedDurationMin = 45;
  bool _isSaving = false;

  final List<_WorkoutExerciseDraft> _exercises = [];

  static const _types = ['Strength', 'Hypertrophy', 'Endurance', 'Mobility'];
  static const _difficulties = ['Beginner', 'Intermediate', 'Advanced'];

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _openExerciseSelector() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _ExerciseSelectorSheet(
        onExerciseSelected: (exercise) {
          setState(() {
            _exercises.add(_WorkoutExerciseDraft(
              exercise: exercise,
              sets: exercise.defaultSets,
              reps: exercise.defaultReps,
              restSeconds: exercise.defaultRestSeconds,
            ));
          });
          Navigator.of(ctx).pop();
        },
      ),
    );
  }

  Future<void> _saveWorkout() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a workout name')),
      );
      return;
    }

    if (_exercises.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one exercise')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final repo = ref.read(workoutRepositoryProvider);
      final workoutData = await repo.createWorkout(
        name: name,
        description: _descController.text.trim().isNotEmpty
            ? _descController.text.trim()
            : null,
        type: _selectedType,
        difficulty: _selectedDifficulty,
        estimatedDurationMin: _estimatedDurationMin,
      );

      final workoutId = workoutData['id'] as String;

      final exerciseRows = _exercises.map((e) => {
            'exercise_id': e.exercise.id,
            'sets': e.sets,
            'reps': e.reps,
            'rest_seconds': e.restSeconds,
          }).toList();

      await repo.addExercisesToWorkout(workoutId, exerciseRows);

      // Invalidate workout provider to refresh list
      ref.invalidate(workoutListProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Workout created successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
        context.pop();
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Workout'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _saveWorkout,
            child: _isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(
                    'Save',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Workout Name
            Text(
              'WORKOUT DETAILS',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.textTertiaryDark,
                    letterSpacing: 1.2,
                  ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Workout Name',
                hintText: 'e.g. Chest & Triceps Blast',
                prefixIcon: Icon(Icons.fitness_center_rounded),
              ),
            ),
            const SizedBox(height: 14),

            // Workout Type & Difficulty Chips
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _selectedType,
                    decoration: const InputDecoration(
                      labelText: 'Type',
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                    items: _types
                        .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedType = val);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _selectedDifficulty,
                    decoration: const InputDecoration(
                      labelText: 'Difficulty',
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                    items: _difficulties
                        .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() => _selectedDifficulty = val);
                      }
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Exercises Section Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'EXERCISES (${_exercises.length})',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.textTertiaryDark,
                        letterSpacing: 1.2,
                      ),
                ),
                TextButton.icon(
                  onPressed: _openExerciseSelector,
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: const Text('Add Exercise'),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Exercises List
            if (_exercises.isEmpty)
              GlassCard(
                padding: const EdgeInsets.symmetric(vertical: 36),
                child: Center(
                  child: Column(
                    children: [
                      const Icon(Icons.fitness_center_outlined,
                          size: 40, color: AppColors.textTertiaryDark),
                      const SizedBox(height: 10),
                      Text(
                        'No exercises added yet',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: AppColors.textSecondaryDark,
                            ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Tap "+ Add Exercise" to choose from the library',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textTertiaryDark,
                            ),
                      ),
                    ],
                  ),
                ),
              )
            else
              ReorderableListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _exercises.length,
                // ignore: deprecated_member_use
                onReorder: (oldIdx, newIdx) {
                  setState(() {
                    if (newIdx > oldIdx) newIdx--;
                    final item = _exercises.removeAt(oldIdx);
                    _exercises.insert(newIdx, item);
                  });
                },
                itemBuilder: (context, index) {
                  final draft = _exercises[index];
                  return Container(
                    key: ValueKey(draft.exercise.id + index.toString()),
                    margin: const EdgeInsets.only(bottom: 10),
                    child: GlassCard(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  gradient: AppColors.gradientPrimary,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Center(
                                  child: Text(
                                    '${index + 1}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      draft.exercise.name,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleSmall
                                          ?.copyWith(
                                              fontWeight: FontWeight.w700),
                                    ),
                                    Text(
                                      draft.exercise.category.toUpperCase(),
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelSmall
                                          ?.copyWith(
                                            color: AppColors.accent,
                                            fontSize: 10,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline_rounded,
                                    size: 20, color: AppColors.error),
                                onPressed: () {
                                  setState(() => _exercises.removeAt(index));
                                },
                              ),
                              const Icon(Icons.drag_handle_rounded,
                                  color: AppColors.textTertiaryDark),
                            ],
                          ),
                          const Divider(height: 16, thickness: 0.5),
                          Row(
                            children: [
                              _StepperField(
                                label: 'Sets',
                                value: draft.sets,
                                min: 1,
                                max: 10,
                                onChanged: (val) =>
                                    setState(() => draft.sets = val),
                              ),
                              const SizedBox(width: 12),
                              _StepperField(
                                label: 'Reps',
                                value: draft.reps,
                                min: 1,
                                max: 50,
                                onChanged: (val) =>
                                    setState(() => draft.reps = val),
                              ),
                              const SizedBox(width: 12),
                              _StepperField(
                                label: 'Rest',
                                value: draft.restSeconds,
                                step: 15,
                                min: 15,
                                max: 300,
                                unit: 's',
                                onChanged: (val) =>
                                    setState(() => draft.restSeconds = val),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),

            const SizedBox(height: 32),
            GradientButton(
              label: 'Save Workout',
              icon: Icons.check_circle_outline_rounded,
              onPressed: _isSaving ? null : _saveWorkout,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _StepperField extends StatelessWidget {
  final String label;
  final int value;
  final int min;
  final int max;
  final int step;
  final String? unit;
  final ValueChanged<int> onChanged;

  const _StepperField({
    required this.label,
    required this.value,
    this.min = 1,
    this.max = 100,
    this.step = 1,
    this.unit,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.surfaceHighDark,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.textTertiaryDark,
                    fontSize: 10,
                  ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: value > min ? () => onChanged(value - step) : null,
                  child: Icon(
                    Icons.remove_circle_outline_rounded,
                    size: 18,
                    color: value > min
                        ? AppColors.textSecondaryDark
                        : AppColors.textTertiaryDark.withValues(alpha: 0.3),
                  ),
                ),
                Text(
                  '$value${unit ?? ''}',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                GestureDetector(
                  onTap: value < max ? () => onChanged(value + step) : null,
                  child: Icon(
                    Icons.add_circle_outline_rounded,
                    size: 18,
                    color: value < max
                        ? AppColors.textSecondaryDark
                        : AppColors.textTertiaryDark.withValues(alpha: 0.3),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ExerciseSelectorSheet extends ConsumerStatefulWidget {
  final ValueChanged<Exercise> onExerciseSelected;

  const _ExerciseSelectorSheet({required this.onExerciseSelected});

  @override
  ConsumerState<_ExerciseSelectorSheet> createState() =>
      _ExerciseSelectorSheetState();
}

class _ExerciseSelectorSheetState
    extends ConsumerState<_ExerciseSelectorSheet> {
  String _search = '';

  @override
  Widget build(BuildContext context) {
    final exercisesAsync = ref.watch(
      exerciseListProvider(ExerciseFilterParams(
        searchQuery: _search.isNotEmpty ? _search : null,
      )),
    );

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
          Text(
            'Select Exercise',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          TextField(
            onChanged: (v) => setState(() => _search = v),
            decoration: const InputDecoration(
              hintText: 'Search exercise...',
              prefixIcon: Icon(Icons.search_rounded),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: exercisesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, s) => Center(child: Text('Error: $e')),
              data: (exercises) {
                if (exercises.isEmpty) {
                  return const Center(child: Text('No exercises found'));
                }
                return ListView.separated(
                  itemCount: exercises.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final exercise = exercises[index];
                    return GlassCard(
                      onTap: () => widget.onExerciseSelected(exercise),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                      child: Row(
                        children: [
                          const Icon(Icons.fitness_center_rounded,
                              color: AppColors.primary, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  exercise.name,
                                  style: Theme.of(context).textTheme.titleSmall,
                                ),
                                Text(
                                  exercise.category.toUpperCase(),
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelSmall
                                      ?.copyWith(
                                        color: AppColors.textTertiaryDark,
                                        fontSize: 10,
                                      ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.add_circle_outline_rounded,
                              color: AppColors.primary),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
