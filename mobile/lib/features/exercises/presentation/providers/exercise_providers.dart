import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/exercise.dart';
import '../../data/repositories/exercise_repository.dart';
import '../../data/repositories/favorites_repository.dart';

/// Parameters for filtering exercises.
class ExerciseFilterParams {
  final String? category;
  final String? difficulty;
  final String? searchQuery;

  const ExerciseFilterParams({
    this.category,
    this.difficulty,
    this.searchQuery,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExerciseFilterParams &&
          category == other.category &&
          difficulty == other.difficulty &&
          searchQuery == other.searchQuery;

  @override
  int get hashCode => Object.hash(category, difficulty, searchQuery);
}

/// Provides the list of exercises based on filter parameters.
/// Falls back to empty list if Supabase is not connected.
final exerciseListProvider =
    FutureProvider.family<List<Exercise>, ExerciseFilterParams>(
  (ref, params) async {
    try {
      final repo = ref.watch(exerciseRepositoryProvider);
      final data = await repo.getExercises(
        category: params.category,
        searchQuery: params.searchQuery,
        difficulty: params.difficulty,
      );
      return data.map((json) => Exercise.fromJson(json)).toList();
    } catch (_) {
      // Return empty list if Supabase is not configured
      return [];
    }
  },
);

/// Provides a single exercise by slug.
final exerciseDetailProvider =
    FutureProvider.family<Exercise?, String>((ref, slug) async {
  try {
    final repo = ref.watch(exerciseRepositoryProvider);
    final data = await repo.getExerciseBySlug(slug);
    if (data == null) return null;
    return Exercise.fromJson(data);
  } catch (_) {
    return null;
  }
});

/// Manages the set of favorited exercise IDs.
class FavoritesNotifier extends StateNotifier<Set<String>> {
  final FavoritesRepository _repo;

  FavoritesNotifier(this._repo) : super({}) {
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    try {
      final ids = await _repo.getFavoriteIds();
      state = ids.toSet();
    } catch (_) {
      // Not authenticated or Supabase not configured
    }
  }

  bool isFavorited(String exerciseId) => state.contains(exerciseId);

  Future<void> toggle(String exerciseId) async {
    // Optimistic update
    final wasFavorited = state.contains(exerciseId);
    if (wasFavorited) {
      state = {...state}..remove(exerciseId);
    } else {
      state = {...state, exerciseId};
    }

    try {
      final nowFavorited = await _repo.toggleFavorite(exerciseId);
      // Reconcile with server state
      if (nowFavorited) {
        state = {...state, exerciseId};
      } else {
        state = {...state}..remove(exerciseId);
      }
    } catch (_) {
      // Revert on error
      if (wasFavorited) {
        state = {...state, exerciseId};
      } else {
        state = {...state}..remove(exerciseId);
      }
    }
  }
}

/// Provider for favorites state management.
final favoritesProvider =
    StateNotifierProvider<FavoritesNotifier, Set<String>>((ref) {
  final repo = ref.watch(favoritesRepositoryProvider);
  return FavoritesNotifier(repo);
});
