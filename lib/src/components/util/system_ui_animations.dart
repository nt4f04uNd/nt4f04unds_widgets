/*---------------------------------------------------------------------------------------------
*  Copyright (c) nt4f04und. All rights reserved.
*  Licensed under the BSD-style license. See LICENSE in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nt4f04unds_widgets/nt4f04unds_widgets.dart';

/// Holds [AnimationController] settings.
class NFAnimationControllerSettings {
  /// The omitted values will be null.
  const NFAnimationControllerSettings({
    this.value,
    this.duration,
    this.reverseDuration,
    this.lowerBound,
    this.upperBound,
    this.animationBehavior,
  });

  /// Creates default configuration of the animation controller.
  const NFAnimationControllerSettings.defaultConfig({
    this.value = 0.0,
    this.duration = kNFRouteTransitionDuration,
    this.reverseDuration,
    this.lowerBound = 0.0,
    this.upperBound = 1.0,
    this.animationBehavior = AnimationBehavior.normal,
  });

  final double value;
  final Duration duration;
  final Duration reverseDuration;
  final double lowerBound;
  final double upperBound;
  final AnimationBehavior animationBehavior;

  /// Creates a copy of this animation controller settings but with the given fields replaced
  /// from [other] controller settings.
  NFAnimationControllerSettings copyWith(NFAnimationControllerSettings other) {
    assert(other != null);
    return NFAnimationControllerSettings(
      value: other.value ?? this.value,
      duration: other.duration ?? this.duration,
      reverseDuration: other.reverseDuration ?? this.reverseDuration,
      lowerBound: other.lowerBound ?? this.lowerBound,
      upperBound: other.upperBound ?? this.upperBound,
      animationBehavior: other.animationBehavior ?? this.animationBehavior,
    );
  }
}

abstract class NFSystemUiControl {
  static SystemUiOverlayStyle _ui;
  static SystemUiOverlayStyle _from;
  static SystemUiOverlayStyle _to = NFWidgets.defaultSystemUiStyle;
  static Curve _curve;

  static AnimationController _controller;
  static PersistentTickerProvider _tickerProvider = PersistentTickerProvider();

  /// Operation to wait before the animation completes
  static Completer _animationCompleter;
  static StreamController<SystemUiOverlayStyle> _streamController =
      StreamController.broadcast();

  static NFAnimationControllerSettings _controllerSettings =
      const NFAnimationControllerSettings.defaultConfig();

  /// Represents the actual UI that is now drawn on the screen.
  ///
  /// Defaults to [const SystemUiOverlayStyle()].
  ///
  /// You should call either [setSystemUiOverlay] or [animateSystemUiOverlay]
  /// on the app start to update this value.
  static SystemUiOverlayStyle get actualUi => _ui;

  /// This value is ultimately the Ui that the current animation, if it exists, leads to
  /// or (led to, if it's ended).
  static SystemUiOverlayStyle get lastUi => _to ?? actualUi;

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
      [NFAnimationControllerSettings settings =
          const NFAnimationControllerSettings.defaultConfig()]) async {
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

  /// Performs a transition from old overlay to new one.
  ///
  /// The returned future will complete after the animation ends.
  ///
  /// [from] is Ui to animate from. It can be omitted, if so, then the internal [_lastUi] will be used instead.
  ///
  /// [to] is the Ui to animate to. It is required.
  ///
  /// [curve] is a custom animation curve
  ///
  /// The passed [settings] will override current settings respectively.
  static Future<void> animateSystemUiOverlay({
    SystemUiOverlayStyle from,
    @required SystemUiOverlayStyle to,
    Curve curve = Curves.easeOutCubic,
    NFAnimationControllerSettings settings,
  }) {
    assert(to != null);
    _ui ??= NFWidgets.defaultSystemUiStyle;
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
  static void _handleStart(NFAnimationControllerSettings settings) {
    _animationCompleter = Completer();
    _controller?.dispose();
    _controller = AnimationController(
      value: settings?.value ?? _controllerSettings.value,
      duration: settings?.duration ?? _controllerSettings.duration,
      reverseDuration:
          settings?.reverseDuration ?? _controllerSettings.reverseDuration,
      debugLabel: "NFSystemUIOverlayAnimationController",
      lowerBound: settings?.lowerBound ?? _controllerSettings.lowerBound,
      upperBound: settings?.upperBound ?? _controllerSettings.upperBound,
      animationBehavior:
          settings?.animationBehavior ?? _controllerSettings.animationBehavior,
      vsync: _tickerProvider,
    );
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
    if (_animationCompleter != null &&
        _animationCompleter.isCompleted == false) {
      _animationCompleter.complete();
      _animationCompleter = null;
    }
  }
}

class SystemUiOverlayStyleTween extends Tween<SystemUiOverlayStyle> {
  /// Creates a SystemUiOverlayStyle tween.
  ///
  /// The [begin] and [end] properties may be null. If both are null, then the
  /// result is always null. If [end] is not null, then its lerping logic is
  /// used (via [SystemUiOverlayStyle.lerpTo]). Otherwise, [begin]'s lerping logic is used
  /// (via [SystemUiOverlayStyle.lerpFrom]).
  SystemUiOverlayStyleTween({
    SystemUiOverlayStyle begin,
    SystemUiOverlayStyle end,
  }) : super(begin: begin, end: end);

  /// Returns the value this variable has at the given animation clock value.
  @override
  SystemUiOverlayStyle lerp(double t) {
    final a = begin;
    final b = end;
    assert(a != null || b != null);
    assert(t != null);
    if (a == null) {
      return b;
    }
    if (b == null) {
      return a;
    }
    return SystemUiOverlayStyle(
      systemNavigationBarColor:
          Color.lerp(a.systemNavigationBarColor, b.systemNavigationBarColor, t),
      systemNavigationBarDividerColor: Color.lerp(
          a.systemNavigationBarDividerColor,
          b.systemNavigationBarDividerColor,
          t),
      systemNavigationBarIconBrightness: t > 0.5
          ? a.systemNavigationBarIconBrightness
          : b.systemNavigationBarIconBrightness,
      statusBarColor: Color.lerp(a.statusBarColor, b.statusBarColor, t),
      statusBarBrightness:
          t > 0.5 ? a.statusBarBrightness : b.statusBarBrightness,
      statusBarIconBrightness:
          t > 0.5 ? a.statusBarIconBrightness : b.statusBarIconBrightness,
    );
  }
}
