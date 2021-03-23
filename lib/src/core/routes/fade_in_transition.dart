/*---------------------------------------------------------------------------------------------
*  Copyright (c) nt4f04und. All rights reserved.
*  Licensed under the BSD-style license. See LICENSE in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import 'route_transitions.dart';
import 'package:flutter/material.dart';
import 'package:nt4f04unds_widgets/nt4f04unds_widgets.dart';

/// A page that uses [FadeInRouteTransition].
class FadeInPage<T> extends Page<T> {
   const FadeInPage({
    required this.child,
    this.transitionSettings,
    LocalKey? key,
    String? name,
    Object? arguments,
  }) :  super(key: key, name: name, arguments: arguments);

  final Widget child;

  final RouteTransitionSettings? transitionSettings;

  @override
  RouteTransition<T> createRoute(BuildContext context) {
    return FadeInRouteTransition<T>(
      settings: this,
      child: child,
      transitionSettings: transitionSettings,
    );
  }
}

/// Route transition that uses [FadeUpwardsPageTransitionsBuilder] from the flutter.
class FadeInRouteTransition<T> extends RouteTransition<T> {
  /// Creates route transition.
  FadeInRouteTransition({
    RouteSettings? settings,
    required this.child,
    RouteTransitionSettings? transitionSettings,
  }) : super(settings: settings, transitionSettings: transitionSettings);

  final Widget child;

  @override
  Widget buildContent(BuildContext context) {
    return child;
  }

  @override
  Widget buildAnimation(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
    return const FadeUpwardsPageTransitionsBuilder().buildTransitions(this, context, CurvedAnimation(
      parent: animation,
      curve: transitionSettings.curve,
      reverseCurve: transitionSettings.reverseCurve,
    ), secondaryAnimation, child);
  }
}
