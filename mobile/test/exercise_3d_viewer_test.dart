import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym3d/features/exercises/data/models/exercise.dart';
import 'package:gym3d/features/exercises/presentation/widgets/exercise_3d_viewer.dart';
import 'package:gym3d/features/exercises/presentation/widgets/muscle_engagement_overlay.dart';

void main() {
  group('3D Viewer and Muscle Overlay Tests', () {
    testWidgets('MuscleEngagementOverlay renders primary and secondary muscles',
        (WidgetTester tester) async {
      const muscles = [
        ExerciseMuscle(
          id: '1',
          role: 'primary',
          muscle: Muscle(
            id: 'm1',
            name: 'Quadriceps',
            slug: 'quadriceps',
            muscleGroup: 'Legs',
            bodyRegion: 'lower',
          ),
        ),
        ExerciseMuscle(
          id: '2',
          role: 'secondary',
          muscle: Muscle(
            id: 'm2',
            name: 'Glutes',
            slug: 'glutes',
            muscleGroup: 'Legs',
            bodyRegion: 'lower',
          ),
        ),
      ];

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MuscleEngagementOverlay(muscles: muscles),
          ),
        ),
      );

      expect(find.text('Muscle Activation'), findsOneWidget);
      expect(find.text('Quadriceps'), findsOneWidget);
      expect(find.text('Glutes'), findsOneWidget);
      expect(find.text('PRIMARY (100% ACTIVATION)'), findsOneWidget);
      expect(find.text('SECONDARY (SUPPORTING)'), findsOneWidget);
    });

    testWidgets('Exercise3DViewer renders with camera controls and fallback preview',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Exercise3DViewer(
              exerciseName: 'Barbell Squat',
              category: 'legs',
            ),
          ),
        ),
      );

      // Verify camera preset buttons are rendered
      expect(find.text('Front'), findsOneWidget);
      expect(find.text('45°'), findsOneWidget);
      expect(find.text('Side'), findsOneWidget);
      expect(find.text('Back'), findsOneWidget);

      // Verify fallback preview is rendered
      expect(find.text('3D Form Preview'), findsOneWidget);
    });
  });
}
