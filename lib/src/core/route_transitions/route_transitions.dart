/*---------------------------------------------------------------------------------------------
*  Copyright (c) nt4f04und. All rights reserved.
*  Licensed under the BSD-style license. See LICENSE in the project root for license information.
*
*  Copyright (c) The Flutter Authors.
*  See ThirdPartyNotices.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

export 'expand_up_transition.dart';
export 'fade_in_transition.dart';
export 'stack_fade_transition.dart';
export 'stack_transition.dart';
export 'zoom_transition.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:nt4f04unds_widgets/nt4f04unds_widgets.dart';

// todo: [NR] add transitionDuration parameter for the ui animation (and for secondary animation too)
// and allow ui animation customization on whole
// todo: rewrite either allow both, instead of animating the ui with `animateSystemUiOverlay`, bind it to the route animations instead

const Duration kNFRouteTransitionDuration = const Duration(milliseconds: 240);

/// Type for function that returns boolean
///
/// todo: to seprate file
typedef bool BoolFunction();

/// Needed to define constant [defRouteTransitionBoolFunc]
///
/// todo: to seprate file
bool trueFunc() => true;

/// Used as default bool function in [RouteTransition]
const BoolFunction defRouteTransitionBoolFunc = trueFunc;

/// Type for function that returns [SystemUiOverlayStyle]
typedef SystemUiOverlayStyle UIFunction();

// Tweens for exit dim animations

/// Tween for exit forward dim
final Tween<double> exitDimTween = Tween<double>(begin: 1.0, end: 0.7);

/// Tween for exit reverse dim
final Tween<double> exitRevDimTween = Tween<double>(begin: 1.0, end: 0.93);

/// Tween that always evaluates to one
final Tween<double> constTween = Tween<double>(begin: 1.0, end: 1.0);

/// Configures the look of the route transition.
class RouteTransitionSettings {
  RouteTransitionSettings({
    this.transitionDuration = kNFRouteTransitionDuration,
    this.reverseTransitionDuration = kNFRouteTransitionDuration,
    this.settings,
    this.opaque = true,
    this.maintainState = false,
    this.checkEntAnimationEnabled = defRouteTransitionBoolFunc,
    this.checkExitAnimationEnabled = defRouteTransitionBoolFunc,
    this.entCurve = Curves.linearToEaseOut,
    this.entReverseCurve = Curves.easeInToLinear,
    this.exitCurve = Curves.linearToEaseOut,
    this.exitReverseCurve = Curves.easeInToLinear,
    this.entIgnore = false,
    this.exitIgnore = false,
    this.checkSystemUi,
  });

  final Duration transitionDuration;
  final Duration reverseTransitionDuration;
  final RouteSettings settings;
  final bool opaque;
  final bool maintainState;

  /// Function that checks whether to play enter animation or not
  ///
  /// E.G disable enter animation for main route
  BoolFunction checkEntAnimationEnabled;

  /// Function that checks whether to play exit animation or not
  ///
  /// E.G disable exit animation for particular route pushes
  BoolFunction checkExitAnimationEnabled;

  /// A curve for enter animation
  ///
  /// Defaults to [Curves.linearToEaseOut]
  Curve entCurve;

  /// A curve for reverse enter animation
  ///
  /// Defaults to [Curves.easeInToLinear]
  Curve entReverseCurve;

  /// A curve for exit animation
  ///
  /// Defaults to [Curves.linearToEaseOut]
  Curve exitCurve;

  /// A curve for reverse exit animation
  ///
  /// Defaults to [Curves.easeInToLinear]
  Curve exitReverseCurve;

  /// Whether to ignore touch events while enter forward animation.
  ///
  /// The reverse one is ignored by me, becuse it doesn't register taps, only drags and this behaviour is pointless.
  ///
  /// Defaults to `false`
  bool entIgnore;

  /// Whether to ignore touch events while exit reverse animation
  ///
  /// The forward one is ignored by the framework and it's not possible to change that.
  ///
  /// Defaults to `false`
  bool exitIgnore;

  /// Function to get system Ui to be set when navigating to route.
  ///
  /// Defaults to function that returns [NFWidgets.defaultSystemUiStyle].
  UIFunction checkSystemUi;
}

class RouteTransitionSettingsProvider extends InheritedWidget {
  const RouteTransitionSettingsProvider({
    Key key,
    @required this.child,
    @required this.transitionSettings,
  })  : assert(child != null),
        assert(transitionSettings != null),
        super(key: key, child: child);

  final Widget child;
  final RouteTransitionSettings transitionSettings;

  static RouteTransitionSettingsProvider of<T>(BuildContext context) {
    return context
        .getElementForInheritedWidgetOfExactType<
            RouteTransitionSettingsProvider>()
        .widget;
  }

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) {
    return false;
  }
}

/// Abstract class to create various route transitions
abstract class RouteTransition<T extends Widget> extends PageRouteBuilder<T> {
  final T route;
  final RouteTransitionSettings transitionSettings;

  @override
  RoutePageBuilder pageBuilder;

  @override
  RouteTransitionsBuilder transitionsBuilder;

  /// Variable to disable the animation switch call if ui is already animating.
  ///
  /// Mostly needed to correctly switch when popping the route, because secondaryAnimation status listener is called multiple times.
  bool uiAnimating = false;

  /// Says when to disable [animation]
  bool entAnimationEnabled = false;

  /// Says when to disable [secondaryAnimation]
  bool exitAnimationEnabled = false;

  /// Says when to ignore widget in [animation]
  bool ignore = false;

  /// Says when to ignore widget in [secondaryAnimation]
  bool secondaryIgnore = false;

  UIFunction get _checkSystemUi =>
      transitionSettings.checkSystemUi ?? () => NFWidgets.defaultSystemUiStyle;

  RouteTransition({
    @required this.route,
    RouteTransitionSettings transitionSettings,
  })  : transitionSettings = transitionSettings ?? RouteTransitionSettings(),
        super(
            settings: transitionSettings.settings,
            opaque: transitionSettings.opaque,
            maintainState: transitionSettings.maintainState,
            transitionDuration: transitionSettings.transitionDuration,
            reverseTransitionDuration:
                transitionSettings.reverseTransitionDuration,
            pageBuilder: (
              BuildContext context,
              Animation<double> animation,
              Animation<double> secondaryAnimation,
            ) {
              return route;
            }) {
    pageBuilder = (
      BuildContext context,
      Animation<double> animation,
      Animation<double> secondaryAnimation,
    ) {
      handleChecks(animation, secondaryAnimation);
      return RouteAwareWidget(
        onPopNext: () async {
          if (!uiAnimating) {
            uiAnimating = true;
            await NFSystemUiControl.animateSystemUiOverlay(
              to: _checkSystemUi(),
              curve: transitionSettings.entReverseCurve,
              settings: NFAnimationControllerSettings(
                duration: transitionDuration,
              ),
            );
            uiAnimating = false;
          }
        },
        child: route,
      );
    };
  }

  /// Must be called in page builder.
  void handleChecks(
      Animation<double> animation, Animation<double> secondaryAnimation) {
    handleSystemUiCheck(animation, secondaryAnimation);
    handleEnabledCheck(animation, secondaryAnimation);
    handleIgnoranceCheck(animation, secondaryAnimation);
  }

  /// Checks for provided system ui.
  ///
  /// Won't be called if route is created via [onGenerateInitialRoutes].
  void handleSystemUiCheck(
      Animation<double> animation, Animation<double> secondaryAnimation) {
    Future<void> animate() async {
      if (!uiAnimating && animation.status == AnimationStatus.forward) {
        uiAnimating = true;
        await NFSystemUiControl.animateSystemUiOverlay(
          to: _checkSystemUi(),
          curve: transitionSettings.entCurve,
          settings: NFAnimationControllerSettings(
            // TODO: why * 2?
            duration: transitionDuration * 2,
          ),
        );
        uiAnimating = false;
      }
    }

    animate();
    animation.addStatusListener((status) {
      animate();
    });
  }

  /// Checks if animation  must be enabled
  void handleEnabledCheck(
      Animation<double> animation, Animation<double> secondaryAnimation) {
    entAnimationEnabled = transitionSettings.checkEntAnimationEnabled();
    animation.addStatusListener((status) {
      entAnimationEnabled = transitionSettings.checkEntAnimationEnabled();
    });
    exitAnimationEnabled = transitionSettings.checkExitAnimationEnabled();
    secondaryAnimation.addStatusListener((status) {
      exitAnimationEnabled = transitionSettings.checkExitAnimationEnabled();
    });
  }

  /// Checks if route taps must be ignored.
  void handleIgnoranceCheck(
      Animation<double> animation, Animation<double> secondaryAnimation) {
    animation.addStatusListener((status) {
      ignore =
          transitionSettings.entIgnore && status == AnimationStatus.forward ||
              status == AnimationStatus.reverse;
    });

    secondaryAnimation.addStatusListener((status) {
      secondaryIgnore =
          transitionSettings.exitIgnore && status == AnimationStatus.reverse;
    });
  }
}

class RouteAwareWidget extends StatefulWidget {
  RouteAwareWidget({
    @required this.child,
    this.routeObservers,
    this.onPush,
    this.onPop,
    this.onPushNext,
    this.onPopNext,
    this.logging = false,
  }) : assert(child != null);
  final Widget child;
  final List<RouteObserver> routeObservers;
  final Function onPush;
  final Function onPop;
  final Function onPushNext;
  final Function onPopNext;

  /// Enables logging of push and pop events.
  final bool logging;
  State<RouteAwareWidget> createState() => RouteAwareWidgetState();
}

// Implement RouteAware in a widget's state and subscribe it to the RouteObserver.
class RouteAwareWidgetState extends State<RouteAwareWidget> with RouteAware {
  List<RouteObserver> _routeObservers;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _routeObservers = widget.routeObservers ?? NFWidgets.routeObservers;
    for (final observer in _routeObservers) {
      observer.subscribe(this, ModalRoute.of(context));
    }
  }

  @override
  void dispose() {
    for (final observer in _routeObservers) {
      observer.unsubscribe(this);
    }
    super.dispose();
  }

  @override
  void didPush() {
    if (widget.logging) print("DID_PUSH");
    if (widget.onPush != null) widget.onPush();
    // Current route was pushed onto navigator and is now topmost route.
  }

  @override
  void didPop() {
    if (widget.logging) print("DID_POP");
    if (widget.onPop != null) widget.onPop();
    // Current route was pushed off the navigator.
  }

  @override
  void didPushNext() {
    if (widget.logging) print("DID_PUSH_NEXT");
    if (widget.onPushNext != null) widget.onPushNext();
    // Covering route was pushed into the navigator.
  }

  @override
  void didPopNext() {
    if (widget.logging) print("DID_POP_NEXT");
    if (widget.onPopNext != null) widget.onPopNext();
    // Covering route was popped off the navigator.
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

/// [SlideTransition] class, but with [enabled] parameter
class TurnableSlideTransition extends SlideTransition {
  TurnableSlideTransition(
      {Key key,
      @required Animation<Offset> position,
      bool transformHitTests: true,
      TextDirection textDirection,
      Widget child,
      this.enabled: true})
      : super(
          key: key,
          position: position,
          transformHitTests: transformHitTests,
          textDirection: textDirection,
          child: child,
        );

  /// If false, animation won't be played
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    if (enabled) {
      Offset offset = position.value;
      if (textDirection == TextDirection.rtl)
        offset = Offset(-offset.dx, offset.dy);
      return FractionalTranslation(
        translation: offset,
        transformHitTests: transformHitTests,
        child: child,
      );
    }
    return child;
  }
}
