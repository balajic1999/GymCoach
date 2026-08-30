import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/services/supabase_service.dart';

/// Repository for user profile operations.
class ProfileRepository {
  final SupabaseClient _client;

  ProfileRepository(this._client);

  /// Fetch the current user's profile.
  Future<Map<String, dynamic>?> getCurrentProfile() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return null;

    final response = await _client
        .from('profiles')
        .select()
        .eq('id', userId)
        .maybeSingle();

    return response;
  }

  /// Update the current user's profile.
  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> data) async {
    final userId = _client.auth.currentUser!.id;

    final response = await _client
        .from('profiles')
        .update(data)
        .eq('id', userId)
        .select()
        .single();

    return response;
  }

  /// Complete onboarding for the current user.
  Future<void> completeOnboarding({
    required String fitnessGoal,
    required String experienceLevel,
    required List<String> availableEquipment,
    required int workoutFrequency,
    required int preferredDurationMin,
    required String trainingLocation,
    String? ageRange,
  }) async {
    final userId = _client.auth.currentUser!.id;

    await _client.from('profiles').update({
      'fitness_goal': fitnessGoal,
      'experience_level': experienceLevel,
      'available_equipment': availableEquipment,
      'workout_frequency': workoutFrequency,
      'preferred_duration_min': preferredDurationMin,
      'training_location': trainingLocation,
      'age_range': ageRange,
      'onboarding_completed': true,
    }).eq('id', userId);
  }

  /// Check if the current user has completed onboarding.
  Future<bool> hasCompletedOnboarding() async {
    final profile = await getCurrentProfile();
    return profile?['onboarding_completed'] == true;
  }
}

/// Provider for ProfileRepository.
final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return ProfileRepository(client);
});
