import 'dart:ui';

import 'package:flutter/material.dart';

import '../controller/super_stepper_controller.dart';
import '../models/super_step.dart';
import '../models/super_step_state.dart';
import '../styles/super_stepper_animation.dart';
import '../styles/super_stepper_behavior.dart';
import '../styles/super_stepper_connector_style.dart';
import '../styles/super_stepper_style.dart';
import '../typedefs/builders.dart';

/// A highly customizable animated stepper.
class SuperStepper<T> extends StatefulWidget {
  /// Creates a super stepper.
  const SuperStepper({
    super.key,
    required this.steps,
    this.controller,
    this.currentStep,
    this.direction = Axis.horizontal,
    this.style = const SuperStepperStyle(),
    this.animation = const SuperStepperAnimation(),
    this.connectorStyle = const SuperStepperConnectorStyle(),
    this.behavior = const SuperStepperBehavior(),
    this.padding = EdgeInsets.zero,
    this.spacing = 10,
    this.reverse = false,
    this.scrollable = false,
    this.shrinkWrap = false,
    this.physics,
    this.stepBuilder,
    this.connectorBuilder,
    this.labelBuilder,
    this.contentBuilder,
    this.transitionBuilder,
    this.onStepTapped,
    this.onStepChanged,
    this.onStepCompleted,
    this.onCompleted,
    this.onWillChange,
    this.showContent = true,
    this.keepAlive = false,
  }) : assert(
          controller == null || currentStep == null,
          'Provide controller or currentStep, not both.',
        );

  /// Steps to render.
  final List<SuperStep<T>> steps;

  /// Optional state controller.
  final SuperStepperController? controller;

  /// Selected step for controlled mode.
  final int? currentStep;

  /// Main layout axis.
  final Axis direction;

  /// Default style.
  final SuperStepperStyle style;

  /// Animation settings.
  final SuperStepperAnimation animation;

  /// Connector style.
  final SuperStepperConnectorStyle connectorStyle;

  /// Interaction settings.
  final SuperStepperBehavior behavior;

  /// Outer padding.
  final EdgeInsetsGeometry padding;

  /// Space between indicator and label.
  final double spacing;

  /// Reverses visual order.
  final bool reverse;

  /// Wraps the step row or column in a scroll view.
  final bool scrollable;

  /// Whether the scroll view should shrink-wrap.
  final bool shrinkWrap;

  /// Optional scroll physics.
  final ScrollPhysics? physics;

  /// Replaces the default step indicator.
  final SuperStepBuilder<T>? stepBuilder;

  /// Replaces the default connector.
  final SuperConnectorBuilder? connectorBuilder;

  /// Replaces the default title and subtitle area.
  final SuperStepLabelBuilder<T>? labelBuilder;

  /// Replaces current step content.
  final SuperStepContentBuilder<T>? contentBuilder;

  /// Replaces the built-in step transition.
  final SuperStepTransitionBuilder? transitionBuilder;

  /// Called when a step receives a valid tap.
  final ValueChanged<int>? onStepTapped;

  /// Called after selection changes.
  final ValueChanged<int>? onStepChanged;

  /// Called when the controller completes a step through navigation.
  final ValueChanged<int>? onStepCompleted;

  /// Called after navigating beyond the final step through [next].
  final VoidCallback? onCompleted;

  /// Asynchronously approves or blocks selection changes.
  final Future<bool> Function(int currentStep, int targetStep)? onWillChange;

  /// Whether current step content is rendered.
  final bool showContent;

  /// Keeps every step's content mounted to preserve its local widget state.
  final bool keepAlive;

  @override
  State<SuperStepper<T>> createState() => _SuperStepperState<T>();
}

class _SuperStepperState<T> extends State<SuperStepper<T>> {
  late SuperStepperController _internalController;
  bool _ownsController = false;
  final Map<int, GlobalKey> _stepKeys = <int, GlobalKey>{};

  SuperStepperController get _controller =>
      widget.controller ?? _internalController;

  int get _currentIndex {
    if (widget.currentStep != null) {
      return widget.currentStep!.clamp(0, widget.steps.length - 1);
    }
    if (widget.steps.isEmpty) return 0;
    return _controller.currentStep.clamp(0, widget.steps.length - 1);
  }

  @override
  void initState() {
    super.initState();
    _createInternalControllerIfNeeded();
    widget.controller?.addListener(_handleControllerChange);
  }

