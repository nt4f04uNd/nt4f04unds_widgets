/*---------------------------------------------------------------------------------------------
*  Copyright (c) nt4f04und. All rights reserved.
*  Licensed under the BSD-style license. See LICENSE in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import 'package:flutter/services.dart';
import 'package:flutter/material.dart' hide showBottomSheet, showGeneralDialog, showModalBottomSheet;
import 'package:flutter/material.dart' as flutter show showGeneralDialog, showBottomSheet, showModalBottomSheet;
import 'package:nt4f04unds_widgets/nt4f04unds_widgets.dart';

const defaultAlertTitlePadding = EdgeInsets.fromLTRB(26.0, 24.0, 26.0, 1.0);
const defaultAlertContentPadding = EdgeInsets.fromLTRB(26.0, 0.0, 26.0, 3.0);

/// Class that contains composed 'show' functions, like [showDialog] and others
class NFShowFunctions {
  /// Empty constructor will allow enheritance.
  NFShowFunctions();
  NFShowFunctions._();
  static final NFShowFunctions instance = NFShowFunctions._();

  //****************** Enhanced Flutter functions *****************************************************

  /// Calls [showGeneralDialog] function from Flutter material library to show a message to user (only accept button).
  ///
  /// Also handles system UI animations to the custom [ui] and out of it on pop, defaults to [NFWidgets.defaultModalSystemUiStyle].
  Future<T?> showAlert<T extends Object?>(
    BuildContext context, {
    Widget? title,
    Widget? content,
    EdgeInsets titlePadding = defaultAlertTitlePadding,
    EdgeInsets contentPadding = defaultAlertContentPadding,
    Widget? acceptButton,
    Color? buttonSplashColor,
    List<Widget>? additionalActions,
    SystemUiOverlayStyle? ui,
  }) async {
    final l10n = NFLocalizations.of(context);
    title ??= Text(l10n.warning);
    acceptButton ??= NFButton.close();
    return showDialog<T>(
      context,
      title: title,
      content: content,
      titlePadding: titlePadding,
      contentPadding: contentPadding,
      acceptButton: acceptButton,
      buttonSplashColor: buttonSplashColor,
      additionalActions: additionalActions,
      hideCancelButton: true,
      ui: ui,
    );
  }

  /// Calls [showGeneralDialog] function from Flutter material library to show a dialog to user (accept and decline buttons).
  ///
  /// Also handles system UI animations to the custom [ui] and out of it on pop, defaults to [NFWidgets.defaultModalSystemUiStyle].
  Future<T?> showDialog<T extends Object?>(
    BuildContext context, {
    required Widget title,
    Widget? content,
    EdgeInsets titlePadding: defaultAlertTitlePadding,
    EdgeInsets contentPadding = defaultAlertContentPadding,
    Widget? acceptButton,
    Widget? cancelButton,
    Color? buttonSplashColor,
    bool hideCancelButton = false,
    List<Widget>? additionalActions,
    double borderRadius = 8.0,
    SystemUiOverlayStyle? ui,
  }) async {
    ui ??= NFTheme.of(context).modalSystemUiStyle;
    SystemUiOverlayStyle? lastUi;
    if (ui != null) {
      lastUi = SystemUiStyleController.lastUi;
      // Animate ui on open.
      SystemUiStyleController.animateSystemUiOverlay(to: ui);
    }

    acceptButton ??= NFButton.accept(splashColor: buttonSplashColor);
    if (!hideCancelButton) {
      cancelButton ??= NFButton.cancel(splashColor: buttonSplashColor);
    }

    return flutter.showGeneralDialog<T>(
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 300),
      barrierDismissible: true,
      barrierLabel: 'NFAlertDialog',
      context: context,
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final scaleAnimation = Tween(begin: 0.9, end: 1.0).animate(
          CurvedAnimation(
            curve: Curves.easeOutCubic,
            reverseCurve: Curves.easeInCubic,
            parent: animation,
          ),
        );
        final fadeAnimation = CurvedAnimation(
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
          parent: animation,
        );
        return ScaleTransition(
          scale: scaleAnimation,
          child: FadeTransition(
            opacity: fadeAnimation,
            child: child,
          ),
        );
      },
      pageBuilder: (context, animation, secondaryAnimation) {
        return _UiHelper(
          ui: ui,
          lastUi: lastUi,
          child: SafeArea(
            child: AlertDialog(
              backgroundColor: Theme.of(context).colorScheme.surface,
              contentPadding: EdgeInsets.zero,
              titlePadding: EdgeInsets.zero,
              contentTextStyle: Theme.of(context).textTheme.subtitle1?.copyWith(
                fontWeight: FontWeight.w500,
                fontSize: 15.0,
              ),
              titleTextStyle: Theme.of(context).textTheme.headline5?.copyWith(
                fontWeight: FontWeight.w700, 
                fontSize: 20.0, 
                height: 1.5
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(borderRadius),
                ),
              ),
              title: Container(
                padding: titlePadding,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(borderRadius),
                    topRight: Radius.circular(borderRadius),
                  ),
                ),
                child: title,
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  if (content != null)
                    Flexible(
                      child: Padding(
                        padding: contentPadding,
                        child: NFScrollbar(
                          thickness: 5.0,
                          child: SingleChildScrollView(
                            child: content,
                          ),
                        ),
                      ),
                    ),
                  Material(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(borderRadius),
                      bottomRight: Radius.circular(borderRadius),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(
                        top: 4.0,
                        left: 14.0,
                        right: 14.0,
                        bottom: 10.0,
                      ),
                      child: Row(
                        mainAxisAlignment: additionalActions == null
                            ? MainAxisAlignment.end
                            : MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          if (additionalActions != null)
                            ButtonBar(
                              buttonPadding: EdgeInsets.zero,
                              alignment: MainAxisAlignment.start,
                              children: additionalActions,
                            ),
                          ButtonBar(
                            buttonPadding: EdgeInsets.zero,
                            mainAxisSize: MainAxisSize.min,
                            alignment: MainAxisAlignment.end,
                            children: <Widget>[
                              if (!hideCancelButton)
                                Padding(
                                  padding: const EdgeInsets.only(right: 8.0),
                                  child: cancelButton,
                                ),
                              acceptButton!,
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// Calls [showBottomSheet], but also handles system UI animations to the custom [ui] and out of it on pop.
  ///
  /// [ui] Defaults to [NFWidgets.defaultBottomSheetSystemUiStyle].
  PersistentBottomSheetController<T> showBottomSheet<T>({
    required BuildContext context,
    required WidgetBuilder builder,
    SystemUiOverlayStyle? ui,
    Color? backgroundColor,
    double? elevation,
    ShapeBorder? shape,
    Clip? clipBehavior,
  }) {
    ui ??= NFTheme.of(context).bottomSheetSystemUiStyle;
    SystemUiOverlayStyle? lastUi;
    if (ui != null) {
      lastUi = SystemUiStyleController.lastUi;
      // Animate ui on open.
      SystemUiStyleController.animateSystemUiOverlay(to: ui);
    }
    return flutter.showBottomSheet<T>(
      context: context,
      builder: (context) => _UiHelper(
        ui: ui,
        lastUi: lastUi,
        child: builder(context),
      ),
      backgroundColor: backgroundColor,
      elevation: elevation,
      shape: shape,
      clipBehavior: clipBehavior,
    );
  }

  /// Calls [showModalBottomSheet], but also handles system UI animations to the custom [ui] and out of it on pop.
  ///
  /// [ui] Defaults to [FWidgets.defaultBottomSheetSystemUiStyle].
  Future<T?> showModalBottomSheet<T>({
    required BuildContext context,
    required WidgetBuilder builder,
    SystemUiOverlayStyle? ui,
    Color? backgroundColor,
    double? elevation,
    ShapeBorder? shape,
    Clip? clipBehavior,
    Color? barrierColor,
    bool isScrollControlled = false,
    bool useRootNavigator = false,
    bool isDismissible = true,
    bool enableDrag = true,
    RouteSettings? routeSettings,
  }) {
    ui ??= NFTheme.of(context).bottomSheetSystemUiStyle;
    SystemUiOverlayStyle? lastUi;
    if (ui != null) {
      lastUi = SystemUiStyleController.lastUi;
      // Animate ui on open.
      SystemUiStyleController.animateSystemUiOverlay(to: ui);
    }
    return flutter.showModalBottomSheet<T>(
      context: context,
      builder: (context) => _UiHelper(
        ui: ui,
        lastUi: lastUi,
        child: builder(context),
      ),
      backgroundColor: backgroundColor,
      elevation: elevation,
      shape: shape,
      clipBehavior: clipBehavior,
      barrierColor: barrierColor,
      isScrollControlled: isScrollControlled,
      useRootNavigator: useRootNavigator,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      routeSettings: routeSettings,
    );
  }
}

/// Helper that wraps widget into [RouteAwareWidget] and handles ui animations.
class _UiHelper extends StatelessWidget {
  const _UiHelper({
    Key? key,
    required this.ui,
    required this.lastUi,
    required this.child,
  }) : super(key: key);

  final SystemUiOverlayStyle? ui;
  final SystemUiOverlayStyle? lastUi;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return RouteAwareWidget(
      onPopNext: () {
        if (ui != null) {
          // Animate ui when the route on top pops.
          SystemUiStyleController.animateSystemUiOverlay(to: ui!);
        }
      },
      onPop: () {
        if (lastUi != null) {
          // Animate ui after sheet been closed.
          SystemUiStyleController.animateSystemUiOverlay(to: lastUi!);
        }
      },
      child: child
    );
  }
}