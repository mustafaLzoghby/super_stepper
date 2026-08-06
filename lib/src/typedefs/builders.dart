import 'package:flutter/widgets.dart';

import '../models/super_step.dart';
import '../models/super_step_state.dart';

/// Builds a complete step indicator.
typedef SuperStepBuilder<T> = Widget Function(
  BuildContext context,
  SuperStep<T> step,
  SuperStepVisualState state,
);

/// Builds the label area under or beside a step.
typedef SuperStepLabelBuilder<T> = Widget Function(
  BuildContext context,
  SuperStep<T> step,
  SuperStepVisualState state,
);

/// Builds the content of the current step.
typedef SuperStepContentBuilder<T> = Widget Function(
  BuildContext context,
  SuperStep<T> step,
  SuperStepVisualState state,
);

/// Builds a connector.
typedef SuperConnectorBuilder = Widget Function(
  BuildContext context,
  SuperConnectorVisualState state,
);

/// Wraps a step with a custom transition.
typedef SuperStepTransitionBuilder = Widget Function(
  BuildContext context,
  Animation<double> animation,
  SuperStepVisualState state,
  Widget child,
);
