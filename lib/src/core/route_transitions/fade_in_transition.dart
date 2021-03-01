/*---------------------------------------------------------------------------------------------
*  Copyright (c) nt4f04und. All rights reserved.
*  Licensed under the BSD-style license. See LICENSE in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import 'route_transitions.dart';
import 'package:flutter/material.dart';
import 'package:nt4f04unds_widgets/nt4f04unds_widgets.dart';

/// Settings for the [FadeInRouteTransition].
class FadeInRouteTransitionSettings extends RouteTransitionSettings {
  FadeInRouteTransitionSettings({
    this.entBegin = const Offset(1.0, 0.0),
    this.entEnd = Offset.zero,
    this.exitBegin = Offset.zero,
    this.exitEnd = const Offset(-0.2, 0.0),
    Duration transitionDuration = kNFRouteTransitionDuration,
    Duration reverseTransitionDuration = kNFRouteTransitionDuration,
    RouteSettings settings,
    bool opaque = true,
    bool maintainState = false,
    BoolCallback checkEntAnimationEnabled = defRouteTransitionBoolFunc,
    BoolCallback checkExitAnimationEnabled = defRouteTransitionBoolFunc,
    Curve entCurve = Curves.linearToEaseOut,
    Curve entReverseCurve = Curves.easeInToLinear,
    Curve exitCurve = Curves.linearToEaseOut,
    Curve exitReverseCurve = Curves.easeInToLinear,
    bool entIgnore = false,
    bool exitIgnore = false,
    UIFunction checkSystemUi,
  }) : super(
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

  /// Begin offset for enter animation
  ///
  /// Defaults to [const Offset(1.0, 0.0)]
  Offset entBegin;

  /// End offset for enter animation
  ///
  /// Defaults to [Offset.zero]
  Offset entEnd;

  /// Begin offset for exit animation
  ///
  /// Defaults to [Offset.zero]
  Offset exitBegin;

  /// End offset for exit animation
  ///
  /// Defaults to [const Offset(-0.2, 0.0)]
  Offset exitEnd;
}

/// Creates customizable fade in transition
///
/// By default acts pretty same as [FadeUpwardsPageTransitionsBuilder] - creates upwards fade in transition
class FadeInRouteTransition<T extends Widget> extends RouteTransition<T> {
  @override
  final T route;
  @override
  final FadeInRouteTransitionSettings transitionSettings;

  FadeInRouteTransition({
    @required this.route,
    FadeInRouteTransitionSettings transitionSettings,
  })  : transitionSettings =
            transitionSettings ?? FadeInRouteTransitionSettings(),
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
      /// Wrap child for to use with material routes (difference from default child is that is has animation status completed check, that brakes theme ui switch)
      final Container materialWrappedChild = Container(
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
      );

      return TurnableSlideTransition(
        enabled: entAnimationEnabled,
        position: Tween(
          begin: this.transitionSettings.entBegin,
          end: this.transitionSettings.entEnd,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: this.transitionSettings.entCurve,
          reverseCurve: this.transitionSettings.entReverseCurve,
        )),
        child: FadeTransition(
          opacity: CurvedAnimation(
            parent: animation,
            curve: Curves.easeIn,
            reverseCurve: this.transitionSettings.entReverseCurve,
          ),
          child: TurnableSlideTransition(
            enabled: exitAnimationEnabled,
            position: Tween(
              begin: this.transitionSettings.exitBegin,
              end: this.transitionSettings.exitEnd,
            ).animate(
              CurvedAnimation(
                parent: secondaryAnimation,
                curve: this.transitionSettings.exitCurve,
                reverseCurve: this.transitionSettings.exitReverseCurve,
              ),
            ),
            child: materialWrappedChild,
          ),
        ),
      );
    };
  }
}
