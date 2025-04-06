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

  /// Calls [showGeneralDialog] function from Flutter material library to show a dialog to user (accept and decline buttons).
  ///
  /// Also handles system UI animations to the custom [ui] and out of it on pop, defaults to [NFWidgets.defaultModalSystemUiStyle].
  Future<T?> showDialog<T extends Object?>(
    BuildContext context, {
    required Widget title,
    Widget? content,
    EdgeInsets titlePadding = defaultAlertTitlePadding,
    EdgeInsets contentPadding = defaultAlertContentPadding,
    Widget? acceptButton,
    Widget? cancelButton,
    Color? buttonSplashColor,
    List<Widget>? additionalActions,
    double borderRadius = 8.0,
    SystemUiOverlayStyle? ui,
  }) async {
    ui ??= NFTheme.of(context).modalSystemUiStyle;
    SystemUiOverlayStyle? lastUi;
    if (ui != null) {
      lastUi = SystemUiStyleController.instance.lastUi;
      // Animate ui on open.
      SystemUiStyleController.instance.animateSystemUiOverlay(to: ui);
    }

    return flutter.showGeneralDialog<T>(
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 300),
      barrierDismissible: true,
      barrierLabel: 'NFAlertDialog',
      context: context,
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final scaleAnimation = Tween(
          begin: 0.9,
          end: 1.0,
        ).animate(CurvedAnimation(curve: Curves.easeOutCubic, reverseCurve: Curves.easeInCubic, parent: animation));
        final fadeAnimation = CurvedAnimation(
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
          parent: animation,
        );
        return ScaleTransition(scale: scaleAnimation, child: FadeTransition(opacity: fadeAnimation, child: child));
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
              contentTextStyle: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w500, fontSize: 15.0),
              titleTextStyle: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700, fontSize: 20.0, height: 1.5),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(borderRadius))),
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
                      child: Material(
                        // Prevent that content splash goes out of dialog border radius
                        color: Colors.transparent,
                        child: Padding(padding: contentPadding, child: content),
                      ),
                    ),
                  Material(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(borderRadius),
                      bottomRight: Radius.circular(borderRadius),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(top: 4.0, left: 14.0, right: 14.0, bottom: 10.0),
                      child: Row(
                        mainAxisAlignment:
                            additionalActions == null ? MainAxisAlignment.end : MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          if (additionalActions != null)
                            Flexible(
                              child: OverflowBar(
                                overflowDirection: VerticalDirection.down,
                                children: additionalActions,
                              ),
                            ),
                          if (acceptButton != null || cancelButton != null)
                            Flexible(
                              child: OverflowBar(
                                overflowDirection: VerticalDirection.down,
                                children: <Widget>[
                                  if (cancelButton != null) cancelButton,
                                  if (acceptButton != null && cancelButton != null) const SizedBox(width: 8.0),
                                  if (acceptButton != null) acceptButton,
                                ],
                              ),
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
  PersistentBottomSheetController showBottomSheet({
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
      lastUi = SystemUiStyleController.instance.lastUi;
      // Animate ui on open.
      SystemUiStyleController.instance.animateSystemUiOverlay(to: ui);
    }
    return flutter.showBottomSheet(
      context: context,
      builder: (context) => _UiHelper(ui: ui, lastUi: lastUi, child: builder(context)),
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
      lastUi = SystemUiStyleController.instance.lastUi;
      // Animate ui on open.
      SystemUiStyleController.instance.animateSystemUiOverlay(to: ui);
    }
    return flutter.showModalBottomSheet<T>(
      context: context,
      builder: (context) => _UiHelper(ui: ui, lastUi: lastUi, child: builder(context)),
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
class _UiHelper extends StatefulWidget {
  const _UiHelper({required this.ui, required this.lastUi, required this.child});

  final SystemUiOverlayStyle? ui;
  final SystemUiOverlayStyle? lastUi;
  final Widget child;

  @override
  State<_UiHelper> createState() => _UiHelperState();
}

class _UiHelperState extends State<_UiHelper> {
  bool _popped = false;
  Future<bool> _handlePop() async {
    if (_popped) {
      return false;
    }
    _popped = true;
    // TODO: workaround for https://github.com/flutter/flutter/issues/82046 - can remove, when it is fixed
    Navigator.pop(context);
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return BackButtonListener(
      onBackButtonPressed: _handlePop,
      child: RouteAwareWidget(
        onPopNext: () {
          if (widget.ui != null) {
            // Animate ui when the route on top pops.
            SystemUiStyleController.instance.animateSystemUiOverlay(to: widget.ui!);
          }
        },
        onPop: () {
          if (widget.lastUi != null) {
            // Animate ui after sheet been closed.
            SystemUiStyleController.instance.animateSystemUiOverlay(to: widget.lastUi!);
          }
        },
        child: widget.child,
      ),
    );
  }
}
