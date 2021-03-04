/*---------------------------------------------------------------------------------------------
*  Copyright (c) nt4f04und. All rights reserved.
*  Licensed under the BSD-style license. See LICENSE in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:nt4f04unds_widgets/nt4f04unds_widgets.dart';
import 'route_transitions.dart';

/// Settings for the [StackFadeRouteTransition].
class StackFadeRouteTransitionSettings extends RouteTransitionSettings {
  /// Creates transition that comes from right to left.
  StackFadeRouteTransitionSettings({
    this.entBegin = const Offset(0.16, 0.0),
    this.exitEnd = const Offset(0.2, 0.0),
    this.dismissible = false,
    this.dismissDirection = SlideDirection.right,
    this.dismissBarrier,
    Duration transitionDuration = kNFRouteTransitionDuration,
    Duration reverseTransitionDuration = kNFRouteTransitionDuration,
    RouteSettings? settings,
    bool opaque = true,
    bool maintainState = false,
    BoolCallback checkEntAnimationEnabled = defRouteTransitionBoolFunc,
    BoolCallback checkExitAnimationEnabled = defRouteTransitionBoolFunc,
    // entCurve and entReverseCurve have different defaults, compared to other transitions
    Curve entCurve = Curves.easeOutCubic,
    Curve entReverseCurve = Curves.easeInCubic,
    Curve exitCurve = Curves.linearToEaseOut,
    Curve exitReverseCurve = Curves.easeInToLinear,
    bool entIgnore = false,
    bool exitIgnore = false,
    UIFunction? checkSystemUi,
  })  : assert(!dismissible || !opaque, 'If dismissible set to true, the opaque property must be set to false'),
        super(
          transitionDuration: transitionDuration,
          reverseTransitionDuration: reverseTransitionDuration,
          settings: settings,
          opaque: opaque,
          maintainState: maintainState,
          checkEntAnimationEnabled: checkEntAnimationEnabled,
          checkExitAnimationEnabled: checkExitAnimationEnabled,
          entCurve: entCurve,
          entReverseCurve: entReverseCurve,
          exitCurve: exitCurve,
          exitReverseCurve: exitReverseCurve,
          entIgnore: entIgnore,
          exitIgnore: exitIgnore,
          checkSystemUi: checkSystemUi,
        );

  /// Creates transition that comes from bottom to top.
  StackFadeRouteTransitionSettings.fromBottom({
    this.dismissible = false,
    this.dismissDirection = SlideDirection.right,
    this.dismissBarrier,
    Duration transitionDuration = kNFRouteTransitionDuration,
    Duration reverseTransitionDuration = kNFRouteTransitionDuration,
    RouteSettings? settings,
    bool opaque = true,
    bool maintainState = false,
    BoolCallback checkEntAnimationEnabled = defRouteTransitionBoolFunc,
    BoolCallback checkExitAnimationEnabled = defRouteTransitionBoolFunc,
    // entCurve and entReverseCurve have different defaults, compared to other transitions
    Curve entCurve = Curves.easeOutCubic,
    Curve entReverseCurve = Curves.easeInCubic,
    Curve exitCurve = Curves.linearToEaseOut,
    Curve exitReverseCurve = Curves.easeInToLinear,
    bool entIgnore = false,
    bool exitIgnore = false,
    UIFunction? checkSystemUi,
  })  : assert(!dismissible || !opaque,
            'If dismissible set to true, the opaque property must be set to false'),
        entBegin = const Offset(0.0, 0.16),
        exitEnd = const Offset(0.0, 0.2),
        super(
          transitionDuration: transitionDuration,
          reverseTransitionDuration: reverseTransitionDuration,
          settings: settings,
          opaque: opaque,
          maintainState: maintainState,
          checkEntAnimationEnabled: checkEntAnimationEnabled,
          checkExitAnimationEnabled: checkExitAnimationEnabled,
          entCurve: entCurve,
          entReverseCurve: entReverseCurve,
          exitCurve: exitCurve,
          exitReverseCurve: exitReverseCurve,
          entIgnore: entIgnore,
          exitIgnore: exitIgnore,
          checkSystemUi: checkSystemUi,
        );

  /// Begin offset for the enter animation
  ///
  /// Defaults to [const Offset(0.16, 0.0)]
  Offset entBegin;

  /// End offset for the exit animation
  ///
  /// Defaults to [const Offset(0.2, 0.0)]
  Offset exitEnd;

  /// Whether the route can be dismissed with the swipe.
  ///
  /// If true, then [opaque] property will be ignored.
  /// Defaults to `false`.
  bool dismissible;

  /// The direction of the swipe to dismiss the route.
  ///
  /// Defaults to [DismissDirection.startToEnd]
  SlideDirection dismissDirection;

  /// Widget to show as barrier.
  ///
  /// By default container of [Colors.black26].
  Widget? dismissBarrier;
}

/// Creates customizable stack route transition with fade, very similar to Telegram app
class StackFadeRouteTransition<T extends Widget> extends RouteTransition<T> {
  @override
  final T route;
  @override
  final StackFadeRouteTransitionSettings transitionSettings;

  /// Whether route has been dismissed by users swipe.
  /// Needed to determine whether to show a barrier and shadow from the route.
  bool _beenDismissed = false;

  StackFadeRouteTransition({
    required this.route,
    StackFadeRouteTransitionSettings? transitionSettings,
  })  : transitionSettings =
            transitionSettings ?? StackFadeRouteTransitionSettings(),
        super(
          route: route,
          transitionSettings: transitionSettings ?? RouteTransitionSettings(),
        ) {
    transitionsBuilder = (
      BuildContext context,
      Animation<double> animation,
      Animation<double> secondaryAnimation,
      Widget child,
    ) {
      ignore = ignore && !_beenDismissed;
      secondaryIgnore = secondaryIgnore && !_beenDismissed;

      final slideAnimation = animation.status == AnimationStatus.forward
          // Move in on enter
          ? Tween<Offset>(
                  begin: this.transitionSettings.entBegin, end: Offset.zero)
              .animate(
              CurvedAnimation(
                parent: animation,
                curve: this.transitionSettings.entCurve,
              ),
            )
          // Move out on enter reverse
          : animation.status == AnimationStatus.reverse
              ? Tween(begin: this.transitionSettings.exitEnd, end: Offset.zero)
                  .animate(
                  CurvedAnimation(
                    parent: animation,
                    curve: this.transitionSettings.entCurve,
                    reverseCurve: this.transitionSettings.entReverseCurve,
                  ),
                )
              // Stand still in other cases
              : Tween(begin: Offset.zero, end: Offset.zero).animate(animation);

      final fadeAnimation = animation.status == AnimationStatus.forward
          // Fade in on enter
          ? Tween<double>(begin: 0.0, end: 1.0).animate(
              CurvedAnimation(
                  curve: Interval(
                    0.0,
                    0.7,
                    curve: Curves.ease,
                  ),
                  parent: animation),
            )
          // Fade out on exit
          : animation.status == AnimationStatus.reverse
              ? Tween<double>(begin: -0.5, end: 1.0).animate(animation)
              // Do not fade in other cases
              : constTween.animate(animation);

      final animatedChild = TurnableSlideTransition(
        enabled: entAnimationEnabled,
        position: slideAnimation,
        child: FadeTransition(
          opacity: fadeAnimation,
          child: child,
        ),
      );

      return IgnorePointer(
        // Disable any touch events on enter while in transition
        ignoring: ignore,
        child: IgnorePointer(
          // Disable any touch events on exit while in transition
          ignoring: secondaryIgnore,
          child: this.transitionSettings.dismissible
              ? _DismissibleRoute(
                  routeTransition: this,
                  animatedChild: animatedChild,
                  child: child,
                )
              : animatedChild,
        ),
      );
    };
  }
}

class _DismissibleRoute extends StatefulWidget {
  _DismissibleRoute({
    Key? key,
    required this.routeTransition,
    required this.animatedChild,
    required this.child,
  })  : assert(routeTransition != null),
        assert(animatedChild != null),
        assert(child != null),
        super(key: key);

  final StackFadeRouteTransition routeTransition;

  /// Widget wrapped into transitions which are played on route push and pop.
  final Widget animatedChild;

  /// Bare child widget.
  final Widget child;
  @override
  _DismissibleRouteState createState() => _DismissibleRouteState();
}

class _DismissibleRouteState extends State<_DismissibleRoute>
    with SingleTickerProviderStateMixin, RouteAware {
  bool _dragged = false;

  /// Needed to make sure I call Navigator pop only once.
  bool _beenPopped = false;

  /// Should barrier be visible.
  bool get _showBarrier =>
      widget.routeTransition.animation!.isCompleted ||
      // Do not show when route went out out of the screen after dismissal
      widget.routeTransition._beenDismissed &&
          !widget.routeTransition.animation!.isDismissed ||
      _dragged &&
          widget.routeTransition.animation!.status == AnimationStatus.forward;

  /// Controller to manipulate the route shadow.
  late AnimationController _controller;
  late Animation<Decoration> _boxDecorationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _boxDecorationAnimation = DecorationTween(
      begin: const BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.transparent,
          ),
        ],
      ),
      end: const BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            spreadRadius: 2.0,
            blurRadius: 2.0,
          ),
        ],
      ),
    ).animate(
      CurvedAnimation(curve: Curves.easeOutCubic, parent: _controller),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didPop() {
    _beenPopped = true;
  }

  @override
  Widget build(BuildContext context) {
    return Slidable(
      springDescription: SpringDescription.withDampingRatio(
        mass: 0.01,
        stiffness: 200.0,
        ratio: 3.0,
      ),
      direction: widget.routeTransition.transitionSettings.dismissDirection,
      start: 0.0,
      end: 1.0,
      barrierIgnoringStrategy: const IgnoringStrategy(
        dismissed: true,
        reverse: true,
      ),
      catchIgnoringStrategy: const MovingIgnoringStrategy(
        forward: true,
        reverse: true,
      ),
      barrierBuilder: (animation, child) {
        return FadeTransition(
          opacity: animation.drive(Tween(begin: 1.0, end: 0.0)), 
          child: child,
        );
      },
      barrier: _showBarrier
          ? widget.routeTransition.transitionSettings.dismissBarrier ?? Container(color: Colors.black26)
          : null,
      onDragUpdate: (_) {
        setState(() {
          _dragged = true;
        });
      },
      onDragEnd: (_, res) {
        setState(() {
          widget.routeTransition._beenDismissed = res;
          _dragged = false;
        });
      },
      onSlideChange: (value) {
        final status = widget.routeTransition.animation!.status;
        if (widget.routeTransition._beenDismissed &&
            !_beenPopped &&
            (status == AnimationStatus.completed || status == AnimationStatus.forward)
            && value == 1.0) {
          if (widget.routeTransition._beenDismissed) {
            // ignore: invalid_use_of_protected_member
            widget.routeTransition.controller!.reverseDuration = const Duration();
          }
          Navigator.of(context).pop();
        }

        if (value != 0.0 && _controller.status != AnimationStatus.forward) {
          _controller.forward();
        } else if (value == 0.0) {
          _controller.reset();
        }
      },
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) => Container(
          child: !widget.routeTransition._beenDismissed
              ? widget.animatedChild
              : widget.child,
          decoration: _boxDecorationAnimation.value,
        ),
      ),
    );
  }
}
