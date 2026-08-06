import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:super_stepper_example/main.dart';

void main() {
  testWidgets('Next changes steps and becomes Finish on the last step',
      (tester) async {
    await tester.pumpWidget(const ExampleApp());

    expect(find.text('Next'), findsOneWidget);
    expect(find.text('Current step: 1 of 4'), findsOneWidget);

    for (var step = 2; step <= 4; step++) {
      await tester.ensureVisible(find.text('Next'));
      await tester.tap(find.text('Next'));
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text('Current step: $step of 4'), findsOneWidget);
    }

    expect(find.text('Next'), findsNothing);
    expect(find.text('Finish'), findsWidgets);

    await tester.ensureVisible(find.widgetWithText(FilledButton, 'Finish'));
    await tester.tap(find.widgetWithText(FilledButton, 'Finish'));
    await tester.pumpAndSettle();

    expect(find.text('All steps are complete.'), findsOneWidget);
  });
}