  void _createInternalControllerIfNeeded() {
    _ownsController = widget.controller == null;
    _internalController = SuperStepperController(
      initialStep: widget.currentStep ?? 0,
    );
    if (_ownsController) {
      _internalController.addListener(_handleControllerChange);
    }
  }

  @override
  void didUpdateWidget(covariant SuperStepper<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?.removeListener(_handleControllerChange);
      if (_ownsController) {
        _internalController.removeListener(_handleControllerChange);
        _internalController.dispose();
      }
      _createInternalControllerIfNeeded();
      widget.controller?.addListener(_handleControllerChange);
    }
    if (oldWidget.currentStep != widget.currentStep) {
      _scheduleScrollToCurrentStep();
    }
  }

  void _handleControllerChange() {
    if (!mounted) return;
    setState(() {});
    _scheduleScrollToCurrentStep();
  }

  void _scheduleScrollToCurrentStep() {
    if (!widget.scrollable) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final stepContext = _stepKeys[_currentIndex]?.currentContext;
      if (stepContext == null) return;
      final scrollable = Scrollable.maybeOf(stepContext);
      final renderObject = stepContext.findRenderObject();
      if (scrollable == null || renderObject == null) return;
      scrollable.position.ensureVisible(
        renderObject,
        alignment: 0.5,
        duration: widget.animation.duration,
        curve: widget.animation.curve,
      );
    });
  }

  SuperStepStatus _statusFor(int index) {
    final step = widget.steps[index];
    if (!step.enabled || _controller.isDisabled(index)) {
      return SuperStepStatus.disabled;
    }
    if (_controller.hasError(index)) return SuperStepStatus.error;
    if (_controller.isLoading(index)) return SuperStepStatus.loading;
    if (index == _currentIndex) return SuperStepStatus.active;
    if (_controller.isCompleted(index)) return SuperStepStatus.completed;
    return SuperStepStatus.inactive;
  }

  bool _canTap(int index, SuperStepStatus status) {
    final behavior = widget.behavior;
    if (!behavior.allowStepTapping || status == SuperStepStatus.disabled) {
      return false;
    }
    if (status == SuperStepStatus.completed) {
      return behavior.allowCompletedStepTapping;
    }
    if (index > _currentIndex && status == SuperStepStatus.inactive) {
      return behavior.allowFutureStepTapping;
    }
    return true;
  }

  Future<void> _selectStep(int index) async {
    final status = _statusFor(index);
    if (!_canTap(index, status) || index == _currentIndex) return;

    final allowed =
        await widget.onWillChange?.call(_currentIndex, index) ?? true;
    if (!allowed || !mounted) return;

    widget.onStepTapped?.call(index);
    if (widget.currentStep == null) {
      if (index < _currentIndex) {
        _controller.uncompleteFrom(index, notify: false);
      }
      _controller.jumpTo(index);
    }
    widget.onStepChanged?.call(index);
  }

  /// Advances the attached or internal controller.
  Future<void> next() async {
    if (widget.steps.isEmpty) return;
    final current = _currentIndex;
    if (current >= widget.steps.length - 1) {
      widget.onCompleted?.call();
      return;
    }

    var target = current + 1;
    if (widget.behavior.skipDisabledSteps) {
      while (target < widget.steps.length &&
          (!widget.steps[target].enabled || _controller.isDisabled(target))) {
        target++;
      }
    }
    if (target >= widget.steps.length) {
      widget.onCompleted?.call();
      return;
    }

    final allowed = await widget.onWillChange?.call(current, target) ?? true;
    if (!allowed || !mounted) return;

    if (widget.behavior.completeStepOnNext && widget.currentStep == null) {
      _controller.complete(current, notify: false);
      widget.onStepCompleted?.call(current);
    }
    if (widget.currentStep == null) _controller.jumpTo(target);
    widget.onStepChanged?.call(target);
  }

  /// Moves to the previous enabled step.
  Future<void> previous() async {
    if (_currentIndex <= 0) return;
    var target = _currentIndex - 1;
    if (widget.behavior.skipDisabledSteps) {
      while (target >= 0 &&
          (!widget.steps[target].enabled || _controller.isDisabled(target))) {
        target--;
      }
    }
    if (target < 0) return;

    final allowed =
        await widget.onWillChange?.call(_currentIndex, target) ?? true;
    if (!allowed || !mounted) return;
    if (widget.currentStep == null) {
      _controller.uncompleteFrom(target, notify: false);
      _controller.jumpTo(target);
    }
    widget.onStepChanged?.call(target);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.steps.isEmpty) return const SizedBox.shrink();

    final generated = List<int>.generate(widget.steps.length, (index) => index);
    final indices = widget.reverse ? generated.reversed.toList() : generated;

    final children = <Widget>[];
    for (var visualIndex = 0; visualIndex < indices.length; visualIndex++) {
      final index = indices[visualIndex];
      children.add(_buildStep(context, index, visualIndex, indices.length));
      if (visualIndex < indices.length - 1) {
        final nextIndex = indices[visualIndex + 1];
        children.add(_buildConnector(context, index, nextIndex));
      }
    }

    Widget stepsWidget = widget.direction == Axis.horizontal
        ? Row(mainAxisSize: MainAxisSize.min, children: children)
        : Column(mainAxisSize: MainAxisSize.min, children: children);

    if (widget.scrollable) {
      stepsWidget = SingleChildScrollView(
        scrollDirection: widget.direction,
        physics: widget.physics,
        child: stepsWidget,
      );
    }

    final Widget body;
    if (widget.direction == Axis.horizontal) {
      body = Column(
        mainAxisSize: widget.shrinkWrap ? MainAxisSize.min : MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(alignment: Alignment.center, child: stepsWidget),
          if (widget.showContent)
            _buildContent(context, padding: widget.style.contentPadding),
        ],
      );
    } else {
      body = Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          stepsWidget,
          if (widget.showContent)
            Expanded(
              child: _buildContent(
                context,
                padding: widget.style.verticalContentPadding,
              ),
            ),
        ],
      );
    }

    return Padding(padding: widget.padding, child: body);
  }

  Widget _buildStep(
    BuildContext context,
    int index,
    int visualIndex,
    int total,
  ) {
    final step = widget.steps[index];
    final status = _statusFor(index);
    final active = status != SuperStepStatus.inactive &&
        status != SuperStepStatus.disabled;

    return KeyedSubtree(
      key: _stepKeys.putIfAbsent(index, GlobalKey.new),
      child: TweenAnimationBuilder<double>(
        key: ValueKey('${step.id ?? index}-$status'),
        tween: Tween(begin: 0, end: active ? 1 : 0),
        duration: widget.animation.duration,
        curve: widget.animation.curve,
        builder: (context, value, child) {
          final state = SuperStepVisualState(
            index: index,
            status: status,
            animationValue: value,
            isFirst: visualIndex == 0,
            isLast: visualIndex == total - 1,
          );
          final indicator = widget.stepBuilder?.call(context, step, state) ??
              _DefaultStepIndicator<T>(
                  step: step, state: state, style: widget.style);
          final transitioned =
              _applyTransition(context, indicator, state, value);
          final label = widget.labelBuilder?.call(context, step, state) ??
              _DefaultStepLabel<T>(
                  step: step, state: state, style: widget.style);

          final child = widget.direction == Axis.horizontal
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    transitioned,
                    SizedBox(height: widget.spacing),
                    label
                  ],
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    transitioned,
                    SizedBox(width: widget.spacing),
                    label
                  ],
                );

          return Semantics(
            button: _canTap(index, status),
            selected: index == _currentIndex,
            enabled: status != SuperStepStatus.disabled,
            label: step.subtitle == null
                ? step.title
                : '${step.title}, ${step.subtitle}',
            child: InkWell(
              borderRadius: widget.style.borderRadius.resolve(
                Directionality.of(context),
              ),
              onTap: _canTap(index, status) ? () => _selectStep(index) : null,
              child: child,
            ),
          );
        },
      ),
    );
  }

  Widget _applyTransition(
    BuildContext context,
    Widget child,
    SuperStepVisualState state,
    double value,
  ) {
    final animation = AlwaysStoppedAnimation<double>(value);
    if (widget.transitionBuilder != null) {
      return widget.transitionBuilder!(context, animation, state, child);
    }
    switch (widget.animation.type) {
      case SuperStepAnimationType.none:
        return child;
      case SuperStepAnimationType.fade:
        return Opacity(opacity: 0.6 + value * 0.4, child: child);
      case SuperStepAnimationType.scale:
        return Transform.scale(scale: 0.9 + value * 0.1, child: child);
      case SuperStepAnimationType.slide:
        return Transform.translate(
            offset: Offset(0, (1 - value) * 5), child: child);
      case SuperStepAnimationType.scaleAndFade:
        return Opacity(
          opacity: 0.7 + value * 0.3,
          child: Transform.scale(scale: 0.9 + value * 0.1, child: child),
        );
    }
  }

  Widget _buildConnector(BuildContext context, int from, int to) {
    final fromStatus = _statusFor(from);
    final completed = fromStatus == SuperStepStatus.completed;
    final active = from == _currentIndex || to == _currentIndex;
    final target = completed ? 1.0 : 0.0;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: target),
      duration: widget.animation.animateConnector
          ? widget.animation.duration
          : Duration.zero,
      curve: widget.animation.curve,
      builder: (context, value, child) {
        final state = SuperConnectorVisualState(
          index: from,
          isActive: active,
          isCompleted: completed,
          animationValue: value,
        );
        return widget.connectorBuilder?.call(context, state) ??
            _DefaultConnector(
              state: state,
              direction: widget.direction,
              style: widget.connectorStyle,
            );
      },
    );
  }

  Widget _buildContent(
    BuildContext context, {
    required EdgeInsetsGeometry padding,
  }) {
    final index = _currentIndex;
    if (widget.keepAlive) {
      return Padding(
        padding: padding,
        child: IndexedStack(
          index: index,
          sizing: StackFit.loose,
          children: List<Widget>.generate(
            widget.steps.length,
            (stepIndex) => KeyedSubtree(
              key: ValueKey(widget.steps[stepIndex].id ?? stepIndex),
              child: _contentFor(context, stepIndex),
            ),
          ),
        ),
      );
    }

    final step = widget.steps[index];
    final content = _contentFor(context, index);
    return Padding(
      padding: padding,
      child: AnimatedSwitcher(
        duration: widget.animation.duration,
        switchInCurve: widget.animation.curve,
        switchOutCurve: widget.animation.curve,
        child: KeyedSubtree(key: ValueKey(step.id ?? index), child: content),
      ),
    );
  }

  Widget _contentFor(BuildContext context, int index) {
    final step = widget.steps[index];
    final state = SuperStepVisualState(
      index: index,
      status: _statusFor(index),
      animationValue: 1,
      isFirst: index == 0,
      isLast: index == widget.steps.length - 1,
    );
    return widget.contentBuilder?.call(context, step, state) ??
        step.content ??
        const SizedBox.shrink();
  }

  @override
  void dispose() {
    widget.controller?.removeListener(_handleControllerChange);
    if (_ownsController) {
      _internalController.removeListener(_handleControllerChange);
      _internalController.dispose();
    }
    super.dispose();
  }
}

