import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:super_stepper/super_stepper.dart';

void main() {
  group('SuperStepperController', () {
    test('moves forward and completes current step', () {
      final controller = SuperStepperController();

      controller.next(totalSteps: 3);

      expect(controller.currentStep, 1);
      expect(controller.isCompleted(0), isTrue);
    });

    test('skips disabled steps', () {
      final controller = SuperStepperController()..disable(1);

      controller.next(totalSteps: 3);

      expect(controller.currentStep, 2);
    });

    test('error replaces completed state', () {
      final controller = SuperStepperController()..complete(0);

      controller.setError(0);

      expect(controller.hasError(0), isTrue);
      expect(controller.isCompleted(0), isFalse);
    });

    test('going back clears completion from the destination onward', () {
      final controller = SuperStepperController();

      controller.next(totalSteps: 3);
      controller.next(totalSteps: 3);
      expect(controller.completedSteps, containsAll(<int>[0, 1]));

      controller.previous();
      expect(controller.currentStep, 1);
      expect(controller.completedSteps, isNot(contains(1)));
      expect(controller.completedSteps, contains(0));

      controller.previous();
      expect(controller.currentStep, 0);
      expect(controller.completedSteps, isEmpty);
    });
  });

  testWidgets('keepAlive preserves form state between steps', (tester) async {
    final controller = SuperStepperController();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SuperStepper<void>(
            controller: controller,
            keepAlive: true,
            steps: const [
              SuperStep<void>(
                title: 'Details',
                content: TextField(key: Key('name-field')),
              ),
              SuperStep<void>(title: 'Confirm', content: Text('Confirm')),
            ],
          ),
        ),
      ),
    );

    await tester.enterText(find.byKey(const Key('name-field')), 'Mustafa');
    controller.next(totalSteps: 2);
    await tester.pumpAndSettle();
    controller.previous();
    await tester.pumpAndSettle();

    expect(find.text('Mustafa'), findsOneWidget);
  });

  testWidgets('glass indicators render in light and dark mode', (tester) async {
    for (final brightness in Brightness.values) {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            brightness: brightness,
            colorSchemeSeed: Colors.indigo,
          ),
          home: const Scaffold(
            body: SuperStepper<void>(
              showContent: false,
              style: SuperStepperStyle(glassEffect: true),
              steps: [
                SuperStep<void>(title: 'Active', icon: Icons.person),
                SuperStep<void>(title: 'Inactive', icon: Icons.payment),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(BackdropFilter), findsNWidgets(2));
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('vertical layout places content beside the step rail',
      (tester) async {
    for (final textDirection in TextDirection.values) {
      await tester.pumpWidget(
        MaterialApp(
          home: Directionality(
            textDirection: textDirection,
            child: const Scaffold(
              body: SizedBox(
                width: 500,
                child: SuperStepper<void>(
                  direction: Axis.vertical,
                  steps: [
                    SuperStep<void>(
                      title: 'Rail step',
                      content: Text('Side content'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

      final railCenter = tester.getCenter(find.text('Rail step'));
      final contentCenter = tester.getCenter(find.text('Side content'));
      if (textDirection == TextDirection.ltr) {
        expect(contentCenter.dx, greaterThan(railCenter.dx));
      } else {
        expect(contentCenter.dx, lessThan(railCenter.dx));
      }
    }
  });
}
