/*---------------------------------------------------------------------------------------------
*  Copyright (c) nt4f04und. All rights reserved.
*  Licensed under the BSD-style license. See LICENSE in the project root for license information.
*--------------------------------------------------------------------------------------------*/

export 'core/core.dart';
export 'widgets/widgets.dart';
export 'constants.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nt4f04unds_widgets/nt4f04unds_widgets.dart';

/// Core widget of the library.
///
/// At the app start you should call [init] method. That is required for some of the
/// widgets and functions in library to work properly.
///
/// See also:
/// * [NFTheme] in which you should wrap your widget tree
class NFWidgets {
  /// A key of the root navigator.
  ///
  /// Used in [NFSnackbarController] to obtain the root overlay to display snackbars.
  /// Can be omitted, if snackbars aren't used.
  static GlobalKey<NavigatorState>? navigatorKey;

  /// Route observers which are used inside route transitions.
  static List<RouteObserver>? routeObservers;

  /// Initializes some parameters for the package to work correctly.
  static void init({required List<RouteObserver> routeObservers, GlobalKey<NavigatorState>? navigatorKey}) {
    NFWidgets.routeObservers = routeObservers;
    NFWidgets.navigatorKey = navigatorKey;
  }
}

/// Provides access to [NFThemeData].
///
/// This is required for some of the widgets and functions in library, so you should
/// wrap your app into this widget.
class NFTheme extends InheritedWidget {
  /// Creates inherited defaults widget.
  const NFTheme({Key? key, required this.data, required this.child}) : super(child: child, key: key);

  /// Default library-wide values.
  final NFThemeData data;

  /// The widget below this widget in the tree.
  final Widget child;

  static NFThemeData of(BuildContext context) {
    final widget = context.getElementForInheritedWidgetOfExactType<NFTheme>()?.widget as NFTheme;
    return widget.data;
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
@immutable
class NFThemeData {
  /// Creates defaults values.
  const NFThemeData({
    this.systemUiStyle,
    SystemUiOverlayStyle? modalSystemUiStyle,
    SystemUiOverlayStyle? bottomSheetSystemUiStyle,
    this.alwaysApplyUiStyle = true,
    this.iconSize = NFConstants.iconSize,
    this.iconButtonSize = NFConstants.iconButtonSize,
  }) : _modalSystemUiStyle = modalSystemUiStyle,
       _bottomSheetSystemUiStyle = bottomSheetSystemUiStyle;

  /// Default style of the system ui.
  ///
  /// If specified, used to apply sustem ui when route is pushed/popped.
  ///
  /// Used:
  /// * instead of [modalSystemUiStyle], [bottomSheetSystemUiStyle], if they were not specified
  /// * as default value for system [RouteTransition.uiStyle], if [alwaysApplyUiStyle] is `true`.
  final SystemUiOverlayStyle? systemUiStyle;
  final SystemUiOverlayStyle? _modalSystemUiStyle;
  final SystemUiOverlayStyle? _bottomSheetSystemUiStyle;

  /// If [RouteTransition.uiStyle] is not specified, by default UI transition just won't happen.
  ///
  /// If this is set to true, it forces the route transition to use [systemUiStyle] as a default values and thus
  /// route transitions will always apply some UI style.
  final bool alwaysApplyUiStyle;

  /// Default icon size.
  /// todo: remove when https://github.com/flutter/flutter/issues/77801 is resolved.
  final double iconSize;

  /// Default icon button size.
  final double iconButtonSize;

  /// Default style of the system ui with modals.
  ///
  /// Used in [NFShowFunctions.showAlert] and [NFShowFunctions.showDialog].
  /// If not specified, the [defaultSystemUiStyle] is used instead.
  SystemUiOverlayStyle? get modalSystemUiStyle => _modalSystemUiStyle ?? systemUiStyle;

  /// Default style of the system ui with bottom sheets.
  ///
  /// [NFShowFunctions.showBottomSheet] and [NFShowFunctions.showModalBottomSheet]
  /// If not specified, the [defaultSystemUiStyle] is used instead.
  SystemUiOverlayStyle? get bottomSheetSystemUiStyle => _bottomSheetSystemUiStyle ?? systemUiStyle;

  /// Creates a copy of these defaults but with the given fields replaced with
  /// the new values.
  NFThemeData copyWith({
    SystemUiOverlayStyle? systemUiStyle,
    SystemUiOverlayStyle? modalSystemUiStyle,
    SystemUiOverlayStyle? bottomSheetSystemUiStyle,
    bool? alwaysApplyUiStyle,
    double? iconSize,
    double? iconButtonSize,
  }) {
    return NFThemeData(
      systemUiStyle: systemUiStyle ?? this.systemUiStyle,
      modalSystemUiStyle: modalSystemUiStyle ?? this.modalSystemUiStyle,
      bottomSheetSystemUiStyle: bottomSheetSystemUiStyle ?? this.bottomSheetSystemUiStyle,
      alwaysApplyUiStyle: alwaysApplyUiStyle ?? this.alwaysApplyUiStyle,
      iconSize: iconSize ?? this.iconSize,
      iconButtonSize: iconButtonSize ?? this.iconButtonSize,
    );
  }
}
