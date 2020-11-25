/*---------------------------------------------------------------------------------------------
*  Copyright (c) nt4f04und. All rights reserved.
*  Licensed under the BSD-style license. See LICENSE in the project root for license information.
*--------------------------------------------------------------------------------------------*/

export 'components/components.dart';
export 'localization/localization.dart';
export 'logic/logic.dart';
export 'utils/utils.dart';
export 'constants.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'components/components.dart';

abstract class NFWidgets {
  /// Prevents class inheritance.
  NFWidgets._();

  static SystemUiOverlayStyle _defaultModalSystemUiStyle;
  static SystemUiOverlayStyle _defaultBottomSheetSystemUiStyle;

  /// Pass the parameters for the package to work properly.
  ///
  /// You can actually pass null to [defaultModalSystemUiStyle] and
  /// [defaultBottomSheetSystemUiStyle].
  static void init({
    @required GlobalKey<NavigatorState> navigatorKey,
    @required RouteObserver<Route> routeObserver,
    @required SystemUiOverlayStyle defaultSystemUiStyle,
    @required SystemUiOverlayStyle defaultModalSystemUiStyle,
    @required SystemUiOverlayStyle defaultBottomSheetSystemUiStyle,
  }) {
    assert(routeObserver != null);
    assert(navigatorKey != null);
    assert(defaultSystemUiStyle != null);

    NFWidgets.routeObserver = routeObserver;
    NFWidgets.navigatorKey = navigatorKey;
    NFWidgets.defaultSystemUiStyle = defaultSystemUiStyle;
    NFWidgets.defaultModalSystemUiStyle = defaultModalSystemUiStyle;
    NFWidgets.defaultBottomSheetSystemUiStyle = defaultBottomSheetSystemUiStyle;
    updateScreenSize();
  }

  /// A key of you root navigator.
  static GlobalKey<NavigatorState> navigatorKey;

  /// Route observer which is used inside route transitions.
  static RouteObserver<Route> routeObserver;

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
  static SystemUiOverlayStyle get defaultModalSystemUiStyle =>
      _defaultModalSystemUiStyle ?? defaultSystemUiStyle;
  static set defaultModalSystemUiStyle(SystemUiOverlayStyle value) {
    _defaultModalSystemUiStyle = value;
  }

  /// Default style of the system ui with bottom sheets.
  ///
  /// [NFShowFunctions.showBottomSheet] and [NFShowFunctions.showModalBottomSheet]
  /// If not specified, the [defaultSystemUiStyle] is used instead.
  static SystemUiOverlayStyle get defaultBottomSheetSystemUiStyle =>
      _defaultBottomSheetSystemUiStyle ?? defaultSystemUiStyle;
  static set defaultBottomSheetSystemUiStyle(SystemUiOverlayStyle value) {
    _defaultBottomSheetSystemUiStyle = value;
  }
}
