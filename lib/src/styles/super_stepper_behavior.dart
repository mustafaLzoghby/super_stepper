import 'package:flutter/foundation.dart';

/// Interaction rules.
@immutable
class SuperStepperBehavior {
  /// Creates behavior settings.
  const SuperStepperBehavior({
    this.allowStepTapping = true,
    this.allowCompletedStepTapping = true,
    this.allowFutureStepTapping = false,
    this.completeStepOnNext = true,
    this.skipDisabledSteps = true,
  });

  /// Whether any enabled step can receive taps.
  final bool allowStepTapping;

  /// Whether completed steps can receive taps.
  final bool allowCompletedStepTapping;

  /// Whether future inactive steps can receive taps.
  final bool allowFutureStepTapping;

  /// Whether the controller completes the current step on next.
  final bool completeStepOnNext;

  /// Whether next and previous ignore disabled steps.
  final bool skipDisabledSteps;
}
