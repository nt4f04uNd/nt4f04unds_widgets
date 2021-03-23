/*---------------------------------------------------------------------------------------------
*  Copyright (c) nt4f04und. All rights reserved.
*  Licensed under the BSD-style license. See LICENSE in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import 'route_transitions.dart';
import 'package:flutter/material.dart';


/// A page that uses [ZoomRouteTransition].
class ZoomPage<T> extends Page<T> {
   const ZoomPage({
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
    return ZoomRouteTransition<T>(
      settings: this,
      child: child,
      transitionSettings: transitionSettings,
    );
  }
}

/// Route transition that uses [ZoomPageTransitionsBuilder] from the flutter.
class ZoomRouteTransition<T> extends RouteTransition<T> {
  /// Creates route transition.
  ZoomRouteTransition({
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
    return const ZoomPageTransitionsBuilder().buildTransitions(this, context, CurvedAnimation(
      parent: animation,
      curve: transitionSettings.curve,
      reverseCurve: transitionSettings.reverseCurve,
    ), CurvedAnimation(
      parent: secondaryAnimation,
      curve: transitionSettings.secondaryCurve,
      reverseCurve: transitionSettings.secondaryReverseCurve,
    ), child);
  }
}
