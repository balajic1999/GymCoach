import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/widgets/common_widgets.dart';
import '../../data/models/exercise.dart';
import '../providers/exercise_providers.dart';

class ExercisesScreen extends ConsumerStatefulWidget {
  const ExercisesScreen({super.key});

  @override
  ConsumerState<ExercisesScreen> createState() => _ExercisesScreenState();
}

class _ExercisesScreenState extends ConsumerState<ExercisesScreen> {
  String _selectedCategory = 'All';
  final _searchController = TextEditingController();
  String _searchQuery = '';

  static const _categories = [
    'All',
    'Chest',
    'Back',
    'Legs',
    'Shoulders',
    'Arms',
    'Core',
  ];

  /// Map category display names to database values.
  static const _categoryDbMap = {
    'All': null,
    'Chest': 'chest',
    'Back': 'back',
    'Legs': 'legs',
    'Shoulders': 'shoulders',
    'Arms': 'arms',
    'Core': 'core',
  };

  ExerciseFilterParams get _filterParams => ExerciseFilterParams(
        category: _categoryDbMap[_selectedCategory],
        searchQuery: _searchQuery.isNotEmpty ? _searchQuery : null,
      );

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final exercisesAsync = ref.watch(exerciseListProvider(_filterParams));

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
                  onChanged: (value) => setState(() => _searchQuery = value),
                  decoration: InputDecoration(
                    hintText: 'Search exercises...',
                    prefixIcon: const Icon(Icons.search_rounded, size: 22),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded, size: 20),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
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

            // Exercise list with data states
            exercisesAsync.when(
              loading: () => SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverList.separated(
                  itemCount: 6,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (_, _) => const ShimmerBox(height: 80),
                ),
              ),
              error: (error, stackTrace) => SliverToBoxAdapter(
                child: const _EmptyState(
                  icon: Icons.cloud_off_rounded,
                  title: 'Connection Error',
                  subtitle:
                      'Could not load exercises.\nCheck your connection and try again.',
                ),
              ),
              data: (exercises) {
                if (exercises.isEmpty) {
                  return SliverToBoxAdapter(
                    child: _EmptyState(
                      icon: Icons.search_off_rounded,
                      title: 'No exercises found',
                      subtitle: _searchQuery.isNotEmpty
                          ? 'Try a different search term'
                          : 'No exercises in this category yet',
                    ),
                  );
                }

                return SliverMainAxisGroup(
                  slivers: [
                    // Results count
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          '${exercises.length} exercise${exercises.length != 1 ? 's' : ''}',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
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
                        itemCount: exercises.length,
                        separatorBuilder: (_, _) =>
                            const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final exercise = exercises[index];
                          return _ExerciseCard(exercise: exercise)
                              .animate()
                              .fadeIn(
                                  duration: 300.ms,
                                  delay: (index * 50).clamp(0, 500).ms)
                              .slideX(begin: 0.05, end: 0);
                        },
                      ),
                    ),
                  ],
                );
              },
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 20)),
          ],
        ),
      ),
    );
  }
}

/// Color mapping for exercise categories.
Color _categoryColor(String category) {
  return switch (category.toLowerCase()) {
    'chest' => AppColors.muscleChest,
    'back' => AppColors.muscleBack,
    'legs' => AppColors.muscleLegs,
    'shoulders' => AppColors.muscleShoulders,
    'arms' => AppColors.muscleArms,
    'core' => AppColors.muscleCore,
    _ => AppColors.primary,
  };
}

/// Color mapping for difficulty levels.
Color _difficultyColor(String difficulty) {
  return switch (difficulty.toLowerCase()) {
    'beginner' => AppColors.success,
    'intermediate' => AppColors.warning,
    'advanced' => AppColors.error,
    _ => AppColors.textSecondaryDark,
  };
}

/// Formats category string for display (e.g., 'chest' → 'Chest').
String _capitalizeFirst(String s) {
  if (s.isEmpty) return s;
  return '${s[0].toUpperCase()}${s.substring(1)}';
}

class _ExerciseCard extends StatelessWidget {
  final Exercise exercise;

  const _ExerciseCard({required this.exercise});

  String get _primaryEquipment {
    final primary =
        exercise.equipment.where((e) => e.isPrimary).toList();
    if (primary.isNotEmpty && primary.first.equipment != null) {
      return primary.first.equipment!.name;
    }
    if (exercise.equipment.isNotEmpty &&
        exercise.equipment.first.equipment != null) {
      return exercise.equipment.first.equipment!.name;
    }
    return 'Bodyweight';
  }

  @override
  Widget build(BuildContext context) {
    final color = _categoryColor(exercise.category);

    return GlassCard(
      onTap: () => context.push('/exercises/${exercise.slug}'),
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          // Icon
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              Icons.fitness_center_rounded,
              color: color,
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
                    _InfoTag(
                      label: _capitalizeFirst(exercise.category),
                      color: color,
                    ),
                    const SizedBox(width: 8),
                    _InfoTag(
                      label: _capitalizeFirst(exercise.difficulty),
                      color: _difficultyColor(exercise.difficulty),
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
                _primaryEquipment,
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

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 64, color: AppColors.textTertiaryDark),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppColors.textSecondaryDark,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textTertiaryDark,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
