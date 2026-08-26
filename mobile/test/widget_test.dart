import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gym3d/main.dart';

void main() {
  testWidgets('App launches and shows home screen', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: Gym3DApp(),
      ),
    );
    await tester.pumpAndSettle();

    // Verify the home screen is displayed
    expect(find.text('Ready to train?'), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Exercises'), findsOneWidget);
  });
}
