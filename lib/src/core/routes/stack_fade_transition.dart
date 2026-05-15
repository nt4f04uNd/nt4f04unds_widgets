/*---------------------------------------------------------------------------------------------
*  Copyright (c) nt4f04und. All rights reserved.
*  Licensed under the BSD-style license. See LICENSE in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import 'package:flutter/material.dart';
import 'package:nt4f04unds_widgets/nt4f04unds_widgets.dart';

const Duration _kStackFadeTransitionDuration = Duration(milliseconds: 240);

/// Settings for the [StackFadeRouteTransition].
class StackFadeRouteTransitionSettings extends RouteTransitionSettings {
  static const String _dismissibleAssertError = 'If dismissible is true, the opaque must false';

  /// Creates transition that goes from right to left.
  StackFadeRouteTransitionSettings({
    this.enterOffset = const Offset(0.16, 0.0),
    this.exitOffset = const Offset(0.2, 0.0),
    this.dismissible = false,
    this.dismissBarrier,
    this.dismissDirection = SlideDirection.right,
    super.opaque,
    super.maintainState,
    super.transitionDuration = _kStackFadeTransitionDuration,
    super.reverseTransitionDuration = _kStackFadeTransitionDuration,
    super.animationEnabled,
    super.secondaryAnimationEnabled,
    super.curve = Curves.easeOutCubic,
    super.reverseCurve = Curves.easeInCubic,
    super.secondaryCurve,
    super.secondaryReverseCurve,
    super.uiStyle,
  }) : assert(!dismissible || !opaque, _dismissibleAssertError);

  /// Creates transition that comes from bottom to top.
  StackFadeRouteTransitionSettings.fromBottom({
    this.dismissible = false,
    this.dismissBarrier,
    this.dismissDirection = SlideDirection.right,
    super.opaque,
    super.maintainState,
    super.transitionDuration = _kStackFadeTransitionDuration,
    super.reverseTransitionDuration = _kStackFadeTransitionDuration,
    super.animationEnabled,
    super.secondaryAnimationEnabled,
    super.curve = Curves.easeOutCubic,
    super.reverseCurve = Curves.easeInCubic,
    super.secondaryCurve,
    super.secondaryReverseCurve,
    super.uiStyle,
  }) : assert(!dismissible || !opaque, _dismissibleAssertError),
       enterOffset = const Offset(0.0, 0.16),
       exitOffset = const Offset(0.0, 0.2);

  /// Offset enter animation starts from.
  Offset enterOffset;

  /// Offset where exit animation ends.
  Offset exitOffset;

  /// Whether the route can be dismissed with the swipe.
  ///
  /// If true, then [opaque] must be `false`.
  bool dismissible;

  /// The widget to show as barrier when route is being dragged.
  ///
  /// If none specified, [Container] with color [Colors.black26] is used.
  Widget? dismissBarrier;

  /// The direction of the swipe to dismiss the route.
  SlideDirection dismissDirection;
}

/// A page that uses [StackFadeRouteTransition].
class StackFadePage<T> extends Page<T> {
  const StackFadePage({required this.child, this.transitionSettings, super.key, super.name, super.arguments});

  final Widget child;

  final StackFadeRouteTransitionSettings? transitionSettings;

  @override
  RouteTransition<T> createRoute(BuildContext context) {
    return StackFadeRouteTransition<T>(settings: this, child: child, transitionSettings: transitionSettings);
  }
}

/// Creates stack fade route transition, similar to Telegram app.
class StackFadeRouteTransition<T> extends RouteTransition<T> {
  /// Creates route transition.
  StackFadeRouteTransition({
    super.settings,
    required this.child,
    StackFadeRouteTransitionSettings? super.transitionSettings,
  }) : _transitionSettings = transitionSettings ?? StackFadeRouteTransitionSettings();

  final Widget child;
  final StackFadeRouteTransitionSettings _transitionSettings;

  @override
  StackFadeRouteTransitionSettings get transitionSettings => _transitionSettings;

  @override
  Widget buildContent(BuildContext context) {
    return child;
  }

  @override
  Widget buildAnimation(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    Animation<Offset>? slideAnimation;
    Animation<double>? fadeAnimation;
    final AnimationStatus status = animation.status;

    if (status == AnimationStatus.forward || status == AnimationStatus.reverse) {
      final bool forward = status == AnimationStatus.forward;

      slideAnimation = Tween<Offset>(
        begin: forward ? transitionSettings.enterOffset : transitionSettings.exitOffset,
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: animation,
          curve: transitionSettings.curve,
          reverseCurve: transitionSettings.reverseCurve,
        ),
      );

      if (forward) {
        fadeAnimation = Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(CurvedAnimation(curve: Interval(0.0, 0.7, curve: Curves.ease), parent: animation));
      } else {
        fadeAnimation = Tween<double>(begin: -0.5, end: 1.0).animate(animation);
      }
    }

    Widget animatedChild = child;
    if (fadeAnimation != null) {
      animatedChild = FadeTransition(opacity: fadeAnimation, child: animatedChild);
    }
    if (slideAnimation != null) {
      animatedChild = SlideTransition(position: slideAnimation, child: animatedChild);
    }

    return transitionSettings.dismissible
        ? DismissibleRoute(
          route: this,
          animatedChild: animatedChild,
          dismissBarrier: transitionSettings.dismissBarrier,
          dismissDirection: transitionSettings.dismissDirection,
          child: child,
        )
        : animatedChild;
  }
}
