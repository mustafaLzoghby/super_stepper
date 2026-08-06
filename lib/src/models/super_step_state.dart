import 'package:flutter/foundation.dart';

/// Visual status of a step.
enum SuperStepStatus {
  /// A future or unselected step.
  inactive,

  /// The currently selected step.
  active,

  /// A completed step.
  completed,

  /// A disabled step.
  disabled,

  /// A step with an error.
  error,

  /// A step currently loading.
  loading,
}

/// State passed to step and label builders.
@immutable
class SuperStepVisualState {
  /// Creates visual state information.
  const SuperStepVisualState({
    required this.index,
    required this.status,
    required this.animationValue,
    required this.isFirst,
    required this.isLast,
  });

  /// Step index.
  final int index;

  /// Current status.
  final SuperStepStatus status;

  /// Current animation value from 0 to 1.
  final double animationValue;

  /// Whether this is the first rendered step.
  final bool isFirst;

  /// Whether this is the last rendered step.
  final bool isLast;

  /// Whether the step is active.
  bool get isActive => status == SuperStepStatus.active;

  /// Whether the step is completed.
  bool get isCompleted => status == SuperStepStatus.completed;

  /// Whether the step has an error.
  bool get hasError => status == SuperStepStatus.error;

  /// Whether the step is disabled.
  bool get isDisabled => status == SuperStepStatus.disabled;

  /// Whether the step is loading.
  bool get isLoading => status == SuperStepStatus.loading;
}

/// State passed to connector builders.
@immutable
class SuperConnectorVisualState {
  /// Creates connector state information.
  const SuperConnectorVisualState({
    required this.index,
    required this.isActive,
    required this.isCompleted,
    required this.animationValue,
  });

  /// Connector index. Connects step [index] to step [index + 1].
  final int index;

  /// Whether either adjacent step is active.
  final bool isActive;

  /// Whether the step before the connector is completed.
  final bool isCompleted;

  /// Animated completion value from 0 to 1.
  final double animationValue;
}