class _DefaultStepIndicator<T> extends StatelessWidget {
  const _DefaultStepIndicator({
    required this.step,
    required this.state,
    required this.style,
  });

  final SuperStep<T> step;
  final SuperStepVisualState state;
  final SuperStepperStyle style;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isNeutral = state.status == SuperStepStatus.inactive ||
        state.status == SuperStepStatus.disabled;
    final background = switch (state.status) {
      SuperStepStatus.active => style.activeColor ?? colors.primary,
      SuperStepStatus.completed => style.completedColor ?? colors.tertiary,
      SuperStepStatus.error => style.errorColor ?? colors.error,
      SuperStepStatus.loading => style.loadingColor ?? colors.secondary,
      SuperStepStatus.disabled =>
        style.disabledColor ?? colors.onSurface.withValues(alpha: 0.12),
      SuperStepStatus.inactive =>
        style.inactiveColor ?? colors.surfaceContainerHighest,
    };
    final foreground = style.foregroundColor ??
        (state.status == SuperStepStatus.inactive ||
                state.status == SuperStepStatus.disabled
            ? colors.onSurfaceVariant
            : colors.onPrimary);

    Widget child;
    if (state.isLoading) {
      child = SizedBox.square(
        dimension: style.stepSize * 0.42,
        child: CircularProgressIndicator(strokeWidth: 2.5, color: foreground),
      );
    } else {
      final icon = switch (state.status) {
        SuperStepStatus.completed => step.completedIcon ?? Icons.check_rounded,
        SuperStepStatus.error => step.errorIcon ?? Icons.priority_high_rounded,
        _ => step.icon,
      };
      child = icon != null
          ? Icon(
              icon,
              color: foreground,
              size: style.stepSize * 0.48,
              shadows: style.glassEffect && isNeutral
                  ? [
                      Shadow(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.22)
                            : colors.primary.withValues(alpha: 0.16),
                        blurRadius: 8,
                      ),
                    ]
                  : null,
            )
          : Text(
              '${state.index + 1}',
              style: TextStyle(color: foreground, fontWeight: FontWeight.w700),
            );
    }

    final radius = style.borderRadius.resolve(Directionality.of(context));
    final indicator = AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      width: style.stepSize,
      height: style.stepSize,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: style.glassEffect
            ? background.withValues(alpha: style.glassOpacity)
            : background,
        borderRadius: radius,
        border: Border.all(
          width: style.borderWidth,
          color: style.glassEffect
              ? Colors.white.withValues(
                  alpha: state.isActive ? 0.72 : (isDark ? 0.30 : 0.52),
                )
              : state.isActive
                  ? colors.primaryContainer
                  : Colors.transparent,
        ),
        gradient: style.glassEffect
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withValues(alpha: isDark ? 0.18 : 0.42),
                  background.withValues(alpha: style.glassOpacity),
                ],
              )
            : null,
        boxShadow: style.glassEffect
            ? [
                BoxShadow(
                  color: background.withValues(
                    alpha: state.isActive ? 0.34 : 0.14,
                  ),
                  blurRadius: state.isActive ? 18 : 10,
                  spreadRadius: state.isActive ? 2 : 0,
                  offset: const Offset(0, 6),
                ),
              ]
            : null,
      ),
      child: child,
    );

    if (!style.glassEffect) return indicator;
    return ClipRRect(
      borderRadius: radius,
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: style.glassBlur,
          sigmaY: style.glassBlur,
        ),
        child: indicator,
      ),
    );
  }
}

