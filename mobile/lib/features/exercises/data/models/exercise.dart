import 'package:equatable/equatable.dart';

/// Exercise model with related muscles and equipment.
class Exercise extends Equatable {
  final String id;
  final String name;
  final String slug;
  final String? description;
  final String category;
  final String difficulty;
  final List<String> instructions;
  final String? breathing;
  final List<String> commonMistakes;
  final List<String> safetyNotes;
  final String? thumbnailUrl;
  final String? animationAssetUrl;
  final String? characterAssetUrl;
  final String? videoUrl;
  final int defaultSets;
  final int defaultReps;
  final int defaultRestSeconds;
  final bool isFree;
  final String status;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final List<ExerciseMuscle> muscles;
  final List<ExerciseEquipment> equipment;

  const Exercise({
    required this.id,
    required this.name,
    required this.slug,
    this.description,
    required this.category,
    required this.difficulty,
    this.instructions = const [],
    this.breathing,
    this.commonMistakes = const [],
    this.safetyNotes = const [],
    this.thumbnailUrl,
    this.animationAssetUrl,
    this.characterAssetUrl,
    this.videoUrl,
    this.defaultSets = 3,
    this.defaultReps = 10,
    this.defaultRestSeconds = 60,
    this.isFree = false,
    this.status = 'published',
    this.createdAt,
    this.updatedAt,
    this.muscles = const [],
    this.equipment = const [],
  });

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      id: json['id'] as String,
      name: json['name'] as String,
      slug: json['slug'] as String,
      description: json['description'] as String?,
      category: json['category'] as String,
      difficulty: json['difficulty'] as String,
      instructions: (json['instructions'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      breathing: json['breathing'] as String?,
      commonMistakes: (json['common_mistakes'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      safetyNotes: (json['safety_notes'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      thumbnailUrl: json['thumbnail_url'] as String?,
      animationAssetUrl: json['animation_asset_url'] as String?,
      characterAssetUrl: json['character_asset_url'] as String?,
      videoUrl: json['video_url'] as String?,
      defaultSets: (json['default_sets'] as int?) ?? 3,
      defaultReps: (json['default_reps'] as int?) ?? 10,
      defaultRestSeconds: (json['default_rest_seconds'] as int?) ?? 60,
      isFree: (json['is_free'] as bool?) ?? false,
      status: (json['status'] as String?) ?? 'published',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      muscles: (json['exercise_muscles'] as List<dynamic>?)
              ?.map((e) => ExerciseMuscle.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      equipment: (json['exercise_equipment'] as List<dynamic>?)
              ?.map((e) => ExerciseEquipment.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'slug': slug,
        'description': description,
        'category': category,
        'difficulty': difficulty,
        'instructions': instructions,
        'breathing': breathing,
        'common_mistakes': commonMistakes,
        'safety_notes': safetyNotes,
        'thumbnail_url': thumbnailUrl,
        'animation_asset_url': animationAssetUrl,
        'character_asset_url': characterAssetUrl,
        'video_url': videoUrl,
        'default_sets': defaultSets,
        'default_reps': defaultReps,
        'default_rest_seconds': defaultRestSeconds,
        'is_free': isFree,
        'status': status,
      };

  Exercise copyWith({
    String? id,
    String? name,
    String? slug,
    String? description,
    String? category,
    String? difficulty,
    List<String>? instructions,
    String? breathing,
    List<String>? commonMistakes,
    List<String>? safetyNotes,
    String? thumbnailUrl,
    String? animationAssetUrl,
    String? characterAssetUrl,
    String? videoUrl,
    int? defaultSets,
    int? defaultReps,
    int? defaultRestSeconds,
    bool? isFree,
    String? status,
    List<ExerciseMuscle>? muscles,
    List<ExerciseEquipment>? equipment,
  }) {
    return Exercise(
      id: id ?? this.id,
      name: name ?? this.name,
      slug: slug ?? this.slug,
      description: description ?? this.description,
      category: category ?? this.category,
      difficulty: difficulty ?? this.difficulty,
      instructions: instructions ?? this.instructions,
      breathing: breathing ?? this.breathing,
      commonMistakes: commonMistakes ?? this.commonMistakes,
      safetyNotes: safetyNotes ?? this.safetyNotes,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      animationAssetUrl: animationAssetUrl ?? this.animationAssetUrl,
      characterAssetUrl: characterAssetUrl ?? this.characterAssetUrl,
      videoUrl: videoUrl ?? this.videoUrl,
      defaultSets: defaultSets ?? this.defaultSets,
      defaultReps: defaultReps ?? this.defaultReps,
      defaultRestSeconds: defaultRestSeconds ?? this.defaultRestSeconds,
      isFree: isFree ?? this.isFree,
      status: status ?? this.status,
      muscles: muscles ?? this.muscles,
      equipment: equipment ?? this.equipment,
    );
  }

  @override
  List<Object?> get props => [id, slug];
}

/// Junction model linking exercises to muscles.
class ExerciseMuscle extends Equatable {
  final String id;
  final String role;
  final Muscle? muscle;

  const ExerciseMuscle({
    required this.id,
    required this.role,
    this.muscle,
  });

  factory ExerciseMuscle.fromJson(Map<String, dynamic> json) {
    return ExerciseMuscle(
      id: json['id'] as String,
      role: json['role'] as String,
      muscle: json['muscle'] != null
          ? Muscle.fromJson(json['muscle'] as Map<String, dynamic>)
          : null,
    );
  }

  @override
  List<Object?> get props => [id];
}

/// Muscle model.
class Muscle extends Equatable {
  final String id;
  final String name;
  final String slug;
  final String muscleGroup;
  final String bodyRegion;
  final String? description;
  final int sortOrder;

  const Muscle({
    required this.id,
    required this.name,
    required this.slug,
    required this.muscleGroup,
    required this.bodyRegion,
    this.description,
    this.sortOrder = 0,
  });

  factory Muscle.fromJson(Map<String, dynamic> json) {
    return Muscle(
      id: json['id'] as String,
      name: json['name'] as String,
      slug: json['slug'] as String,
      muscleGroup: json['muscle_group'] as String,
      bodyRegion: json['body_region'] as String,
      description: json['description'] as String?,
      sortOrder: (json['sort_order'] as int?) ?? 0,
    );
  }

  @override
  List<Object?> get props => [id, slug];
}

/// Equipment model.
class Equipment extends Equatable {
  final String id;
  final String name;
  final String slug;
  final String? category;
  final String? description;
  final String? iconUrl;

  const Equipment({
    required this.id,
    required this.name,
    required this.slug,
    this.category,
    this.description,
    this.iconUrl,
  });

  factory Equipment.fromJson(Map<String, dynamic> json) {
    return Equipment(
      id: json['id'] as String,
      name: json['name'] as String,
      slug: json['slug'] as String,
      category: json['category'] as String?,
      description: json['description'] as String?,
      iconUrl: json['icon_url'] as String?,
    );
  }

  @override
  List<Object?> get props => [id, slug];
}

/// Junction model linking exercises to equipment.
class ExerciseEquipment extends Equatable {
  final String id;
  final bool isPrimary;
  final Equipment? equipment;

  const ExerciseEquipment({
    required this.id,
    this.isPrimary = true,
    this.equipment,
  });

  factory ExerciseEquipment.fromJson(Map<String, dynamic> json) {
    return ExerciseEquipment(
      id: json['id'] as String,
      isPrimary: (json['is_primary'] as bool?) ?? true,
      equipment: json['equipment'] != null
          ? Equipment.fromJson(json['equipment'] as Map<String, dynamic>)
          : null,
    );
  }

  @override
  List<Object?> get props => [id];
}
