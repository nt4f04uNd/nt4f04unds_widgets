/*---------------------------------------------------------------------------------------------
*  Copyright (c) nt4f04und. All rights reserved.
*  Licensed under the BSD-style license. See LICENSE in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import 'package:flutter/material.dart';
import 'package:nt4f04unds_widgets/nt4f04unds_widgets.dart';

/// Makes the [route] dismissible.
class DismissibleRoute extends StatefulWidget {
  DismissibleRoute({
    Key? key,
    required this.route,
    required this.child,
    required this.animatedChild,
    Widget? dismissBarrier,
    this.dismissDirection = SlideDirection.right,
  }) : dismissBarrier = dismissBarrier ?? Container(color: Colors.black26),
       super(key: key);

  static late final springDescription = SpringDescription.withDampingRatio(mass: 0.01, stiffness: 200.0, ratio: 3.0);

  /// Returns controller of the nearest dismissible route.
  static SlidableController? controllerOf(BuildContext context) {
    return SlidableController.maybeOf<DismissibleRoute>(context);
  }

  /// Route that will be dismissible.
  final TransitionRoute route;

  /// Bare child provided by the [route].
  final Widget child;

  /// The [child] wrapped into transitions which will be displayed on route push and pop.
  final Widget animatedChild;

  /// The widget to show as barrier when route is being dragged.
  ///
  /// If none specified, [Container] with color [Colors.black26] is used.
  final Widget? dismissBarrier;

  /// The direction of the swipe to dismiss the route.
  final SlideDirection dismissDirection;

  @override
  DismissibleRouteState createState() => DismissibleRouteState();
}

class DismissibleRouteState extends State<DismissibleRoute> with TickerProviderStateMixin {
  bool _dragged = false;

  /// Whether route has been dismissed by users swipe.
  /// Needed to determine whether to show a barrier and shadow from the route.
  bool _beenDismissed = false;

  /// Whether should the barrier be visible.
  bool get _showBarrier =>
      widget.route.animation!.isCompleted ||
      // Do not show when route went out out of the screen after dismissal
      _beenDismissed && !widget.route.animation!.isDismissed ||
      _dragged && widget.route.animation!.status == AnimationStatus.forward;

  late SlidableController _controller;

  /// Controller to manipulate the route shadow.
  late AnimationController _boxDecorationController;
  late Animation<Decoration> _boxDecorationAnimation;

  // ignore: invalid_use_of_protected_member
  AnimationController get _routeAnimationController => widget.route.controller!;

  @override
  void initState() {
    super.initState();
    _controller = SlidableController(vsync: this, springDescription: DismissibleRoute.springDescription);
    _boxDecorationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _boxDecorationAnimation = DecorationTween(
      begin: const BoxDecoration(boxShadow: [BoxShadow(color: Colors.transparent)]),
      end: const BoxDecoration(boxShadow: [BoxShadow(color: Colors.black12, spreadRadius: 2.0, blurRadius: 2.0)]),
    ).animate(CurvedAnimation(curve: Curves.easeOutCubic, parent: _boxDecorationController));
    _routeAnimationController.addStatusListener(_handleAnimationStatus);
  }

  @override
  void dispose() {
    _routeAnimationController.removeStatusListener(_handleAnimationStatus);
    _controller.dispose();
    _boxDecorationController.dispose();
    super.dispose();
  }

  /// Used to disable dismiss gesture while pop animation is being performed.
  bool _popAnimating = false;
  void _handleAnimationStatus(AnimationStatus status) {
    if (status == AnimationStatus.reverse) {
      if (!_popAnimating) {
        setState(() {
          _popAnimating = true;
        });
      }
    } else {
      if (_popAnimating) {
        setState(() {
          _popAnimating = false;
        });
      }
    }
  }

  void _handleSlideChange(double value) {
    final status = widget.route.animation!.status;
    if (_beenDismissed && value == 1.0 && (status == AnimationStatus.completed || status == AnimationStatus.forward)) {
      // TODO: milliseconds: 1 is a workaround for the https://github.com/flutter/flutter/issues/78750 . remove it when it's resolved
      _routeAnimationController.reverseDuration = const Duration(milliseconds: 1);
      Navigator.of(context).pop();
    }

    if (value != 0.0 && _boxDecorationController.status != AnimationStatus.forward) {
      _boxDecorationController.forward();
    } else if (value == 0.0) {
      _boxDecorationController.reset();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SlidableControllerProvider<DismissibleRoute>(
      controller: _controller,
      child: Slidable(
        controller: _controller,
        direction: _popAnimating ? SlideDirection.none : widget.dismissDirection,
        start: 0.0,
        end: 1.0,
        barrierIgnoringStrategy: const IgnoringStrategy(dismissed: true, reverse: true),
        catchIgnoringStrategy: const MovingIgnoringStrategy(forward: true, reverse: true),
        barrier: _showBarrier ? widget.dismissBarrier : null,
        barrierBuilder: (animation, child) {
          return FadeTransition(opacity: animation.drive(Tween(begin: 1.0, end: 0.0)), child: child);
        },
        onSlideChange: _handleSlideChange,
        onDragUpdate: (details) {
          setState(() {
            _dragged = true;
          });
        },
        onDragEnd: (_, res) {
          setState(() {
            _beenDismissed = res;
            _dragged = false;
          });
        },
        child: AnimatedBuilder(
          animation: _boxDecorationController,
          builder:
              (context, child) => Container(
                child: !_beenDismissed ? widget.animatedChild : widget.child,
                decoration: _boxDecorationAnimation.value,
              ),
        ),
      ),
    );
  }
}
