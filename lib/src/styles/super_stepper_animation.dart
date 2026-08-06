import 'package:flutter/animation.dart';
import 'package:flutter/foundation.dart';

/// Built-in transition types.
enum SuperStepAnimationType {
  /// No transition.
  none,

  /// Fade transition.
  fade,

  /// Scale transition.
  scale,

  /// Slide transition.
  slide,

  /// Scale and fade transition.
  scaleAndFade,
}

/// Animation configuration.
@immutable
class SuperStepperAnimation {
  /// Creates animation settings.
  const SuperStepperAnimation({
    this.duration = const Duration(milliseconds: 350),
    this.curve = Curves.easeInOutCubic,
    this.type = SuperStepAnimationType.scaleAndFade,
    this.animateConnector = true,
    this.animateLabels = true,
  });

  /// Transition duration.
  final Duration duration;

  /// Transition curve.
  final Curve curve;

  /// Built-in transition type.
  final SuperStepAnimationType type;

  /// Whether connector progress is animated.
  final bool animateConnector;

  /// Whether labels are animated.
  final bool animateLabels;
}
