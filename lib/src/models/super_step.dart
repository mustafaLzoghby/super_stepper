import 'package:flutter/widgets.dart';

/// Describes one item displayed by [SuperStepper].
@immutable
class SuperStep<T> {
  /// Creates a step.
  const SuperStep({
    required this.title,
    this.id,
    this.subtitle,
    this.icon,
    this.completedIcon,
    this.errorIcon,
    this.content,
    this.data,
    this.enabled = true,
  });

  /// Optional stable identifier.
  final String? id;

  /// Main label.
  final String title;

  /// Secondary label.
  final String? subtitle;

  /// Default icon.
  final IconData? icon;

  /// Icon used when the step is completed.
  final IconData? completedIcon;

  /// Icon used when the step has an error.
  final IconData? errorIcon;

  /// Optional content associated with this step.
  final Widget? content;

  /// Arbitrary data supplied by the package user.
  final T? data;

  /// Whether this step can be selected.
  final bool enabled;
}
