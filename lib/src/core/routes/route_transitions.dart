/*---------------------------------------------------------------------------------------------
*  Copyright (c) nt4f04und. All rights reserved.
*  Licensed under the BSD-style license. See LICENSE in the project root for license information.
*--------------------------------------------------------------------------------------------*/

export 'expand_up_transition.dart';
export 'fade_in_transition.dart';
export 'stack_fade_transition.dart';
export 'zoom_transition.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nt4f04unds_widgets/nt4f04unds_widgets.dart';

/// Default route transition duration.
const Duration kRouteTransitionDuration = const Duration(milliseconds: 300);

/// Configures the look of the route transition.
///
/// This class is immutable because router v2 is now in place, which allow to manager
/// routes declaratevly.
///
/// Properties are not final to be able to update settings without recreateing the route.
///
/// todo: add seprarate settings with parameters for sustem ui, or come up with a way of wiring it up into router v2, or something else
class RouteTransitionSettings {
  RouteTransitionSettings({
    this.opaque = true,
    this.maintainState = true,
    this.transitionDuration = kRouteTransitionDuration,
    this.reverseTransitionDuration = kRouteTransitionDuration,
    this.animationEnabled = true,
    this.secondaryAnimationEnabled = true,
    this.curve = Curves.linearToEaseOut,
    this.reverseCurve = Curves.easeInToLinear,
    this.secondaryCurve = Curves.linearToEaseOut,
    this.secondaryReverseCurve = Curves.easeInToLinear,
    this.uiStyle,
  });

  /// Whether the route obscures previous routes when the transition is complete.
  ///
  /// When an opaque route's entrance transition is complete, the routes behind
  /// the opaque route will not be built to save resources.
  bool opaque;

  /// Whether the route should remain in memory when it is inactive.
  ///
  /// If this is true, then the route is maintained, so that any futures it is
  /// holding from the next route will properly resolve when the next route
  /// pops. If this is not necessary, this can be set to false to allow the
  /// framework to entirely discard the route's widget hierarchy when it is not
  /// visible.
  bool maintainState;

  /// The duration the transition going forwards.
  Duration transitionDuration;

  /// The duration the transition going in reverse.
  Duration reverseTransitionDuration;

  /// Whether animation is enabled.
  bool animationEnabled;

  /// Whether secondary animation is enabled.
  bool secondaryAnimationEnabled;

  /// A curve used for the animation.
  Curve curve;

  /// A curve used for reverse animation.
  Curve reverseCurve;

  /// A curve used for secondary animation.
  Curve secondaryCurve;

  /// A curve for reverse secondary animation.
  Curve secondaryReverseCurve;

  /// Function to get system UI to be set when navigating to route.
  ///
  /// If none specified, UI will not be changed on animation.
  ///
  /// However if [NFThemeData.alwaysApplyUiStyle] is `true`, it will animate even if it's `null`,
  /// but [NFThemeData.systemUiStyle] will be used as a fallback.
  ///
  /// The is UI animated only when:
  /// * new screen is opening - bound to animation
  /// * screen goes away and old one is revealed - bound to secondary animation
  SystemUiOverlayStyle? uiStyle;
}

/// A handy class to create various route transitions.
class RouteTransitionBuilder<T> extends RouteTransition<T> {
  RouteTransitionBuilder({
    required this.builder,
    required this.animationBuilder,
    RouteSettings? settings,
    RouteTransitionSettings? transitionSettings,
    this.barrierDismissible = false,
    this.barrierColor,
    this.barrierLabel,
  }) : super(settings: settings, transitionSettings: transitionSettings);

  @override
  final bool barrierDismissible;

  @override
  final Color? barrierColor;

  @override
  final String? barrierLabel;

  /// Builds the primary contents of the route.
  final WidgetBuilder builder;

  /// Builds route animation.
  final RouteTransitionsBuilder animationBuilder;

  @override
  Widget buildContent(BuildContext context) {
    return builder(context);
  }

  @override
  Widget buildAnimation(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return animationBuilder(context, animation, secondaryAnimation, child);
  }
}

/// Represents a route transition with various [transitionSettings] to its parameters.
abstract class RouteTransition<T> extends PageRoute<T> {
  RouteTransition({RouteSettings? settings, RouteTransitionSettings? transitionSettings})
    : transitionSettings = transitionSettings ?? RouteTransitionSettings(),
      super(settings: settings);

  /// Settings that define how the transition will look like
  final RouteTransitionSettings transitionSettings;

  @override
  bool get opaque => transitionSettings.opaque;

  @override
  final bool barrierDismissible = false;

  @override
  final Color? barrierColor = null;

  @override
  final String? barrierLabel = null;

  @override
  Duration get transitionDuration => transitionSettings.transitionDuration;

  @override
  Duration get reverseTransitionDuration => transitionSettings.reverseTransitionDuration;

  @override
  bool get maintainState => transitionSettings.maintainState;

  /// Variable to disable the animation switch call if ui is already animating.
  /// Needed to correctly switch when popping the route, because secondaryAnimation status listener is called multiple times.
  bool uiAnimating = false;

  SystemUiOverlayStyle? _getUi(context) {
    final nftheme = NFTheme.of(context);
    return nftheme.alwaysApplyUiStyle
        ? transitionSettings.uiStyle ?? nftheme.systemUiStyle
        : transitionSettings.uiStyle;
  }

  /// Builds route contents.
  @protected
  Widget buildContent(BuildContext context);

  /// Builds route animation.
  ///
  /// Called within [buildTransitions]. Introduced because [buildTransitions] contains addtional logic for handling
  /// [RouteTransitionSettings.animationEnabled] and [RouteTransitionSettings.secondaryAnimationEnabled].
  @protected
  Widget buildAnimation(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  );

