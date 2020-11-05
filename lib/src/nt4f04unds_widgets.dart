export 'components/components.dart';
export 'localization/localization.dart';
export 'logic/logic.dart';
export 'utils/utils.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
