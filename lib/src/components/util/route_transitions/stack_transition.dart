/*---------------------------------------------------------------------------------------------
*  Copyright (c) nt4f04und. All rights reserved.
*  Licensed under the BSD-style license. See LICENSE in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import 'package:flutter/material.dart';
import 'route_transitions.dart';

/// Creates customizable stack route transition (basically, one route slides over another)
///
/// Slides from right to left by default
class StackRouteTransition<T extends Widget> extends RouteTransition<T> {
  @override
  final T route;
  @override
  BoolFunction checkEntAnimationEnabled;
  @override
  BoolFunction checkExitAnimationEnabled;
  @override
  final Curve entCurve;
  @override
  final Curve entReverseCurve;
  @override
  final Curve exitCurve;
  @override
  final Curve exitReverseCurve;
  @override
  final bool entIgnore;
  @override
  final bool exitIgnore;
  @override
  UIFunction checkSystemUi;

  /// Begin offset for enter animation
  ///
  /// Defaults to [const Offset(1.0, 0.0)]
  final Offset entBegin;

  /// End offset for enter animation
  ///
  /// Defaults to [Offset.zero]
  final Offset entEnd;

  /// Begin offset for exit animation
  ///
  /// Defaults to [Offset.zero]
  final Offset exitBegin;

  /// End offset for exit animation
  ///
  /// Defaults to [const Offset(-0.3, 0.0)]
  final Offset exitEnd;

  StackRouteTransition({
    @required this.route,
    this.checkEntAnimationEnabled = defRouteTransitionBoolFunc,
    this.checkExitAnimationEnabled = defRouteTransitionBoolFunc,
    this.entCurve = Curves.linearToEaseOut,
    this.entReverseCurve = Curves.easeInToLinear,
    this.exitCurve = Curves.linearToEaseOut,
    this.exitReverseCurve = Curves.easeInToLinear,
    this.entIgnore = false,
    this.exitIgnore = false,
    this.checkSystemUi,
    this.entBegin = const Offset(1.0, 0.0),
    this.entEnd = Offset.zero,
    this.exitBegin = Offset.zero,
    this.exitEnd = const Offset(-0.2, 0.0),
    Duration transitionDuration = kNFRouteTransitionDuration,
    Duration reverseTransitionDuration = kNFRouteTransitionDuration,
    RouteSettings settings,
    bool opaque = true,
    bool maintainState = false,
  }) : super(
          route: route,
          transitionDuration: transitionDuration,
          reverseTransitionDuration: reverseTransitionDuration,
          settings: settings,
          opaque: opaque,
          maintainState: maintainState,
        ) {
    transitionsBuilder = (
      BuildContext context,
      Animation<double> animation,
      Animation<double> secondaryAnimation,
      Widget child,
    ) {
      return TurnableSlideTransition(
        enabled: entAnimationEnabled,
        position: Tween(begin: entBegin, end: entEnd).animate(CurvedAnimation(
            parent: animation, curve: entCurve, reverseCurve: entReverseCurve)),
        child: TurnableSlideTransition(
          enabled: exitAnimationEnabled,
          position: Tween(begin: exitBegin, end: exitEnd).animate(
              CurvedAnimation(
                  parent: secondaryAnimation,
                  curve: exitCurve,
                  reverseCurve: exitReverseCurve)),
          child: Container(
            color: Colors.black,
            child: FadeTransition(
              opacity: secondaryAnimation.status == AnimationStatus.forward
                  // Dim route on exit
                  ? exitDimTween.animate(
                      secondaryAnimation,
                    )
                  // Dim route on exit reverse, but less a little bit than on forward
                  : secondaryAnimation.status == AnimationStatus.reverse
                      ? exitRevDimTween.animate(
                          secondaryAnimation,
                        )
                      // Do not dim in other cases
                      : constTween.animate(secondaryAnimation),
              child: IgnorePointer(
                // Disable any touch events on enter while in transition
                ignoring: ignore,
                child: IgnorePointer(
                  // Disable any touch events on exit while in transition
                  ignoring: secondaryIgnore,
                  child: child,
                ),
              ),
            ),
          ),
        ),
      );
    };
  }
}
