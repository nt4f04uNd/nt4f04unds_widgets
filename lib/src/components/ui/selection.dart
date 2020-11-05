/*---------------------------------------------------------------------------------------------
*  Copyright (c) nt4f04und. All rights reserved.
*  Licensed under the BSD-style license. See LICENSE in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import 'package:flutter/material.dart';
import 'package:nt4f04unds_widgets/nt4f04unds_widgets.dart';
import 'package:nt4f04unds_widgets/src/constants.dart';

/// Just an [AppBar], but has the properties to specify how it will look in the selection mode.
/// Also performs a fade switch animation while switching in and out of the selection mode.
class SelectionAppBar extends AppBar {
  SelectionAppBar({
    Key key,
    @required SelectionController selectionController,
    @required Widget title,

    /// Title to show in selection
    @required Widget titleSelection,
    @required List<Widget> actions,

    /// Actions to show in selection
    @required List<Widget> actionsSelection,

    /// Go to selection animation
    Curve curve = Curves.easeOutCubic,

    /// Back from selection animation
    Curve reverseCurve = Curves.easeInCubic,
    bool automaticallyImplyLeading = true,
    Widget flexibleSpace,
    PreferredSizeWidget bottom,
    double elevation = 2.0,

    /// Elevation in selection
    double elevationSelection = 2.0,
    ShapeBorder shape,
    Color backgroundColor,
    Brightness brightness,
    IconThemeData iconTheme,
    IconThemeData actionsIconTheme,
    TextTheme textTheme,
    bool primary = true,
    bool centerTitle,
    bool excludeHeaderSemantics = false,
    double titleSpacing = NavigationToolbar.kMiddleSpacing,
    double toolbarOpacity = 1.0,
    double bottomOpacity = 1.0,
  }) : super(
          key: key,
          leading: Builder(
            builder: (BuildContext context) {
              return AnimatedMenuCloseButton(
                guideAnimation: selectionController.animationController,
                onCloseClick: selectionController.close,
                onMenuClick: () {
                  Scaffold.of(context).openDrawer();
                },
              );
            },
          ),
          title: AnimationSwitcher(
            animation: CurvedAnimation(
              curve: curve,
              reverseCurve: reverseCurve,
              parent: selectionController.animationController,
            ),
            child1: title,
            child2: titleSelection,
          ),
          actions: <Widget>[
            Padding(
              padding: const EdgeInsets.only(left: 5.0, right: 5.0),
              child: AnimationSwitcher(
                animation: CurvedAnimation(
                  curve: curve,
                  reverseCurve: reverseCurve,
                  parent: selectionController.animationController,
                ),
                child1: Row(children: actions),
                child2: Row(children: actionsSelection),
              ),
            ),
          ],
          automaticallyImplyLeading: automaticallyImplyLeading,
          flexibleSpace: flexibleSpace,
          bottom: bottom,
          elevation:
              selectionController.inSelection ? elevationSelection : elevation,
          shape: shape,
          backgroundColor: backgroundColor,
          brightness: brightness,
          iconTheme: iconTheme,
          actionsIconTheme: actionsIconTheme,
          textTheme: textTheme,
          primary: primary,
          centerTitle: centerTitle,
          excludeHeaderSemantics: excludeHeaderSemantics,
          titleSpacing: titleSpacing,
          toolbarOpacity: toolbarOpacity,
          bottomOpacity: bottomOpacity,
        );
}

class AnimatedMenuCloseButton extends StatefulWidget {
  AnimatedMenuCloseButton({
    Key key,
    @required this.guideAnimation,
    this.iconSize,
    this.size,
    this.iconColor,
    this.onMenuClick,
    this.onCloseClick,
  })  : assert(guideAnimation != null),
        super(key: key);

  /// Animation controller that this button will listen to and animate together.
  ///
  /// This can't be used to control the exact animation of the buttun, though.
  final Animation guideAnimation;
  final double iconSize;
  final double size;
  final Color iconColor;

  /// Handle click when menu is shown
  final Function onMenuClick;

  /// Handle click when close icon is shown
  final Function onCloseClick;

  AnimatedMenuCloseButtonState createState() => AnimatedMenuCloseButtonState();
}

class AnimatedMenuCloseButtonState extends State<AnimatedMenuCloseButton>
    with SingleTickerProviderStateMixin {
  AnimationController controller;
  Animation<double> animation;

  @override
  void initState() {
    super.initState();
    controller =
        AnimationController(vsync: this, duration: kNFSelectionDuration);
    animation = Tween(begin: 0.0, end: 1.0).animate(
      DefaultAnimation(parent: controller),
    );

    widget.guideAnimation.addStatusListener(_handleGuideStatusChange);

    final guideStatus = widget.guideAnimation.status;
    if (guideStatus == AnimationStatus.forward ||
        guideStatus == AnimationStatus.reverse) {
      controller.forward();
    } else if (guideStatus == AnimationStatus.completed ||
        guideStatus == AnimationStatus.dismissed) {
      controller.value = 1.0;
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _handleGuideStatusChange(AnimationStatus status) {
    if (status == AnimationStatus.forward ||
        status == AnimationStatus.reverse) {
      controller.value = 0.0;
      controller.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    final showClose = widget.guideAnimation.isCompleted ||
        widget.guideAnimation.status == AnimationStatus.forward;
    return AnimatedBuilder(
      animation: controller,
      builder: (BuildContext context, Widget child) => NFIconButton(
        size: widget.size ?? Constants.iconButtonSize,
        iconSize: widget.iconSize ?? Constants.iconSize,
        color: Theme.of(context).colorScheme.onSurface,
        onPressed: showClose ? widget.onCloseClick : widget.onMenuClick,
        icon: AnimatedIcon(
          icon: showClose ? AnimatedIcons.menu_close : AnimatedIcons.close_menu,
          color: widget.iconColor,
          // FIXME: this
          //  ?? Constants.AppTheme.playPauseIcon.auto(context),
          progress: animation,
        ),
      ),
    );
  }
}
