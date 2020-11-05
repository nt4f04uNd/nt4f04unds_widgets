/*---------------------------------------------------------------------------------------------
*  Copyright (c) nt4f04und. All rights reserved.
*  Licensed under the BSD-style license. See LICENSE in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import 'package:flutter/services.dart';
import 'package:flutter/material.dart'
    hide showBottomSheet, showGeneralDialog, showModalBottomSheet;
import 'package:flutter/material.dart' as flutter
    show showGeneralDialog, showBottomSheet, showModalBottomSheet;
import 'package:nt4f04unds_widgets/constants.dart';
import 'package:nt4f04unds_widgets/nt4f04unds_widgets.dart';

const EdgeInsets defaultAlertTitlePadding =
    EdgeInsets.fromLTRB(26.0, 24.0, 26.0, 1.0);
const EdgeInsets defaultAlertContentPadding =
    EdgeInsets.fromLTRB(26.0, 0.0, 26.0, 3.0);

/// Class that contains composed 'show' functions, like [showDialog] and others
class NFShowFunctions {
  /// Empty constructor will allow enheritance.
  NFShowFunctions();
  NFShowFunctions._internal();
  static final NFShowFunctions _instance = NFShowFunctions._internal();
  static NFShowFunctions get instance => _instance;

  //****************** Enhanced Flutter functions *****************************************************

  /// Calls [showGeneralDialog] function from Flutter material library to show a message to user (only accept button).
  ///
  /// Also handles system UI animations to the custom [ui] and out of it on pop, defaults to [Constants.AppSystemUIThemes.modal].
  Future<dynamic> showAlert(
    BuildContext context, {
    Widget title,
    Widget content,
    EdgeInsets titlePadding = defaultAlertTitlePadding,
    EdgeInsets contentPadding = defaultAlertContentPadding,
    Widget acceptButton,
    List<Widget> additionalActions,
    SystemUiOverlayStyle ui,
  }) async {
    title ??= Text(l10n.warning);
    acceptButton ??= DialogButton.accept(text: l10n.close);
    return showDialog(
      context,
      title: title,
      content: content,
      titlePadding: titlePadding,
      contentPadding: contentPadding,
      acceptButton: acceptButton,
      additionalActions: additionalActions,
      hideDeclineButton: true,
    );
  }

  /// Calls [showGeneralDialog] function from Flutter material library to show a dialog to user (accept and decline buttons).
  ///
  /// Also handles system UI animations to the custom [ui] and out of it on pop, defaults to [Constants.AppSystemUIThemes.modal].
  Future<dynamic> showDialog(
    BuildContext context, {
    @required Widget title,
    Widget content,
    EdgeInsets titlePadding: defaultAlertTitlePadding,
    EdgeInsets contentPadding = defaultAlertContentPadding,
    Widget acceptButton,
    Widget declineButton,
    bool hideDeclineButton = false,
    List<Widget> additionalActions,
    double borderRadius = 8.0,
    SystemUiOverlayStyle ui,
  }) async {
    assert(title != null);

    var prevUi;
    if (ui != null) {
      prevUi = SystemUiControl.ui;
    }

    // Animate ui on open.
    SystemUiControl.animateSystemUiOverlay(to: ui);

    acceptButton ??= DialogButton.accept();
    if (!hideDeclineButton) {
      declineButton ??= DialogButton.cancel();
    }

    final closeFuture = flutter.showGeneralDialog(
      barrierColor: Colors.black54,
      transitionDuration: Constants.routeTransitionDuration,
      barrierDismissible: true,
      barrierLabel: 'SMMAlertDialog',
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
        return SafeArea(
          child: AlertDialog(
            backgroundColor: Theme.of(context).colorScheme.surface,
            contentPadding: EdgeInsets.zero,
            titlePadding: EdgeInsets.zero,
            contentTextStyle: Theme.of(context).textTheme.subtitle1.copyWith(
                  fontWeight: FontWeight.w500,
                  fontSize: 15.0,
                ),
            titleTextStyle: Theme.of(context).textTheme.headline5.copyWith(
                fontWeight: FontWeight.w700, fontSize: 20.0, height: 1.5),
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
                //  widget(child: content),
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
                        left: 14.0, right: 14.0, bottom: 10.0),
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
                            acceptButton,
                            if (!hideDeclineButton)
                              Padding(
                                padding: const EdgeInsets.only(left: 8.0),
                                child: declineButton,
                              )
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
    () async {
      await closeFuture;
      // Animate ui after sheet been closed.
      await SystemUiControl.animateSystemUiOverlay(to: prevUi);
    }();
    return closeFuture;
  }

  /// Calls [showBottomSheet], but also handles system UI animations to the custom [ui] and out of it on pop.
  ///
  /// [ui] Defaults to [Constants.AppSystemUIThemes.bottomSheet].
  PersistentBottomSheetController<T> showBottomSheet<T>({
    @required BuildContext context,
    @required WidgetBuilder builder,
    SystemUiOverlayStyle ui,
    Color backgroundColor,
    double elevation,
    ShapeBorder shape,
    Clip clipBehavior,
  }) {
    var prevUi;
    if (ui != null) {
      prevUi = SystemUiControl.ui;
    }
    // Animate ui on open.
    SystemUiControl.animateSystemUiOverlay(to: ui);
    final controller = flutter.showBottomSheet<T>(
      context: context,
      builder: (context) => RouteAwareWidget(
        onPopNext: () {
          // Animate ui when the route on top pops.
          SystemUiControl.animateSystemUiOverlay(to: ui);
        },
        child: builder(context),
      ),
      backgroundColor: backgroundColor,
      elevation: elevation,
      shape: shape,
      clipBehavior: clipBehavior,
    );
    if (ui != null) {
      () async {
        await controller.closed;
        // Animate ui after sheet been closed.
        SystemUiControl.animateSystemUiOverlay(to: prevUi);
      }();
    }
    return controller;
  }

  /// Calls [showModalBottomSheet], but also handles system UI animations to the custom [ui] and out of it on pop.
  ///
  /// [ui] Defaults to [Constants.AppSystemUIThemes.bottomSheet].
  Future<T> showModalBottomSheet<T>({
    @required BuildContext context,
    @required WidgetBuilder builder,
    SystemUiOverlayStyle ui,
    Color backgroundColor,
    double elevation,
    ShapeBorder shape,
    Clip clipBehavior,
    Color barrierColor,
    bool isScrollControlled = false,
    bool useRootNavigator = false,
    bool isDismissible = true,
    bool enableDrag = true,
    RouteSettings routeSettings,
  }) {
    var prevUi;
    if (ui != null) {
      prevUi = SystemUiControl.ui;
    }
    // Animate ui on open.
    SystemUiControl.animateSystemUiOverlay(to: ui);
    final closeFuture = flutter.showModalBottomSheet<T>(
      context: context,
      builder: (context) => RouteAwareWidget(
        onPopNext: () {
          // Animate ui when the route on top pops.
          SystemUiControl.animateSystemUiOverlay(to: ui);
        },
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
    if (ui != null) {
      () async {
        await closeFuture;
        // Animate ui after sheet been closed.
        SystemUiControl.animateSystemUiOverlay(to: prevUi);
      }();
    }
    return closeFuture;
  }
}
