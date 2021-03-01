/*---------------------------------------------------------------------------------------------
*  Copyright (c) nt4f04und. All rights reserved.
*  Licensed under the BSD-style license. See LICENSE in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:nt4f04unds_widgets/nt4f04unds_widgets.dart';

/// A wrapper to create buttons that have pressing animation.
/// Doesn't draw any by itslef.
/// 
/// todo: allow custrom transition builders
class ResponsiveWidget extends StatefulWidget {
  ResponsiveWidget({
    Key key,
    @required this.child,
    this.disabled = false,
    this.duration = const Duration(milliseconds: 100),
    this.onPressed,
    this.offset = 2.0,
  }) : super(key: key);

  final Widget child;
  final bool disabled;
  final Duration duration;
  final Function onPressed;

  /// Max offset applied to widget at the end of animation when it's pressed.
  final double offset;

  @override
  ResponsiveWidgetState createState() => ResponsiveWidgetState();
}

class ResponsiveWidgetState extends State<ResponsiveWidget>
    with SingleTickerProviderStateMixin {

  AnimationController controller;
  CancelableOperation operation;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> moveDown() async {
    if (controller.isDismissed) {
      controller.duration = widget.duration;
    } else {
      // Slow if tapped on the not dismissed state.
      controller.duration = widget.duration + Duration(milliseconds: (widget.duration.inMilliseconds / 2 * controller.value).toInt());
    }
    operation?.cancel();
    operation = CancelableOperation.fromFuture(controller.forward());
  }

  Future<void> moveUp() async {
    await operation?.valueOrCancellation();
    if (operation != null && operation.isCompleted) {
      controller.reverse();
    }
    operation = null;
  }

  @override
  Widget build(BuildContext context) {
    final animation = NFDefaultAnimation(parent: controller);
    if (widget.disabled && controller.value != 0.0) {
      moveUp();
    }
    return IgnorePointer(
      ignoring: widget.disabled,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onPanDown: (_) {
          moveDown();
        },
        onTapUp: (_) {
          try {
            if (widget.onPressed != null && !widget.disabled)
              widget.onPressed();
          } finally {
            moveUp();
          }
        },
        onPanEnd: (_) {
          moveUp();
        },
        onPanCancel: () {
          moveUp();
        },
        child: AnimatedBuilder(
          animation: animation,
          child: widget.child,
          builder: (BuildContext context, Widget child) => Transform.translate(
            offset: Offset(0.0, widget.offset * animation.value),
            child: child,
          ),
        ),
      ),
    );
  }
}
