import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/services/supabase_service.dart';

/// Repository for exercise-related database operations.
/// All queries respect Supabase RLS — only published exercises are returned.
class ExerciseRepository {
  final SupabaseClient _client;

  ExerciseRepository(this._client);

  /// Fetch all published exercises with muscles and equipment relations.
  Future<List<Map<String, dynamic>>> getExercises({
    String? category,
    String? difficulty,
    String? searchQuery,
    int limit = 50,
    int offset = 0,
  }) async {
    var query = _client
        .from('exercises')
        .select('''
          *,
          exercise_muscles(
            id, role,
            muscle:muscles(id, name, slug, muscle_group, body_region)
          ),
          exercise_equipment(
            id, is_primary,
            equipment:equipment(id, name, slug, category)
          )
        ''');

    if (category != null && category != 'All') {
      query = query.eq('category', category.toLowerCase());
    }
    if (difficulty != null) {
      query = query.eq('difficulty', difficulty.toLowerCase());
    }
    if (searchQuery != null && searchQuery.isNotEmpty) {
      query = query.or('name.ilike.%$searchQuery%,description.ilike.%$searchQuery%');
    }

    final response = await query
        .order('name')
        .range(offset, offset + limit - 1);

    return List<Map<String, dynamic>>.from(response);
  }

  /// Fetch a single exercise by slug with all related data.
  Future<Map<String, dynamic>?> getExerciseBySlug(String slug) async {
    final response = await _client
        .from('exercises')
        .select('''
          *,
          exercise_muscles(
            id, role,
            muscle:muscles(id, name, slug, muscle_group, body_region, description)
          ),
          exercise_equipment(
            id, is_primary,
            equipment:equipment(id, name, slug, category, description)
          )
        ''')
        .eq('slug', slug)
        .maybeSingle();

    return response;
  }

  /// Fetch a single exercise by ID.
  Future<Map<String, dynamic>?> getExerciseById(String id) async {
    final response = await _client
        .from('exercises')
        .select('''
          *,
          exercise_muscles(
            id, role,
            muscle:muscles(id, name, slug, muscle_group, body_region, description)
          ),
          exercise_equipment(
            id, is_primary,
            equipment:equipment(id, name, slug, category, description)
          )
        ''')
        .eq('id', id)
        .maybeSingle();

    return response;
  }

  /// Fetch all muscles.
  Future<List<Map<String, dynamic>>> getMuscles() async {
    final response = await _client
        .from('muscles')
        .select()
        .order('sort_order');

    return List<Map<String, dynamic>>.from(response);
  }

  /// Fetch all equipment.
  Future<List<Map<String, dynamic>>> getEquipment() async {
    final response = await _client
        .from('equipment')
        .select()
        .order('name');

    return List<Map<String, dynamic>>.from(response);
  }

  /// Fetch exercises by muscle group.
  Future<List<Map<String, dynamic>>> getExercisesByMuscle(String muscleSlug) async {
    final response = await _client
        .from('exercises')
        .select('''
          *,
          exercise_muscles!inner(
            role,
            muscle:muscles!inner(slug)
          )
        ''')
        .eq('exercise_muscles.muscle.slug', muscleSlug)
        .order('name');

    return List<Map<String, dynamic>>.from(response);
  }

  /// Get categories with exercise counts.
  Future<List<Map<String, dynamic>>> getCategoryCounts() async {
    final response = await _client
        .rpc('get_category_counts');

    return List<Map<String, dynamic>>.from(response);
  }
}

/// Provider for ExerciseRepository.
final exerciseRepositoryProvider = Provider<ExerciseRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return ExerciseRepository(client);
});
