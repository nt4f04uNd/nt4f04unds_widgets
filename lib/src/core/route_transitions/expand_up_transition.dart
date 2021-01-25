/*---------------------------------------------------------------------------------------------
*  Copyright (c) nt4f04und. All rights reserved.
*  Licensed under the BSD-style license. See LICENSE in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import 'route_transitions.dart';
import 'package:flutter/material.dart';

// Used by all of the transition animations.
const Curve _transitionCurve = Cubic(0.20, 0.00, 0.00, 1.00);

// The new page slides upwards just a little as its clip
// rectangle exposes the page from bottom to top.
final Tween<Offset> _primaryTranslationTween = Tween<Offset>(
  begin: const Offset(0.0, 0.05),
  end: Offset.zero,
);

// The old page slides upwards a little as the new page appears.
final Tween<Offset> _secondaryTranslationTween = Tween<Offset>(
  begin: Offset.zero,
  end: const Offset(0.0, -0.025),
);

/// Settings for the [ExpandUpRouteTransition].
class ExpandUpRouteTransitionSettings extends RouteTransitionSettings {
  ExpandUpRouteTransitionSettings({
    this.exitBegin = Offset.zero,
    this.exitEnd = const Offset(-0.2, 0.0),
    this.playMaterialExit = false,
    Duration transitionDuration = kNFRouteTransitionDuration,
    Duration reverseTransitionDuration = kNFRouteTransitionDuration,
    RouteSettings settings,
    bool opaque = true,
    bool maintainState = false,
    BoolFunction checkEntAnimationEnabled = defRouteTransitionBoolFunc,
    BoolFunction checkExitAnimationEnabled = defRouteTransitionBoolFunc,
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

  /// Begin offset for exit animation
  ///
  /// Defaults to [Offset.zero]
  Offset exitBegin;

  /// End offset for exit animation
  ///
  /// Defaults to [const Offset(-0.2, 0.0)]
  Offset exitEnd;

  /// If true, default material exit animation will be played.
  bool playMaterialExit;
}

/// Creates customizable expand up route transition
///
/// By default acts pretty same as [OpenUpwardsPageTransitionsBuilder] - creates upwards expand in transition
class ExpandUpRouteTransition<T extends Widget> extends RouteTransition<T> {
  @override
  final T route;
  @override
  ExpandUpRouteTransitionSettings transitionSettings;

  ExpandUpRouteTransition({
    @required this.route,
    ExpandUpRouteTransitionSettings transitionSettings,
  })  : this.transitionSettings =
            transitionSettings ?? ExpandUpRouteTransitionSettings(),
        super(
            route: route,
            transitionSettings:
                transitionSettings ?? ExpandUpRouteTransitionSettings()) {
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

      return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final Size size = constraints.biggest;

          final CurvedAnimation primaryAnimation = CurvedAnimation(
            parent: animation,
            curve: _transitionCurve,
            reverseCurve: _transitionCurve.flipped,
          );

          // Gradually expose the new page from bottom to top.
          final Animation<double> clipAnimation = Tween<double>(
            begin: 0.0,
            end: size.height,
          ).animate(primaryAnimation);

          final Animation<Offset> primaryTranslationAnimation =
              _primaryTranslationTween.animate(primaryAnimation);

          final Animation<Offset> secondaryTranslationAnimation =
              _secondaryTranslationTween.animate(
            CurvedAnimation(
              parent: secondaryAnimation,
              curve: _transitionCurve,
              reverseCurve: _transitionCurve.flipped,
            ),
          );

          return AnimatedBuilder(
            animation: animation,
            builder: (BuildContext context, Widget child) {
              return Container(
                alignment: Alignment.bottomLeft,
                child: ClipRect(
                  child: SizedBox(
                    height: clipAnimation.value,
                    child: OverflowBox(
                      alignment: Alignment.bottomLeft,
                      maxHeight: size.height,
                      child: child,
                    ),
                  ),
                ),
              );
            },
            child: this.transitionSettings.playMaterialExit
                ? AnimatedBuilder(
                    animation: secondaryAnimation,
                    child: FractionalTranslation(
                      translation: primaryTranslationAnimation.value,
                      child: child,
                    ),
                    builder: (BuildContext context, Widget child) {
                      return FractionalTranslation(
                        translation: secondaryTranslationAnimation.value,
                        child: materialWrappedChild,
                      );
                    },
                  )
                : TurnableSlideTransition(
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
          );
        },
      );
    };
  }
}
