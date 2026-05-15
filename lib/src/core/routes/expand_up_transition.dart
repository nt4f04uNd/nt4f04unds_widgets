/*---------------------------------------------------------------------------------------------
*  Copyright (c) nt4f04und. All rights reserved.
*  Licensed under the BSD-style license. See LICENSE in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import 'route_transitions.dart';
import 'package:flutter/material.dart';
import 'package:nt4f04unds_widgets/nt4f04unds_widgets.dart';

/// A page that uses [ExpandUpRouteTransition].
class ExpandUpPage<T> extends Page<T> {
  const ExpandUpPage({required this.child, this.transitionSettings, super.key, super.name, super.arguments});

  final Widget child;

  final RouteTransitionSettings? transitionSettings;

  @override
  RouteTransition<T> createRoute(BuildContext context) {
    return ExpandUpRouteTransition<T>(settings: this, child: child, transitionSettings: transitionSettings);
  }
}

/// Route transition that uses [OpenUpwardsPageTransitionsBuilder] from the flutter.
class ExpandUpRouteTransition<T> extends RouteTransition<T> {
  /// Creates route transition.
  ExpandUpRouteTransition({super.settings, required this.child, super.transitionSettings});

  final Widget child;

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
    return const OpenUpwardsPageTransitionsBuilder().buildTransitions(
      this,
      context,
      CurvedAnimation(
        parent: animation,
        curve: transitionSettings.curve,
        reverseCurve: transitionSettings.reverseCurve,
      ),
      CurvedAnimation(
        parent: secondaryAnimation,
        curve: transitionSettings.secondaryCurve,
        reverseCurve: transitionSettings.secondaryReverseCurve,
      ),
      child,
    );
  }
}
