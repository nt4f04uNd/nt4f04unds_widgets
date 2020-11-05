/*---------------------------------------------------------------------------------------------
*  Copyright (c) nt4f04und. All rights reserved.
*  Licensed under the BSD-style license. See LICENSE in the project root for license information.
*--------------------------------------------------------------------------------------------*/

library nt4f04unds_widgets;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

export 'components/components.dart';
export 'localization/localization.dart';
export 'logic/logic.dart';
export 'utils/utils.dart';

abstract class NFWidgets {
  /// Pass here these parameters for package to work properly.
  static void init({
    @required RouteObserver<Route> routeObserver,
    @required SystemUiOverlayStyle defaultSystemUiStyle,
    @required GlobalKey<NavigatorState> navigatorKey,
  }) {
    assert(routeObserver != null);
    assert(defaultSystemUiStyle != null);
    assert(navigatorKey != null);

    routeObserver = routeObserver;
    defaultSystemUiStyle = defaultSystemUiStyle;
    navigatorKey = navigatorKey;
  }

  /// Route observer which is used inside route transitions.
  static RouteObserver<Route> routeObserver;

  /// Default style to be applied when the route transitions, if its [RouteTransition] is not specified.
  static SystemUiOverlayStyle defaultSystemUiStyle;
  static GlobalKey<NavigatorState> navigatorKey;
}
