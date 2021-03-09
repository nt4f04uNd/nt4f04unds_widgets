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
import 'package:nt4f04unds_widgets/nt4f04unds_widgets.dart';

import 'core/core.dart';

class _Observer extends WidgetsBindingObserver {
  @override
  void didChangeMetrics() {
    updateScreenSize();
  }
}

/// Core widget of the library.
/// 
/// At the app start you should call [init] method. That is required for some of the
/// widgets and functions in library to work properly.
/// 
/// See also:
/// * [NFTheme] in which you should wrap your widget tree
class NFWidgets {
  static _Observer? _observer;

  /// A key of you root navigator.
  static GlobalKey<NavigatorState>? navigatorKey;

  /// Route observers which are used inside route transitions.
  static List<RouteObserver>? routeObservers;

  /// Initializes some parameters for the package to work correctly.
  static void init({
    required GlobalKey<NavigatorState> navigatorKey,
    required List<RouteObserver> routeObservers,
  }) {
    NFWidgets.routeObservers = routeObservers;
    NFWidgets.navigatorKey = navigatorKey;
    updateScreenSize();
    if (_observer == null) {
      _observer = _Observer();
      WidgetsBinding.instance!.addObserver(_observer!);
    }
  }

  /// Removes the [WidgetsBinding] observer.
  static void dispose() {
    if (_observer != null) {
      WidgetsBinding.instance!.removeObserver(_observer!);
      _observer = null;
    }
  }
}

/// Provides access to [NFThemeData].
/// 
/// This is required for some of the widgets and functions in library, so you should
/// wrap your app into this widget.
class NFTheme extends InheritedWidget  {
  /// Creates inherited defaults widget.
  const NFTheme({
    Key? key,
    required this.data,
    required this.child,
  }) : super(child: child, key: key);

  /// Default library-wide values.
  final NFThemeData data;

  /// The widget below this widget in the tree.
  final Widget child;

  static NFThemeData of(BuildContext context) {
    return context.findAncestorWidgetOfExactType<NFTheme>()!.data;
  }

  @override
  bool updateShouldNotify(NFTheme oldWidget) {
    return oldWidget.data != data;
  }
}

/// Wraps up all default library-wide values.
///
/// This is required for some of the widgets and functions in library, so you should
/// wrap your app into [NFTheme] and pass this class into it.
class NFThemeData {
  /// Creates defaults values.
  const NFThemeData({
    required this.systemUiStyle,
    SystemUiOverlayStyle? modalSystemUiStyle,
    SystemUiOverlayStyle? bottomSheetSystemUiStyle,
    this.iconSize = NFConstants.iconSize,
    this.iconButtonSize = NFConstants.iconButtonSize,
  }) : _modalSystemUiStyle = modalSystemUiStyle,
       _bottomSheetSystemUiStyle = bottomSheetSystemUiStyle;

  /// Default style of the system ui.
  ///
  /// For example, used within [RouteTransitions],
  /// or instead of [modalSystemUiStyle], [bottomSheetSystemUiStyle],
  /// if they were not specified.
  final SystemUiOverlayStyle systemUiStyle;
  final SystemUiOverlayStyle? _modalSystemUiStyle;
  final SystemUiOverlayStyle? _bottomSheetSystemUiStyle;

  /// Default icon size.
  final double iconSize;

  /// Default icon button size.
  final double iconButtonSize;

  /// Default style of the system ui with modals.
  ///
  /// Used in [NFShowFunctions.showAlert] and [NFShowFunctions.showDialog].
  /// If not specified, the [defaultSystemUiStyle] is used instead.
  SystemUiOverlayStyle get modalSystemUiStyle => _modalSystemUiStyle ?? systemUiStyle;

  /// Default style of the system ui with bottom sheets.
  ///
  /// [NFShowFunctions.showBottomSheet] and [NFShowFunctions.showModalBottomSheet]
  /// If not specified, the [defaultSystemUiStyle] is used instead.
  SystemUiOverlayStyle get bottomSheetSystemUiStyle => _bottomSheetSystemUiStyle ?? systemUiStyle;

  /// Creates a copy of these defaults but with the given fields replaced with
  /// the new values.
  NFThemeData copyWith({
    SystemUiOverlayStyle? systemUiStyle,
    SystemUiOverlayStyle? modalSystemUiStyle,
    SystemUiOverlayStyle? bottomSheetSystemUiStyle,
  }) {
    return NFThemeData(
      systemUiStyle: systemUiStyle ?? this.systemUiStyle,
      modalSystemUiStyle: modalSystemUiStyle ?? this.modalSystemUiStyle,
      bottomSheetSystemUiStyle: bottomSheetSystemUiStyle ?? this.bottomSheetSystemUiStyle,
    );
  }
}
