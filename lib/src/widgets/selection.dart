/*---------------------------------------------------------------------------------------------
*  Copyright (c) nt4f04und. All rights reserved.
*  Licensed under the BSD-style license. See LICENSE in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:nt4f04unds_widgets/nt4f04unds_widgets.dart';

/// A regular [AppBar] which to use with selection and [SelectionController].
///
/// By default performs a fade switch animation while switching in and out of the selection mode.
///
/// See also:
/// * [AnimatedMenuCloseButton] which creates animated menu / close button which can be used with selection app bar
class SelectionAppBar extends AppBar {
  SelectionAppBar({
    super.key,
    required SelectionController selectionController,
    required Widget title,
    required Widget titleSelection,
    required List<Widget> actions,
    required List<Widget> actionsSelection,
    required VoidCallback? onMenuPressed,
    bool showMenuButton = true,
    Widget? leading,
    Curve curve = Curves.easeOutCubic,
    Curve reverseCurve = Curves.easeInCubic,
    super.flexibleSpace,
    super.bottom,
    double elevation = 2.0,
    double elevationSelection = 2.0,
    super.shape,
    super.backgroundColor,
    super.systemOverlayStyle,
    super.iconTheme,
    super.actionsIconTheme,
    TextTheme? textTheme,
    super.toolbarTextStyle,
    super.titleTextStyle,
    super.primary,
    super.centerTitle,
    super.excludeHeaderSemantics,
    double super.titleSpacing = NavigationToolbar.kMiddleSpacing,
    super.toolbarOpacity,
    super.bottomOpacity,
    super.toolbarHeight,
  }) : super(
         leading:
             !showMenuButton
                 ? leading
                 : Builder(
                   builder: (BuildContext context) {
                     return AnimatedMenuCloseButton(
                       animation: selectionController.animation,
                       onMenuPressed: onMenuPressed,
                       onClosePressed: selectionController.close,
                     );
                   },
                 ),
         title: AnimationSwitcher(
           animation: CurvedAnimation(curve: curve, reverseCurve: reverseCurve, parent: selectionController.animation),
           alignment: AlignmentDirectional.centerStart,
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
                 parent: selectionController.animation,
               ),
               alignment: Alignment.centerRight,
               builder2: defaultSelectionActionsBuilder,
               child1: Row(children: actions),
               child2: Row(children: actionsSelection),
             ),
           ),
         ],
         automaticallyImplyLeading: false,
         elevation: selectionController.inSelection ? elevationSelection : elevation,
       );

  static Widget defaultSelectionActionsBuilder(Widget child, Animation<double> animation) {
    return FadeTransition(
      opacity: animation,
      child: AnimatedBuilder(
        animation: animation,
        child: child,
        builder:
            (context, child) => Transform(
              transform: Matrix4.identity()..rotateX((1.0 - animation.value) * math.pi / 2),
              origin: const Offset(0.0, 30.0),
              child: child,
            ),
      ),
    );
  }
}

/// Wraps [AnimatedIcon] with menu / close animations and listens to [animation] statuses
/// to animate the button accordingly:
///
/// * forward or completed - [AnimatedIcons.menu_close]
/// * reverse or dismissed - [AnimatedIcons.close_menu]
///
/// As source of animation [SelectionController.animationController] can be used.
class AnimatedMenuCloseButton extends StatefulWidget {
  const AnimatedMenuCloseButton({
    super.key,
    required this.animation,
    this.size,
    this.iconSize,
    this.iconColor,
    this.onMenuPressed,
    this.onClosePressed,
    this.duration = const Duration(milliseconds: 500),
    this.reverseDuration,
    this.curve = Curves.easeOutCubic,
    this.reverseCurve = Curves.easeInCubic,
  });

  /// Animation controller that this button will listen to and animate together.
  ///
  /// This can't be used to control the exact animation of the buttun, though.
  final Animation animation;

  /// Button size. Defaults to [NFThemeData.iconButtonSize].
  final double? size;

  /// Icon size. Defaults to [NFThemeData.iconSize].
  final double? iconSize;

  /// Icon color. If none specified, theme color will be used.
  final Color? iconColor;

  /// The callback that will be called on tap on button when menu icon is shown.
  final VoidCallback? onMenuPressed;

  /// The callback that will be called on tap on button when close icon is shown.
  final VoidCallback? onClosePressed;

  /// The duration of the `menu_close` animation.
  final Duration duration;

  /// The duration of the `close_menu` animation.
  final Duration? reverseDuration;

  /// The curve to use for `menu_close` animation.
  final Curve curve;

  /// The curve to use for `close_menu` animation.
  final Curve reverseCurve;

  @override
  State createState() => _AnimatedMenuCloseButtonState();
}

class _AnimatedMenuCloseButtonState extends State<AnimatedMenuCloseButton> with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> animation;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(vsync: this, duration: widget.duration, reverseDuration: widget.reverseDuration);
    animation = Tween(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(curve: widget.curve, reverseCurve: widget.reverseCurve, parent: controller));

    widget.animation.addStatusListener(_handleParentAnimationStatusChange);

    final status = widget.animation.status;
    if (status == AnimationStatus.forward || status == AnimationStatus.reverse) {
      controller.forward();
    } else {
      controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(covariant AnimatedMenuCloseButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    controller.duration = widget.duration;
    controller.reverseDuration = widget.reverseDuration;
    if (oldWidget.curve != widget.curve || oldWidget.reverseCurve != widget.reverseCurve) {
      _createAnimation();
    }
    if (oldWidget.animation != widget.animation) {
      oldWidget.animation.removeStatusListener(_handleParentAnimationStatusChange);
      widget.animation.addStatusListener(_handleParentAnimationStatusChange);
    }
  }

  @override
  void dispose() {
    widget.animation.removeStatusListener(_handleParentAnimationStatusChange);
    controller.dispose();
    super.dispose();
  }

  void _handleParentAnimationStatusChange(AnimationStatus status) {
    if (status == AnimationStatus.forward || status == AnimationStatus.reverse) {
      controller.forward(from: 0.0);
    }
  }

  void _createAnimation() {
    animation = CurvedAnimation(curve: widget.curve, reverseCurve: widget.reverseCurve, parent: controller);
  }

  @override
  Widget build(BuildContext context) {
    final status = widget.animation.status;
    final showClose = status == AnimationStatus.completed || status == AnimationStatus.forward;
    final theme = Theme.of(context);
    return AnimatedBuilder(
      animation: controller,
      builder:
          (BuildContext context, Widget? child) => NFIconButton(
            size: widget.size ?? NFConstants.iconButtonSize,
            iconSize: widget.iconSize ?? NFConstants.iconSize,
            color: theme.colorScheme.onSurface,
            onPressed: showClose ? widget.onClosePressed : widget.onMenuPressed,
            icon: AnimatedIcon(
              icon: showClose ? AnimatedIcons.menu_close : AnimatedIcons.close_menu,
              color: widget.iconColor,
              progress: animation,
            ),
          ),
    );
  }
}
