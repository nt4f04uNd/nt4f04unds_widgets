/*---------------------------------------------------------------------------------------------
*  Copyright (c) nt4f04und. All rights reserved.
*  Licensed under the BSD-style license. See LICENSE in the project root for license information.
*--------------------------------------------------------------------------------------------*/

export 'core/core.dart';
export 'widgets/widgets.dart';
export 'localization/localization.dart';
export 'constants.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'core/core.dart';

class _Observer extends WidgetsBindingObserver {
  @override
  void didChangeMetrics() {
    updateScreenSize();
  }
}

abstract class NFWidgets {
  /// Prevents class inheritance.
  NFWidgets._();

  static SystemUiOverlayStyle _defaultModalSystemUiStyle;
  static SystemUiOverlayStyle _defaultBottomSheetSystemUiStyle;
  static _Observer _observer;

  /// Pass the parameters for the package to work properly.
  ///
  /// You can actually pass null to [defaultModalSystemUiStyle] and
  /// [defaultBottomSheetSystemUiStyle].
  static void init({
    @required GlobalKey<NavigatorState> navigatorKey,
    @required List<RouteObserver> routeObservers,
    @required SystemUiOverlayStyle defaultSystemUiStyle,
    @required SystemUiOverlayStyle defaultModalSystemUiStyle,
    @required SystemUiOverlayStyle defaultBottomSheetSystemUiStyle,
  }) {
    NFWidgets.routeObservers = routeObservers;
    NFWidgets.navigatorKey = navigatorKey;
    NFWidgets.defaultSystemUiStyle = defaultSystemUiStyle;
    NFWidgets.defaultModalSystemUiStyle = defaultModalSystemUiStyle;
    NFWidgets.defaultBottomSheetSystemUiStyle = defaultBottomSheetSystemUiStyle;
    updateScreenSize();
    if (_observer == null) {
      _observer = _Observer();
      WidgetsBinding.instance.addObserver(_observer);
    }
  }

  /// Removes the [WidgetsBinding] observer.
  static void dispose() {
    if (_observer != null) {
      WidgetsBinding.instance.removeObserver(_observer);
      _observer = null;
    }
  }

  /// A key of you root navigator.
  static GlobalKey<NavigatorState> navigatorKey;

  /// Route observers which are used inside route transitions.
  static List<RouteObserver> routeObservers;

  /// Default style of the system ui.
  ///
  /// For example, used within [RouteTransitions],
  /// or instead of [defaultModalSystemUiStyle], [defaultBottomSheetSystemUiStyle],
  /// if they were not specified.
  static SystemUiOverlayStyle defaultSystemUiStyle;

  /// Default style of the system ui with modals.
  ///
  /// Used in [NFShowFunctions.showAlert] and [NFShowFunctions.showDialog].
  /// If not specified, the [defaultSystemUiStyle] is used instead.
  static SystemUiOverlayStyle get defaultModalSystemUiStyle => _defaultModalSystemUiStyle ?? defaultSystemUiStyle;
  static set defaultModalSystemUiStyle(SystemUiOverlayStyle value) {
    _defaultModalSystemUiStyle = value;
  }

  /// Default style of the system ui with bottom sheets.
  ///
  /// [NFShowFunctions.showBottomSheet] and [NFShowFunctions.showModalBottomSheet]
  /// If not specified, the [defaultSystemUiStyle] is used instead.
  static SystemUiOverlayStyle get defaultBottomSheetSystemUiStyle => _defaultBottomSheetSystemUiStyle ?? defaultSystemUiStyle;
  static set defaultBottomSheetSystemUiStyle(SystemUiOverlayStyle value) {
    _defaultBottomSheetSystemUiStyle = value;
  }
}
