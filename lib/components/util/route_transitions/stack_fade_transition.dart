/*---------------------------------------------------------------------------------------------
*  Copyright (c) nt4f04und. All rights reserved.
*  Licensed under the BSD-style license. See LICENSE in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import 'package:flutter/material.dart';
import 'package:nt4f04unds_widgets/nt4f04unds_widgets.dart';
import 'route_transitions.dart';

/// Creates customizable stack route transition with fade, very similar to Telegram app
class StackFadeRouteTransition<T extends Widget, RouteT extends dynamic>
    extends RouteTransition<T, RouteT> {
  @override
  final T route;
  @override
  final RouteT routeType;
  @override
  BoolFunction checkEntAnimationEnabled;
  @override
  final Curve entCurve;
  @override
  final Curve entReverseCurve;
  @override
  final bool entIgnoreEventsForward;
  @override
  final bool exitIgnoreEventsForward;
  @override
  final bool exitIgnoreEventsReverse;
  @override
  UIFunction checkSystemUi;

  /// Begin offset for the enter animation
  ///
  /// Defaults to [const Offset(0.16, 0.0)]
  final Offset entBegin;

  /// End offset for the exit animation
  ///
  /// Defaults to [const Offset(0.2, 0.0)]
  final Offset exitEnd;

  /// Whether the route can be dismissed with the swipe.
  ///
  /// If true, then [opaque] property will be ignored.
  /// Defaults to `false`.
  final bool dismissible;

  /// The direction of the swipe to dismiss the route.
  ///
  /// Defaults to [DismissDirection.startToEnd]
  final SlideDirection dismissDirection;

  Widget dismissBarrier;

  factory StackFadeRouteTransition.fromBottom({
    @required T route,
    RouteT routeType,
  }) {
    return StackFadeRouteTransition(
      route: route,
      entBegin: const Offset(0.0, 0.16),
      exitEnd: const Offset(0.0, 0.2),
    );
  }

  /// Whether route has been dismissed by users swipe.
  /// Needed to determine whether to show a barrier and shadow from the route.
  bool _beenDismissed = false;

  StackFadeRouteTransition({
    @required this.route,
    this.routeType,
    this.checkEntAnimationEnabled = defBoolFunc,
    this.entCurve = Curves.easeOutCubic,
    this.entReverseCurve = Curves.easeInCubic,
    this.entIgnoreEventsForward = false,
    this.exitIgnoreEventsForward = false,
    this.exitIgnoreEventsReverse = false,
    this.checkSystemUi,
    this.entBegin = const Offset(0.16, 0.0),
    this.exitEnd = const Offset(0.2, 0.0),
    this.dismissible = false,
    this.dismissDirection = SlideDirection.startToEnd,
    Duration transitionDuration = kNFRouteTransitionDuration,
    RouteSettings settings,
    bool opaque = true,
    bool maintainState = false,
  }) : super(
          route: route,
          transitionDuration: transitionDuration,
          settings: settings,
          opaque: opaque && !dismissible,
          maintainState: maintainState,
        ) {
    transitionsBuilder = (
      BuildContext context,
      Animation<double> animation,
      Animation<double> secondaryAnimation,
      Widget child,
    ) {
      // TODO: this
      // dismissBarrier ??= ignore = ignore && !_beenDismissed;
      ignore = ignore && !_beenDismissed;
      secondaryIgnore = secondaryIgnore && !_beenDismissed;

      final slideAnimation = animation.status == AnimationStatus.forward
          // Move in on enter
          ? Tween<Offset>(begin: entBegin, end: Offset.zero).animate(
              CurvedAnimation(
                parent: animation,
                curve: entCurve,
              ),
            )
          // Move out on enter reverse
          : animation.status == AnimationStatus.reverse
              ? Tween(begin: exitEnd, end: Offset.zero).animate(
                  CurvedAnimation(
                    parent: animation,
                    curve: entCurve,
                    reverseCurve: entReverseCurve,
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
          child: dismissible
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
    Key key,
    @required this.routeTransition,
    @required this.animatedChild,
    @required this.child,
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
    with SingleTickerProviderStateMixin {
  bool _dragged = false;

  /// Needed to make sure I call Navigator pop only once.
  bool _beenPopped = false;

  /// Should barrier be visible.
  bool get _showBarrier =>
      widget.routeTransition.animation.isCompleted ||
      widget.routeTransition._beenDismissed &&
          !widget.routeTransition.animation.isDismissed ||
      _dragged &&
          widget.routeTransition.animation.status == AnimationStatus.forward;

  /// Controller to manipulate the route shadow.
  AnimationController _controller;
  Animation<Decoration> _boxDecorationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _boxDecorationAnimation = DecorationTween(
      begin: const BoxDecoration(),
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
  Widget build(BuildContext context) {
    return RouteAwareWidget(
      onPop: () {
        _beenPopped = true;
      },
      child: Stack(
        children: [
          Slidable(
            key: ValueKey(widget.routeTransition.routeType),
            startOffset: Offset.zero,
            endOffset: const Offset(1.0, 0.0),
            canReverseForward: false,
            canReverseReverse: false,
            direction: widget.routeTransition.dismissDirection,
            invertBarrierProgress: true,
            barrier: _showBarrier
                ? widget.routeTransition.dismissBarrier
                // Container(
                //     color:
                //         ThemeControl.isDark ? Colors.black54 : Colors.black26,
                //   )
                : null,
            onDragUpdate: (_, __) {
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
              if (widget.routeTransition._beenDismissed &&
                  !_beenPopped &&
                  (widget.routeTransition.animation.status ==
                          AnimationStatus.completed ||
                      widget.routeTransition.animation.status ==
                          AnimationStatus.forward)) {
                Navigator.of(context).pop();
              }

              if (value != 0.0 &&
                  _controller.status != AnimationStatus.forward) {
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
                // curve: Curves.easeOut,
                decoration: _boxDecorationAnimation.value,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