class _DefaultStepLabel<T> extends StatelessWidget {
  const _DefaultStepLabel({
    required this.step,
    required this.state,
    required this.style,
  });

  final SuperStep<T> step;
  final SuperStepVisualState state;
  final SuperStepperStyle style;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 130),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            step.title,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: state.isActive
                ? style.activeLabelStyle ??
                    theme.labelLarge?.copyWith(fontWeight: FontWeight.w700)
                : style.labelStyle ?? theme.labelLarge,
          ),
          if (step.subtitle != null) ...[
            const SizedBox(height: 2),
            Text(
              step.subtitle!,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: style.subtitleStyle ?? theme.bodySmall,
            ),
          ],
        ],
      ),
    );
  }
}

class _DefaultConnector extends StatelessWidget {
  const _DefaultConnector({
    required this.state,
    required this.direction,
    required this.style,
  });

  final SuperConnectorVisualState state;
  final Axis direction;
  final SuperStepperConnectorStyle style;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final inactive = style.inactiveColor ?? colors.outlineVariant;
    final active = style.activeColor ?? colors.primary.withValues(alpha: 0.55);
    final completed = style.completedColor ?? colors.tertiary;
    final color =
        state.isCompleted ? completed : (state.isActive ? active : inactive);

    final size = direction == Axis.horizontal
        ? Size(style.length, style.thickness)
        : Size(style.thickness, style.length);

