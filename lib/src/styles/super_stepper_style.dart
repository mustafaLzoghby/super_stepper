import 'package:flutter/material.dart';

/// Default visual styling.
@immutable
class SuperStepperStyle {
  /// Creates stepper styling.
  const SuperStepperStyle({
    this.activeColor,
    this.completedColor,
    this.inactiveColor,
    this.disabledColor,
    this.errorColor,
    this.loadingColor,
    this.foregroundColor,
    this.stepSize = 48,
    this.borderWidth = 2,
    this.borderRadius = const BorderRadius.all(Radius.circular(100)),
    this.glassEffect = false,
    this.glassBlur = 14,
    this.glassOpacity = 0.24,
    this.labelStyle,
    this.subtitleStyle,
    this.activeLabelStyle,
    this.contentPadding = const EdgeInsets.only(top: 24),
    this.verticalContentPadding = const EdgeInsetsDirectional.only(start: 24),
  })  : assert(glassBlur >= 0),
        assert(glassOpacity >= 0 && glassOpacity <= 1);

  /// Active background color.
  final Color? activeColor;

  /// Completed background color.
  final Color? completedColor;

  /// Inactive background color.
  final Color? inactiveColor;

  /// Disabled background color.
  final Color? disabledColor;

  /// Error background color.
  final Color? errorColor;

  /// Loading background color.
  final Color? loadingColor;

  /// Icon and text color inside the step indicator.
  final Color? foregroundColor;

  /// Default indicator width and height.
  final double stepSize;

  /// Indicator border width.
  final double borderWidth;

  /// Indicator shape.
  final BorderRadiusGeometry borderRadius;

  /// Whether indicators use a translucent blurred glass treatment.
  final bool glassEffect;

  /// Background blur strength when [glassEffect] is enabled.
  final double glassBlur;

  /// Indicator color opacity when [glassEffect] is enabled.
  final double glassOpacity;

  /// Default label style.
  final TextStyle? labelStyle;

  /// Default subtitle style.
  final TextStyle? subtitleStyle;

  /// Active label style.
  final TextStyle? activeLabelStyle;

  /// Padding before the current step content.
  final EdgeInsetsGeometry contentPadding;

  /// Padding between a vertical step rail and its content.
  final EdgeInsetsGeometry verticalContentPadding;
}
