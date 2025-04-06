/*---------------------------------------------------------------------------------------------
*  Copyright (c) nt4f04und. All rights reserved.
*  Licensed under the BSD-style license. See LICENSE in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import 'package:flutter/cupertino.dart';
import 'package:nt4f04unds_widgets/nt4f04unds_widgets.dart';

/// Rrebuilds when the given animation changes status.
///
/// See also:
/// * [AnimationStrategyBuilder] which rebuilds every time evaluated animation strategy
///   value changes
class AnimationStatusBuilder extends StatusTransitionWidget {
  AnimationStatusBuilder({Key? key, required Animation<double> animation, required this.builder, this.child})
    : super(key: key, animation: animation);

  final Widget? child;
  final TransitionBuilder builder;

  @override
  Widget build(BuildContext context) {
    return builder(context, child);
  }
}

/// Rebuilds when the given animation changes status and if [strategy] value
/// changes from this stats change.
///
/// See also:
/// * [AnimationStatusBuilder] which rebuilds every time animation status changes
class AnimationStrategyBuilder<T> extends StatefulWidget {
  const AnimationStrategyBuilder({
    Key? key,
    required this.animation,
    required this.strategy,
    required this.builder,
    this.child,
  }) : super(key: key);

  /// Animation this widget listens to end uses to evaluate the [strategy].
  final Animation<double> animation;

  /// Animation strategy to evaluate with [animation].
  /// The widget will be rebuilt only when the evaluated values changes.
  final AnimationStrategy<T> strategy;

  /// The child widget to pass to the [builder].
  final Widget? child;

  /// Receives a [strategy] evaluated with [animation].
  final ValueWidgetBuilder<T> builder;

  @override
  _AnimationStrategyBuilderState<T> createState() => _AnimationStrategyBuilderState<T>();
}

class _AnimationStrategyBuilderState<T> extends State<AnimationStrategyBuilder<T>> {
  AnimationStatus? _prevStatus;

  @override
  void initState() {
    super.initState();
    widget.animation.addStatusListener(_animationStatusChanged);
  }

  @override
  void didUpdateWidget(AnimationStrategyBuilder<T> oldWidget) {
    if (widget.animation != oldWidget.animation) {
      oldWidget.animation.removeStatusListener(_animationStatusChanged);
      widget.animation.addStatusListener(_animationStatusChanged);
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    widget.animation.removeStatusListener(_animationStatusChanged);
    super.dispose();
  }

  void _animationStatusChanged(AnimationStatus status) {
    T? prevValue;
    if (_prevStatus != null) prevValue = widget.strategy.decide(_prevStatus!);
    final value = widget.strategy.decide(status);
    if (prevValue != value) {
      _prevStatus = status;
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, widget.strategy.ask(widget.animation), widget.child);
  }
}
