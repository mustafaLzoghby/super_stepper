import 'package:flutter/material.dart';

/// Connector rendering type.
enum SuperConnectorType {
  /// Solid line.
  solid,

  /// Dashed line.
  dashed,
}

/// Connector styling.
@immutable
class SuperStepperConnectorStyle {
  /// Creates connector styling.
  const SuperStepperConnectorStyle({
    this.type = SuperConnectorType.solid,
    this.thickness = 3,
    this.length = 44,
    this.inactiveColor,
    this.activeColor,
    this.completedColor,
    this.borderRadius = const BorderRadius.all(Radius.circular(100)),
    this.dashLength = 6,
    this.dashGap = 4,
  });

  /// Connector type.
  final SuperConnectorType type;

  /// Line thickness.
  final double thickness;

  /// Desired connector length in the main axis.
  final double length;

  /// Inactive color.
  final Color? inactiveColor;

  /// Active color.
  final Color? activeColor;

  /// Completed color.
  final Color? completedColor;

  /// Corner radius for solid connectors.
  final BorderRadiusGeometry borderRadius;

  /// Length of one dash.
  final double dashLength;

  /// Gap between dashes.
  final double dashGap;
}
