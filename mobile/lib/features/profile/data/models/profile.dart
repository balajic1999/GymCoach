import 'package:equatable/equatable.dart';

/// User profile model matching the Supabase profiles table.
class Profile extends Equatable {
  final String id;
  final String? fullName;
  final String? avatarUrl;
  final String? fitnessGoal;
  final String? experienceLevel;
  final List<String> availableEquipment;
  final int? workoutFrequency;
  final int? preferredDurationMin;
  final String? trainingLocation;
  final String? ageRange;
  final String subscriptionTier;
  final bool onboardingCompleted;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Profile({
    required this.id,
    this.fullName,
    this.avatarUrl,
    this.fitnessGoal,
    this.experienceLevel,
    this.availableEquipment = const [],
    this.workoutFrequency,
    this.preferredDurationMin,
    this.trainingLocation,
    this.ageRange,
    this.subscriptionTier = 'free',
    this.onboardingCompleted = false,
    this.createdAt,
    this.updatedAt,
  });

  bool get isPro => subscriptionTier == 'pro';

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json['id'] as String,
      fullName: json['full_name'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      fitnessGoal: json['fitness_goal'] as String?,
      experienceLevel: json['experience_level'] as String?,
      availableEquipment: (json['available_equipment'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      workoutFrequency: json['workout_frequency'] as int?,
      preferredDurationMin: json['preferred_duration_min'] as int?,
      trainingLocation: json['training_location'] as String?,
      ageRange: json['age_range'] as String?,
      subscriptionTier: (json['subscription_tier'] as String?) ?? 'free',
      onboardingCompleted: (json['onboarding_completed'] as bool?) ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'full_name': fullName,
        'avatar_url': avatarUrl,
        'fitness_goal': fitnessGoal,
        'experience_level': experienceLevel,
        'available_equipment': availableEquipment,
        'workout_frequency': workoutFrequency,
        'preferred_duration_min': preferredDurationMin,
        'training_location': trainingLocation,
        'age_range': ageRange,
        'subscription_tier': subscriptionTier,
        'onboarding_completed': onboardingCompleted,
      };

  Profile copyWith({
    String? fullName,
    String? avatarUrl,
    String? fitnessGoal,
    String? experienceLevel,
    List<String>? availableEquipment,
    int? workoutFrequency,
    int? preferredDurationMin,
    String? trainingLocation,
    String? ageRange,
    String? subscriptionTier,
    bool? onboardingCompleted,
  }) {
    return Profile(
      id: id,
      fullName: fullName ?? this.fullName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      fitnessGoal: fitnessGoal ?? this.fitnessGoal,
      experienceLevel: experienceLevel ?? this.experienceLevel,
      availableEquipment: availableEquipment ?? this.availableEquipment,
      workoutFrequency: workoutFrequency ?? this.workoutFrequency,
      preferredDurationMin: preferredDurationMin ?? this.preferredDurationMin,
      trainingLocation: trainingLocation ?? this.trainingLocation,
      ageRange: ageRange ?? this.ageRange,
      subscriptionTier: subscriptionTier ?? this.subscriptionTier,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  @override
  List<Object?> get props => [id];
}
