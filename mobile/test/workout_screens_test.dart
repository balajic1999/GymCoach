import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gym3d/features/workout/presentation/screens/create_workout_screen.dart';
import 'package:gym3d/features/workout/presentation/screens/active_workout_screen.dart';

void main() {
  group('Workout Creation & Execution Tests', () {
    testWidgets('CreateWorkoutScreen renders form and exercise section',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: CreateWorkoutScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Create Workout'), findsOneWidget);
      expect(find.text('WORKOUT DETAILS'), findsOneWidget);
      expect(find.text('Save'), findsOneWidget);
      expect(find.text('Add Exercise'), findsOneWidget);
      expect(find.text('Save Workout'), findsOneWidget);
    });

    testWidgets('ActiveWorkoutScreen renders stopwatch, exercise header, and set logging table',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: ActiveWorkoutScreen(
              workoutTitle: 'Leg Day Blast',
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Leg Day Blast'), findsOneWidget);
      expect(find.text('Finish'), findsOneWidget);
      expect(find.text('SET'), findsOneWidget);
      expect(find.text('KG'), findsOneWidget);
      expect(find.text('REPS'), findsOneWidget);
      expect(find.text('DONE'), findsOneWidget);
    });
  });
}