    if (style.type == SuperConnectorType.dashed) {
      return CustomPaint(
        size: size,
        painter: _DashedConnectorPainter(
          color: color,
          direction: direction,
          thickness: style.thickness,
          dashLength: style.dashLength,
          dashGap: style.dashGap,
        ),
      );
    }

    return SizedBox.fromSize(
      size: size,
      child: DecoratedBox(
        decoration:
            BoxDecoration(color: color, borderRadius: style.borderRadius),
      ),
    );
  }
}

class _DashedConnectorPainter extends CustomPainter {
  const _DashedConnectorPainter({
    required this.color,
    required this.direction,
    required this.thickness,
    required this.dashLength,
    required this.dashGap,
  });

  final Color color;
  final Axis direction;
  final double thickness;
  final double dashLength;
  final double dashGap;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = thickness
      ..strokeCap = StrokeCap.round;
    final total = direction == Axis.horizontal ? size.width : size.height;
    var offset = 0.0;
    while (offset < total) {
      final end = (offset + dashLength).clamp(0.0, total);
      if (direction == Axis.horizontal) {
        canvas.drawLine(Offset(offset, size.height / 2),
            Offset(end, size.height / 2), paint);
      } else {
        canvas.drawLine(
            Offset(size.width / 2, offset), Offset(size.width / 2, end), paint);
      }
      offset += dashLength + dashGap;
    }
  }

  @override
  bool shouldRepaint(covariant _DashedConnectorPainter oldDelegate) =>
      color != oldDelegate.color ||
      direction != oldDelegate.direction ||
      thickness != oldDelegate.thickness ||
      dashLength != oldDelegate.dashLength ||
      dashGap != oldDelegate.dashGap;
}
