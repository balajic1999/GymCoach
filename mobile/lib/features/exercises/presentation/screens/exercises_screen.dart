import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/widgets/common_widgets.dart';
import 'package:go_router/go_router.dart';

class ExercisesScreen extends StatefulWidget {
  const ExercisesScreen({super.key});

  @override
  State<ExercisesScreen> createState() => _ExercisesScreenState();
}

class _ExercisesScreenState extends State<ExercisesScreen> {
  String _selectedCategory = 'All';
  final _searchController = TextEditingController();

  static const _categories = [
    'All',
    'Chest',
    'Back',
    'Legs',
    'Shoulders',
    'Arms',
    'Core',
  ];

  static const _exercises = [
    _ExerciseItem('Bench Press', 'Chest', 'Intermediate', 'Barbell', AppColors.muscleChest),
    _ExerciseItem('Incline Bench Press', 'Chest', 'Intermediate', 'Barbell', AppColors.muscleChest),
    _ExerciseItem('Push Up', 'Chest', 'Beginner', 'Bodyweight', AppColors.muscleChest),
    _ExerciseItem('Dumbbell Fly', 'Chest', 'Intermediate', 'Dumbbells', AppColors.muscleChest),
    _ExerciseItem('Deadlift', 'Back', 'Advanced', 'Barbell', AppColors.muscleBack),
    _ExerciseItem('Lat Pulldown', 'Back', 'Beginner', 'Cable Machine', AppColors.muscleBack),
    _ExerciseItem('Pull Up', 'Back', 'Intermediate', 'Pull-up Bar', AppColors.muscleBack),
    _ExerciseItem('Barbell Row', 'Back', 'Intermediate', 'Barbell', AppColors.muscleBack),
    _ExerciseItem('Squat', 'Legs', 'Intermediate', 'Barbell', AppColors.muscleLegs),
    _ExerciseItem('Leg Press', 'Legs', 'Beginner', 'Machine', AppColors.muscleLegs),
    _ExerciseItem('Lunges', 'Legs', 'Beginner', 'Bodyweight', AppColors.muscleLegs),
    _ExerciseItem('Leg Extension', 'Legs', 'Beginner', 'Machine', AppColors.muscleLegs),
    _ExerciseItem('Shoulder Press', 'Shoulders', 'Intermediate', 'Barbell', AppColors.muscleShoulders),
    _ExerciseItem('Lateral Raise', 'Shoulders', 'Beginner', 'Dumbbells', AppColors.muscleShoulders),
    _ExerciseItem('Front Raise', 'Shoulders', 'Beginner', 'Dumbbells', AppColors.muscleShoulders),
    _ExerciseItem('Bicep Curl', 'Arms', 'Beginner', 'Dumbbells', AppColors.muscleArms),
    _ExerciseItem('Hammer Curl', 'Arms', 'Beginner', 'Dumbbells', AppColors.muscleArms),
    _ExerciseItem('Tricep Pushdown', 'Arms', 'Beginner', 'Cable Machine', AppColors.muscleArms),
    _ExerciseItem('Skull Crusher', 'Arms', 'Intermediate', 'Barbell', AppColors.muscleArms),
    _ExerciseItem('Crunch', 'Core', 'Beginner', 'Bodyweight', AppColors.muscleCore),
    _ExerciseItem('Plank', 'Core', 'Beginner', 'Bodyweight', AppColors.muscleCore),
  ];

  List<_ExerciseItem> get _filteredExercises {
    var filtered = _exercises.toList();
    if (_selectedCategory != 'All') {
      filtered = filtered.where((e) => e.category == _selectedCategory).toList();
    }
    final query = _searchController.text.toLowerCase();
    if (query.isNotEmpty) {
      filtered = filtered.where((e) =>
          e.name.toLowerCase().contains(query) ||
          e.category.toLowerCase().contains(query) ||
          e.equipment.toLowerCase().contains(query)).toList();
    }
    return filtered;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Text(
                  'Exercise Library',
                  style: Theme.of(context).textTheme.displaySmall,
                ),
              ),
            ),

            // Search bar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                child: TextField(
                  controller: _searchController,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'Search exercises...',
                    prefixIcon: const Icon(Icons.search_rounded, size: 22),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded, size: 20),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {});
                            },
                          )
                        : null,
                  ),
                ),
              ),
            ),

            // Category chips
            SliverToBoxAdapter(
              child: SizedBox(
                height: 42,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  scrollDirection: Axis.horizontal,
                  itemCount: _categories.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final cat = _categories[index];
                    return CategoryChip(
                      label: cat,
                      isSelected: _selectedCategory == cat,
                      onTap: () => setState(() => _selectedCategory = cat),
                    );
                  },
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 16)),

            // Results count
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  '${_filteredExercises.length} exercises',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondaryDark,
                      ),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 12)),

            // Exercise list
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverList.separated(
                itemCount: _filteredExercises.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final exercise = _filteredExercises[index];
                  return _ExerciseCard(exercise: exercise)
                      .animate()
                      .fadeIn(duration: 300.ms, delay: (index * 50).ms)
                      .slideX(begin: 0.05, end: 0);
                },
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 20)),
          ],
        ),
      ),
    );
  }
}

class _ExerciseItem {
  final String name;
  final String category;
  final String difficulty;
  final String equipment;
  final Color color;

  const _ExerciseItem(this.name, this.category, this.difficulty, this.equipment, this.color);
}

class _ExerciseCard extends StatelessWidget {
  final _ExerciseItem exercise;

  const _ExerciseCard({required this.exercise});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      onTap: () {
        final slug = exercise.name.toLowerCase().replaceAll(' ', '-');
        context.push('/exercises/$slug');
      },
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          // Icon
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: exercise.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              Icons.fitness_center_rounded,
              color: exercise.color,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  exercise.name,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    _InfoTag(label: exercise.category, color: exercise.color),
                    const SizedBox(width: 8),
                    _InfoTag(
                      label: exercise.difficulty,
                      color: exercise.difficulty == 'Beginner'
                          ? AppColors.success
                          : exercise.difficulty == 'Intermediate'
                              ? AppColors.warning
                              : AppColors.error,
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Equipment badge
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                exercise.equipment,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textTertiaryDark,
                    ),
              ),
              const SizedBox(height: 4),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: AppColors.textTertiaryDark,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoTag extends StatelessWidget {
  final String label;
  final Color color;

  const _InfoTag({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}
