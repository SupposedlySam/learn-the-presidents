import 'package:flutter_test/flutter_test.dart';
import 'package:learn_the_presidents/main.dart';

void main() {
  testWidgets('Load and display presidents', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const LearnThePresidentsApp());

    // Verify that the app loads and displays the presidents.
    await tester.pumpAndSettle();

    // Check that the sections are displayed.
    expect(find.text('Section 1'), findsOneWidget);
    expect(find.text('Section 2'), findsOneWidget);

    // Check that the presidents are displayed.
    expect(find.text('George Washington'), findsOneWidget);
    expect(find.text('John Adams'), findsOneWidget);
  });
}
