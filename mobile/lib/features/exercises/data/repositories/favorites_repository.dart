import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/services/supabase_service.dart';

/// Repository for favorites operations.
class FavoritesRepository {
  final SupabaseClient _client;

  FavoritesRepository(this._client);

  /// Get all favorite exercise IDs for the current user.
  Future<List<String>> getFavoriteIds() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return [];

    final response = await _client
        .from('favorites')
        .select('exercise_id')
        .eq('user_id', userId);

    return (response as List)
        .map<String>((row) => row['exercise_id'] as String)
        .toList();
  }

  /// Get all favorited exercises with full details.
  Future<List<Map<String, dynamic>>> getFavoriteExercises() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return [];

    final response = await _client
        .from('favorites')
        .select('''
          exercise_id,
          exercise:exercises(
            *,
            exercise_muscles(
              id, role,
              muscle:muscles(id, name, slug, muscle_group)
            ),
            exercise_equipment(
              id, is_primary,
              equipment:equipment(id, name, slug)
            )
          )
        ''')
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  /// Check if an exercise is favorited.
  Future<bool> isFavorited(String exerciseId) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return false;

    final response = await _client
        .from('favorites')
        .select('id')
        .eq('user_id', userId)
        .eq('exercise_id', exerciseId)
        .maybeSingle();

    return response != null;
  }

  /// Toggle favorite for an exercise.
  /// Returns true if now favorited, false if unfavorited.
  Future<bool> toggleFavorite(String exerciseId) async {
    final userId = _client.auth.currentUser!.id;

    final existing = await _client
        .from('favorites')
        .select('id')
        .eq('user_id', userId)
        .eq('exercise_id', exerciseId)
        .maybeSingle();

    if (existing != null) {
      await _client.from('favorites').delete().eq('id', existing['id']);
      return false;
    } else {
      await _client.from('favorites').insert({
        'user_id': userId,
        'exercise_id': exerciseId,
      });
      return true;
    }
  }
}

/// Provider for FavoritesRepository.
final favoritesRepositoryProvider = Provider<FavoritesRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return FavoritesRepository(client);
});
