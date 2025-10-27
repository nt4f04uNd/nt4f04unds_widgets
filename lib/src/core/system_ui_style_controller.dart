/*---------------------------------------------------------------------------------------------
*  Copyright (c) nt4f04und. All rights reserved.
*  Licensed under the BSD-style license. See LICENSE in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nt4f04unds_widgets/nt4f04unds_widgets.dart';

/// Allows to perform animations on [SystemUiOverlayStyle] and provides some convenience methods
/// ands properties, like [actualUi].
///
/// When using this class, it's recommended to never call [SystemChrome.setSystemUIOverlayStyle] directly.
class SystemUiStyleController {
  static SystemUiStyleController instance = SystemUiStyleController();

  SystemUiOverlayStyle? _ui;
  late SystemUiOverlayStyle _from;

  /// It's not `late` because is use it in [lastUi].
  SystemUiOverlayStyle? _to;
  AnimationController? _controller;
  PersistentTickerProvider _tickerProvider = PersistentTickerProvider();

  /// Operation to wait before the animation completes
  Completer? _animationCompleter;
  StreamController<SystemUiOverlayStyle> _streamController = StreamController.broadcast();

  /// Represents the actual UI that is now drawn on the screen.
  ///
  /// Before using this property, it's required to call [setSystemUiOverlay] or
  /// [animateSystemUiOverlay] with `from` parameter at least once.
  SystemUiOverlayStyle get actualUi {
    assert(() {
      if (_ui == null) {
        throw StateError(
          "`from` happaned to be null. Could not imply it from `actualUi`, because it's null. \n"
          "Specify `from` it directly, or either call `setSystemUiOverlay` to set `actualUi` so controller would know the current ui to animate from it.",
        );
      }
      return true;
    }());
    return _ui!;
  }

  /// This value is the UI that the current animation, if it exists, leads to
  /// or (led to, if it's ended).
  SystemUiOverlayStyle get lastUi => _to ?? actualUi;

  /// The stream notifying of the [actualUi] changes.
  Stream<SystemUiOverlayStyle> get onUiChange => _streamController.stream;

  /// Curve that will be used for UI animations.
  Curve curve = Curves.linear;

  /// Duration that will be used for UI animations.
  Duration duration = const Duration(milliseconds: 240);

  /// Sets a new overlay ui style, any existing animation will be cancelled.
  void setSystemUiOverlay(SystemUiOverlayStyle ui) {
    _controller?.dispose();
    _controller = null;
    _handleEnd();
    _ui = ui;
    _to = ui;
    _streamController.add(ui);
    SystemChrome.setSystemUIOverlayStyle(ui);
  }

  /// Performs a transition from one [SystemUiOverlayStyle] to another one.
  ///
  /// First time calling this method, you have to either:
  /// * provide [from]
  /// * before once call [setSystemUiOverlay]
  ///
  /// Otherwise, we won't know from which color we should perform the animation, so method will throw.
  ///
  /// The returned future will complete after the animation ends.
  ///
  /// The [to] is the Ui to animate to, it is required.
  ///
  /// The [from] is the UI to animate from. It can be omitted, if so, then the [actualUi] will be used instead.
  ///
  /// The [curve] is the animation curve.
  ///
  /// The [duration] is the animation duration.
  ///
  /// NOTE: don't `await` for this method in `main` this will lead to
  /// that your application never starts
  Future<void> animateSystemUiOverlay({
    SystemUiOverlayStyle? from,
    required SystemUiOverlayStyle to,
    Curve? curve,
    Duration? duration,
  }) {
    from ??= actualUi;
    _from = from;
    _to = to;
    curve ??= SystemUiStyleController.instance.curve;
    duration ??= SystemUiStyleController.instance.duration;
    _handleEnd();
    _handleStart(curve: curve, duration: duration);
    return _animationCompleter!.future;
  }

  /// Creates animation from the [curve] and [duration].
  void _handleStart({required Curve curve, required Duration duration}) {
    _animationCompleter = Completer();
    _controller?.dispose();
    _controller = AnimationController(
      duration: duration,
      debugLabel: 'SystemUiStyleController',
      vsync: _tickerProvider,
    );
    _controller!.addListener(() {
      final animation = SystemUiOverlayStyleTween(
        begin: _from,
        end: _to!,
      ).animate(CurvedAnimation(curve: curve, parent: _controller!));
      _ui = animation.value;
      _streamController.add(animation.value);
      SystemChrome.setSystemUIOverlayStyle(animation.value);
    });
    _controller!.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _handleEnd();
      }
    });
    _controller!.forward();
  }

  void _handleEnd() {
    if (_animationCompleter != null && !_animationCompleter!.isCompleted) {
      _animationCompleter!.complete();
      _animationCompleter = null;
    }
  }
}

/// An interpolation between two [SystemUiOverlayStyle]s.
class SystemUiOverlayStyleTween extends Tween<SystemUiOverlayStyle> {
  /// Creates a SystemUiOverlayStyle tween.
  ///
  /// The [begin] and [end] properties may be null. If both are null, then the
  /// result is always null.
  ///
  /// If [end] is not null, then its lerping logic is
  /// used (via [SystemUiOverlayStyle.lerpTo]). Otherwise, [begin]'s lerping logic is used
  /// (via [SystemUiOverlayStyle.lerpFrom]).
  SystemUiOverlayStyleTween({SystemUiOverlayStyle? begin, SystemUiOverlayStyle? end}) : super(begin: begin, end: end);

  /// Returns the value this variable has at the given animation clock value.
  @override
  SystemUiOverlayStyle lerp(double t) {
    final a = begin;
    final b = end;
    assert(a != null || b != null);
    if (a == null) {
      return b!;
    }
    if (b == null) {
      return a;
    }
    return SystemUiOverlayStyle(
      systemNavigationBarColor: Color.lerp(a.systemNavigationBarColor, b.systemNavigationBarColor, t),
      systemNavigationBarDividerColor: Color.lerp(
        a.systemNavigationBarDividerColor,
        b.systemNavigationBarDividerColor,
        t,
      ),
      systemNavigationBarIconBrightness:
          t > 0.5 ? a.systemNavigationBarIconBrightness : b.systemNavigationBarIconBrightness,
      statusBarColor: Color.lerp(a.statusBarColor, b.statusBarColor, t),
      statusBarBrightness: t > 0.5 ? a.statusBarBrightness : b.statusBarBrightness,
      statusBarIconBrightness: t > 0.5 ? a.statusBarIconBrightness : b.statusBarIconBrightness,
    );
  }
}