  @override
  Widget buildPage(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
    handleSystemUi(context, animation, secondaryAnimation);
    return RouteAwareWidget(
      onPopNext: () async {
        if (!uiAnimating) {
          final ui = _getUi(context);
          if (ui == null) return;
          uiAnimating = true;
          await SystemUiStyleController.instance.animateSystemUiOverlay(
            to: ui,
            curve: transitionSettings.reverseCurve,
            duration: transitionDuration,
          );
          uiAnimating = false;
        }
      },
      child: buildContent(context),
    );
  }

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    if (!transitionSettings.animationEnabled) {
      animation = kAlwaysCompleteAnimation;
    }
    if (!transitionSettings.secondaryAnimationEnabled) {
      secondaryAnimation = kAlwaysDismissedAnimation;
    }
    return buildAnimation(context, animation, secondaryAnimation, child);
  }

  /// Animates UI when:
  /// * new screen is opening
  /// * screen goes away and old one is revealed
  ///
  /// Called within [buildPage].
  @protected
  void handleSystemUi(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
    Future<void> animate() async {
      if (!uiAnimating && animation.status == AnimationStatus.forward) {
        final ui = _getUi(context);
        if (ui == null) return;
        uiAnimating = true;
        await SystemUiStyleController.instance.animateSystemUiOverlay(
          to: ui,
          curve: transitionSettings.curve,
          // multiplying by 2 here, because animation looks too fast without it
          duration: transitionDuration * 2,
        );
        uiAnimating = false;
      }
    }

    animate();
    animation.addStatusListener((status) {
      animate();
    });

    //* the code below was meant to interpolate UI style values based on animation values, but it didn't work for some reason

    // final nftheme = NFTheme.of(context);
    // SystemUiOverlayStyle? getUi() {
    //   return nftheme.alwaysApplyUiStyle
    //       ? transitionSettings.uiStyle ?? nftheme.systemUiStyle
    //       : transitionSettings.uiStyle;
    // }
    // Animation<SystemUiOverlayStyle> getUiAnimation(SystemUiOverlayStyle ui, Animation<double> _animation) {
    //   return SystemUiOverlayStyleTween(
    //     begin: SystemUiStyleController.instance.actualUi,
    //     end: ui,
    //   ).animate(CurvedAnimation(
    //     curve: transitionSettings.curve,
    //     reverseCurve: transitionSettings.secondaryReverseCurve,
    //     parent: _animation,
    //   ));
    // }
    // animation.addStatusListener((status) {
    //   if (onTop && status == AnimationStatus.completed) {
    //     final ui = getUi();
    //     if (ui != null) {
    //       SystemUiStyleController.instance.setSystemUiOverlay(ui);
    //     }
    //   }
    // });
    // secondaryAnimation.addStatusListener((status) {
    //   if (status == AnimationStatus.dismissed) {
    //     final ui = getUi();
    //     if (ui != null) {
    //       SystemUiStyleController.instance.setSystemUiOverlay(SystemUiStyleController.instance.actualUi!);
    //     }
    //   }
    // });
    // animation.addListener(() {
    //   if (!onTop || animation.status != AnimationStatus.forward)
    //     return;
    //   final ui = getUi();
    //   if (ui != null) {
    //     SystemUiStyleController.instance.setSystemUiOverlay(getUiAnimation(ui, animation).value);
    //   }
    // });
    // secondaryAnimation.addListener(() {
    //   if (!onTop || secondaryAnimation.status != AnimationStatus.reverse)
    //     return;
    //   final ui = getUi();
    //   if (ui != null) {
    //     SystemUiStyleController.instance.setSystemUiOverlay(getUiAnimation(ui, secondaryAnimation).value);
    //   }
    // });
  }
}

/// Reacts with callbacks depent of the current route state in the [Navigator].
class RouteAwareWidget extends StatefulWidget {
  RouteAwareWidget({
    required this.child,
    this.routeObservers,
    this.onPush,
    this.onPop,
    this.onPushNext,
    this.onPopNext,
    this.logging = false,
  });

  final Widget child;
  final List<RouteObserver>? routeObservers;
  final Function? onPush;
  final Function? onPop;
  final Function? onPushNext;
  final Function? onPopNext;

  /// Enables logging of push and pop events.
  final bool logging;

  State<RouteAwareWidget> createState() => RouteAwareWidgetState();
}

class RouteAwareWidgetState extends State<RouteAwareWidget> with RouteAware {
  List<RouteObserver>? _routeObservers;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _routeObservers = widget.routeObservers ?? NFWidgets.routeObservers;
    for (final observer in _routeObservers!) {
      observer.subscribe(this, ModalRoute.of(context)!);
    }
  }

  @override
  void dispose() {
    for (final observer in _routeObservers!) {
      observer.unsubscribe(this);
    }
    super.dispose();
  }

  @override
  void didPush() {
    if (widget.logging) print('DID_PUSH');
    if (widget.onPush != null) widget.onPush!();
    // Current route was pushed onto navigator and is now topmost route.
  }

  @override
  void didPop() {
    if (widget.logging) print('DID_POP');
    if (widget.onPop != null) widget.onPop!();
    // Current route was pushed off the navigator.
  }

  @override
  void didPushNext() {
    if (widget.logging) print('DID_PUSH_NEXT');
    if (widget.onPushNext != null) widget.onPushNext!();
    // Covering route was pushed into the navigator.
  }

  @override
  void didPopNext() {
    if (widget.logging) print('DID_POP_NEXT');
    if (widget.onPopNext != null) widget.onPopNext!();
    // Covering route was popped off the navigator.
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
