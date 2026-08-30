import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/profile.dart';
import '../../data/repositories/profile_repository.dart';

/// Provides the current user's profile.
final profileProvider = FutureProvider<Profile?>((ref) async {
  try {
    final repo = ref.watch(profileRepositoryProvider);
    final data = await repo.getCurrentProfile();
    if (data == null) return null;
    return Profile.fromJson(data);
  } catch (_) {
    return null;
  }
});
