/*---------------------------------------------------------------------------------------------
*  Copyright (c) nt4f04und. All rights reserved.
*  Licensed under the BSD-style license. See LICENSE in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nt4f04unds_widgets/src/constants.dart';
import 'package:nt4f04unds_widgets/nt4f04unds_widgets.dart';

const String kNFSystemUiOverlayAnimationDebugLabel =
    "SystemUIOverlayAnimationController";

/// Holds [AnimationController] settings.
class AnimationControllerSettings {
  const AnimationControllerSettings({
    this.value,
    this.duration,
    this.reverseDuration,
    this.lowerBound,
    this.upperBound,
    this.animationBehavior,
  });

  /// Creates default configuration of the [AnimationController].
  const AnimationControllerSettings.defaultConfig({
    this.value = 0.0,
    this.duration = Constants.routeTransitionDuration,
    this.reverseDuration,
    this.lowerBound = 0.0,
    this.upperBound = 1.0,
    this.animationBehavior,
  });

  final double value;
  final Duration duration;
  final Duration reverseDuration;
  final double lowerBound;
  final double upperBound;
  final AnimationBehavior animationBehavior;

  /// Creates a copy of this animation settings but with the given fields replaced with
  /// the new values.
  AnimationControllerSettings copyWith(AnimationControllerSettings other) {
    assert(other != null);
    return AnimationControllerSettings(
      value: other.value ?? this.value,
      duration: other.duration ?? this.duration,
      reverseDuration: other.reverseDuration ?? this.reverseDuration,
      lowerBound: other.lowerBound ?? this.lowerBound,
      upperBound: other.upperBound ?? this.upperBound,
      animationBehavior: other.animationBehavior ?? this.animationBehavior,
    );
  }
}

abstract class SystemUiControl {
  static SystemUiOverlayStyle _from;
  static SystemUiOverlayStyle _to;
  static Curve _curve;

  static AnimationController _controller;
  static PersistentTickerProvider _tickerProvider;

  /// Operation to wait before the animation completes
  static Completer _animationCompleter;
  static StreamController<SystemUiOverlayStyle> _streamController =
      StreamController.broadcast();

  static AnimationControllerSettings _controllerSettings =
      const AnimationControllerSettings.defaultConfig();

  static SystemUiOverlayStyle _ui = const SystemUiOverlayStyle();

  /// Represents the actual UI that is now drawn on the screen.
  ///
  /// Defaults to [const SystemUiOverlayStyle()].
  ///
  /// You should call either [setSystemUiOverlay] or [animateSystemUiOverlay]
  /// on the app start to update this value.
  static SystemUiOverlayStyle get actualUi => _ui;

  /// This value is ultimately the Ui that the current animation, if it exists, leads to.
  static SystemUiOverlayStyle get ui => _to ?? actualUi;

  /// The stream notifying of the [actualUi] changes.
  static Stream<SystemUiOverlayStyle> get onUiChange =>
      _streamController.stream;

  /// Sets up settings of the animation controller.
  ///
  /// Will override the existing settings with new ones.
  /// You can also omit some values and they will remain unchanged.
  ///
  /// Will reset settings to default if no value has been passed.
  static void setControllerSettings(
      [AnimationControllerSettings settings =
          const AnimationControllerSettings.defaultConfig()]) async {
    _controllerSettings = _controllerSettings.copyWith(settings);
  }

  /// Sets a new overlay ui style, any existing animation will be cancelled.
  static void setSystemUiOverlay(SystemUiOverlayStyle ui) {
    _controller?.dispose();
    _controller = null;
    _handleEnd();
    _ui = ui;
    _to = ui;
    _streamController.add(ui);
    SystemChrome.setSystemUIOverlayStyle(ui);
  }

  /// Performs a transition between two UIs, which are represented with [from] and [to].
  ///
  /// The [to] is required, whereas [from] can be omitted, if so, [actualUi] will be used instead.
  ///
  /// User [curve] to apply a custom transition curve.
  ///
  /// The passed [settings] will override (with merge) current settings for just this transition.
  ///
  /// The returned future completes after the animation ends or cancels.
  static Future<void> animateSystemUiOverlay({
    SystemUiOverlayStyle from,
    @required SystemUiOverlayStyle to,
    Curve curve = Curves.easeOutCubic,
    AnimationControllerSettings settings,
  }) {
    assert(to != null);
    from ??= _ui;
    _from = from;
    _to = to;
    _curve = curve;
    _handleEnd();
    _handleStart(settings);
    return _animationCompleter.future;
  }

  /// Creates the controller from the provided settings.
  /// The passed settings will override current settings respectively.
  static void _handleStart(AnimationControllerSettings settings) {
    _animationCompleter = Completer();
    _controller?.dispose();
    _controller = AnimationController(
      value: settings?.value ?? _controllerSettings.value,
      duration: settings?.duration ?? _controllerSettings.duration,
      reverseDuration:
          settings?.reverseDuration ?? _controllerSettings.reverseDuration,
      debugLabel: "SystemUIOverlayAnimationController",
      lowerBound: settings?.lowerBound ?? _controllerSettings.lowerBound,
      upperBound: settings?.upperBound ?? _controllerSettings.upperBound,
      animationBehavior:
          settings?.animationBehavior ?? _controllerSettings.animationBehavior,
      vsync: _tickerProvider,
    );
    if (_tickerProvider.ticker?.isActive == false) {
      _tickerProvider.ticker.start();
    }
    _controller.addListener(() {
      final animation =
          SystemUiOverlayStyleTween(begin: _from, end: _to).animate(
        CurvedAnimation(curve: _curve, parent: _controller),
      );
      _ui = animation.value;
      _streamController.add(animation.value);
      SystemChrome.setSystemUIOverlayStyle(animation.value);
    });
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _handleEnd();
      }
    });
    _controller.forward();
  }

  static void _handleEnd() {
    if (_tickerProvider.ticker?.isActive == true) {
      _tickerProvider.ticker.stop();
    }
    if (_animationCompleter != null &&
        _animationCompleter.isCompleted == false) {
      _animationCompleter.complete();
      _animationCompleter = null;
    }
  }
}

/// A tween for [SystemUiOverlayStyle].
class SystemUiOverlayStyleTween extends Tween<SystemUiOverlayStyle> {
  SystemUiOverlayStyleTween(
      {SystemUiOverlayStyle begin, SystemUiOverlayStyle end})
      : assert(
          begin != null || end != null,
          "Either begin, or end, or both have to be specified",
        ),
        super(begin: begin, end: end);

  /// Returns the value this variable has at the given animation clock value.
  @override
  SystemUiOverlayStyle lerp(double t) {
    final a = begin;
    final b = end;
    assert(t != null);
    if (a == null) {
      return b;
    }
    if (b == null) {
      return a;
    }

    // The 0.95 here, because that's just the optimal value for the system brightness change animation.
    return SystemUiOverlayStyle(
      systemNavigationBarColor:
          Color.lerp(a.systemNavigationBarColor, b.systemNavigationBarColor, t),
      systemNavigationBarDividerColor: Color.lerp(
          a.systemNavigationBarDividerColor,
          b.systemNavigationBarDividerColor,
          t),
      systemNavigationBarIconBrightness: t > 0.95
          ? a.systemNavigationBarIconBrightness
          : b.systemNavigationBarIconBrightness,
      statusBarColor: Color.lerp(a.statusBarColor, b.statusBarColor, t),
      statusBarBrightness:
          t > 0.95 ? a.statusBarBrightness : b.statusBarBrightness,
      statusBarIconBrightness:
          t > 0.95 ? a.statusBarIconBrightness : b.statusBarIconBrightness,
    );
  }
}
