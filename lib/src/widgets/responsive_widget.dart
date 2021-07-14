/*---------------------------------------------------------------------------------------------
*  Copyright (c) nt4f04und. All rights reserved.
*  Licensed under the BSD-style license. See LICENSE in the project root for license information.
*--------------------------------------------------------------------------------------------*/

// todo: maybe allow custrom transition builders

import 'package:async/async.dart';
import 'package:flutter/material.dart';

/// When pressed, animates down like a button, and then animates back up, 
/// when user unpresses it.
class ResponsiveWidget extends StatefulWidget {
  ResponsiveWidget({
    Key? key,
    required this.child,
    required this.onPressed,
    this.offset = 2.0,
    this.duration = const Duration(milliseconds: 100),
    this.reverseDuration,
    this.curve = Curves.easeOutCubic,
    this.reverseCurve = Curves.easeInCubic,
  }) : super(key: key);

  /// The widget below this widget in the tree.
  final Widget? child;

  /// The callback that is called when the widget is tapped or otherwise activated.
  ///
  /// If this is set to null, the widget will be disabled.
  final VoidCallback? onPressed;

  /// Max offset applied to widget at the end of animation when it's pressed.
  final double offset;

  /// The duration of the move down animation.
  final Duration duration;

  /// The duration of the move up animation.
  final Duration? reverseDuration;

  /// The curve to use for move down animation.
  final Curve curve;
  
  /// The curve to use for move up animation.
  final Curve reverseCurve;

  @override
  _ResponsiveWidgetState createState() => _ResponsiveWidgetState();
}

class _ResponsiveWidgetState extends State<ResponsiveWidget> with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> animation;
  CancelableOperation? operation;
  bool get _enabled => widget.onPressed != null;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: widget.duration,
      reverseDuration: widget.reverseDuration,
    );
    _createAnimation();
  }

  @override
  void didUpdateWidget(covariant ResponsiveWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    controller.duration = widget.duration;
    controller.reverseDuration = widget.reverseDuration;
    if (oldWidget.curve != widget.curve || oldWidget.reverseCurve != widget.reverseCurve) {
      _createAnimation();
    }
    if (!_enabled) {
      _moveUp();
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _createAnimation() {
    animation = CurvedAnimation(
      curve: widget.curve,
      reverseCurve: widget.reverseCurve,
      parent: controller
    );
  }

  void _moveDown() {
    if (controller.isDismissed) {
      controller.duration = widget.duration;
    } else {
      // Slow if tapped on the not dismissed state.
      controller.duration = widget.duration + Duration(milliseconds: (widget.duration.inMilliseconds / 2 * controller.value).toInt());
    }
    operation?.cancel();
    operation = CancelableOperation.fromFuture(controller.forward());
  }

  Future<void> _moveUp() async {
    await operation?.valueOrCancellation();
    if (operation?.isCompleted ?? false) {
      controller.reverse();
    }
    operation = null;
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: !_enabled,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onPanDown: (_) => _moveDown(),
        onPanEnd: (_) => _moveUp(),
        onPanCancel: () => _moveUp(),
        onTapUp: (_) {
          try {
            widget.onPressed?.call();
          } finally {
            _moveUp();
          }
        },
        child: AnimatedBuilder(
          animation: animation,
          child: widget.child,
          builder: (BuildContext context, Widget? child) => Transform.translate(
            offset: Offset(0.0, widget.offset * animation.value),
            child: child,
          ),
        ),
      ),
    );
  }
}
