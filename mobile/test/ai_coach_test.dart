import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gym3d/features/ai_coach/presentation/providers/ai_coach_providers.dart';
import 'package:gym3d/features/ai_coach/presentation/screens/ai_coach_screen.dart';
import 'package:gym3d/features/ai_coach/presentation/widgets/ai_workout_generator_sheet.dart';

class _TestAiCoachNotifier extends StateNotifier<AiCoachState>
    implements AiCoachNotifier {
  _TestAiCoachNotifier()
      : super(AiCoachState(
          messages: [
            ChatMessageItem(
              id: 'test-1',
              role: 'assistant',
              content: 'Hey! 👋 I\'m your **Gym3D AI Coach**.\n\n'
                  'What are we focusing on today?',
              timestamp: DateTime.now(),
              suggestions: const [
                'How do I perform a squat correctly?',
                'Create a beginner workout',
              ],
            ),
          ],
        ));

  @override
  Future<void> sendMessage(String text) async {}

  @override
  void clearChat() {}
}

void main() {
  group('AI Coach and Generator Tests', () {
    testWidgets('AiCoachScreen renders header, initial greeting, and input field',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            aiCoachStateProvider.overrideWith((ref) => _TestAiCoachNotifier()),
          ],
          child: const MaterialApp(
            home: AiCoachScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('AI Coach'), findsOneWidget);
      expect(find.textContaining('Gym3D AI Coach'), findsOneWidget);
      expect(find.text('Ask me anything about fitness...'), findsOneWidget);
      expect(find.text('How do I perform a squat correctly?'), findsOneWidget);
    });

    testWidgets('AiWorkoutGeneratorSheet renders focus options and generate button',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: AiWorkoutGeneratorSheet(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('AI Workout Generator'), findsOneWidget);
      expect(find.text('TARGET FOCUS'), findsOneWidget);
      expect(find.text('Full Body'), findsOneWidget);
      expect(find.text('Generate Workout'), findsOneWidget);
    });
  });
}
