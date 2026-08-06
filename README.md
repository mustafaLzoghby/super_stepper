# super_stepper

A highly customizable animated stepper for Flutter. It includes useful defaults while allowing package users to replace every important visual part with builders.

## Demo

<img src="https://raw.githubusercontent.com/mustafaLzoghby/super_stepper/main/media/demo.gif" alt="Super Stepper demo" width="360">

## Features

- Horizontal and vertical layouts
- Controller-driven and controlled modes
- Active, completed, inactive, error, loading, and disabled states
- Built-in fade, scale, slide, and combined animations
- Solid and dashed animated connectors
- Custom step, label, connector, content, and transition builders
- Tap restrictions and asynchronous navigation validation
- Scrollable layouts and RTL support
- Generic data on every step
- Material 3 friendly defaults

## Installation

Install the package from pub.dev:

```bash
flutter pub add super_stepper
```

Or add it manually:

```yaml
dependencies:
  super_stepper: ^0.1.2
```

For local package development, use a path dependency:

```yaml
dependencies:
  super_stepper:
    path: ../super_stepper
```

## Basic usage

```dart
final controller = SuperStepperController();

final steps = [
  const SuperStep(
    title: 'Account',
    icon: Icons.person_outline,
    content: Text('Account form'),
  ),
  const SuperStep(
    title: 'Address',
    icon: Icons.location_on_outlined,
    content: Text('Address form'),
  ),
  const SuperStep(
    title: 'Payment',
    icon: Icons.payment_outlined,
    content: Text('Payment form'),
  ),
];

SuperStepper<void>(
  controller: controller,
  steps: steps,
  keepAlive: true,
  style: const SuperStepperStyle(
    glassEffect: true,
    glassBlur: 14,
    glassOpacity: 0.24,
  ),
);
```

Set `keepAlive: true` for forms to preserve text fields, selections, toggles,
and other local widget state while navigating between steps.

Navigation:

```dart
controller.next(totalSteps: steps.length);
controller.previous();
controller.jumpTo(2);
controller.complete(0);
controller.setError(1);
controller.setLoading(2);
controller.disable(1);
controller.reset();
```

React to navigation and handle the final step separately:

```dart
controller.addListener(() {
  final index = controller.currentStep;
  // Save a draft, run analytics, or update surrounding UI.
});

final isLastStep = controller.currentStep == steps.length - 1;

FilledButton(
  onPressed: isLastStep
      ? () async {
          // Submit the completed flow or navigate away.
        }
      : () => controller.next(totalSteps: steps.length),
  child: Text(isLastStep ? 'Finish' : 'Next'),
);
```

## Fully customized indicator

```dart
SuperStepper<void>(
  steps: steps,
  currentStep: 1,
  stepBuilder: (context, step, state) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: state.isActive ? 70 : 48,
      height: 48,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: state.isActive
            ? const LinearGradient(colors: [Colors.blue, Colors.purple])
            : null,
        color: state.isActive ? null : Colors.black12,
      ),
      child: Icon(step.icon),
    );
  },
  connectorBuilder: (context, state) {
    return Container(
      width: 48,
      height: 4,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(100),
        gradient: const LinearGradient(
          colors: [Colors.blue, Colors.purple],
        ),
      ),
    );
  },
);
```

## Form validation

```dart
SuperStepper<void>(
  controller: controller,
  steps: steps,
  onWillChange: (current, target) async {
    if (target > current) {
      return formKeys[current].currentState?.validate() ?? false;
    }
    return true;
  },
);
```

## RTL

`SuperStepper` follows the surrounding `Directionality`, so it works naturally inside Arabic applications:

```dart
Directionality(
  textDirection: TextDirection.rtl,
  child: SuperStepper<void>(steps: steps),
);
```

## Publishing checklist

Before publishing, update `homepage`, `repository`, and `issue_tracker` in `pubspec.yaml`, then run:

```bash
flutter pub get
flutter analyze
flutter test
dart format .
dart pub publish --dry-run
```

## License

MIT
