/*---------------------------------------------------------------------------------------------
*  Copyright (c) nt4f04und. All rights reserved.
*  Licensed under the BSD-style license. See LICENSE in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import 'package:flutter/material.dart';
import 'package:nt4f04unds_widgets/nt4f04unds_widgets.dart';

/// Button to go back from page.
class NFBackButton extends StatelessWidget {
  const NFBackButton({
    Key? key,
    this.icon,
    this.size = NFConstants.iconButtonSize,
    this.iconSize = NFConstants.iconSize,
    this.onPressed,
  }) : super(key: key);

  /// A custom icon for back button
  final IconData? icon;

  /// Button size. Defaults to [NFThemeData.iconButtonSize].
  final double? size;

  /// Icon size. Defaults to [NFThemeData.iconSize].
  final double? iconSize;

  /// Callback that will be called on button press that will override default
  /// pop callback.
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final nftheme = NFTheme.of(context);
    return NFIconButton(
      icon: Icon(
        icon ?? Icons.arrow_back_rounded,
      ),
      size: size ?? nftheme.iconButtonSize,
      iconSize: iconSize ?? nftheme.iconSize,
      onPressed: onPressed ?? () => Navigator.of(context).pop(),
    );
  }
}

/// An icon button, that can be toggled visually on and off with [enabled],
/// for example to repesent some logical state, like `on / off`.
/// 
/// On and off toggle will have a color animation.
class AnimatedIconButton extends StatefulWidget {
  AnimatedIconButton({
    Key? key,
    required this.onPressed,
    required this.icon,
    this.duration = const Duration(milliseconds: 500),
    this.size,
    this.iconSize,
    this.active = true,
    this.color,
    this.inactiveColor,
    this.disabledColor,
    this.tooltip,
  }) : super(key: key);

  /// An icon to use.
  final Widget icon;

  /// Callback that will be called on button press.
  ///
  /// If `null`, [disabledColor] is applied.
  final VoidCallback? onPressed;

  /// The toogle animation duration used.
  /// 
  /// By default 500 milliseconds.
  final Duration duration;

  /// Button size. Defaults to [NFThemeData.iconButtonSize].
  final double? size;
  
  /// Icon size. Defaults to [NFThemeData.iconSize].
  final double? iconSize;

  /// When given `false`, button will appear visually toggled off with [inactiveColor] applied.
  /// This won't prevent taps on button.
  final bool active;

  /// Default icon color.
  /// 
  /// If none specified, theme icon color is used.
  final Color? color;

  /// Inactive icon color which is applied with [active] set to `false`.
  /// 
  /// If none specified, [ThemeData.unselectedWidgetColor] color is used.
  final Color? inactiveColor;

  /// Color to use when [onPressed] is `null`.
  /// 
  /// If none specified, [ThemeData.disabledColor] color is used.
  final Color? disabledColor;
  
  /// Text that describes the action that will occur when the button is pressed.
  final String? tooltip;

  @override
  AnimatedIconButtonState createState() => AnimatedIconButtonState();
}

class AnimatedIconButtonState extends State<AnimatedIconButton> with SingleTickerProviderStateMixin {
  late AnimationController controller;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    if (widget.active && widget.onPressed != null) {
      controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(covariant AnimatedIconButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.active != widget.active || oldWidget.onPressed != widget.onPressed) {
      if (widget.active && widget.onPressed != null) {
        controller.forward();
      } else {
        controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final nftheme = NFTheme.of(context);
    final colorAnimation = ColorTween(
      begin: widget.onPressed != null
        ? widget.inactiveColor ?? theme.unselectedWidgetColor
        : widget.disabledColor ?? theme.disabledColor,
      end: widget.color ?? theme.iconTheme.color,
    ).animate(CurvedAnimation(
      parent: controller,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    ));
    return AnimatedBuilder(
      animation: controller,
      builder: (BuildContext context, Widget? child) => NFIconButton(
        icon: widget.icon,
        onPressed: widget.onPressed,
        iconSize: widget.iconSize ?? nftheme.iconSize,
        size: widget.size ?? nftheme.iconButtonSize,
        color: colorAnimation.value,
        disabledColor: colorAnimation.value,
        tooltip: widget.tooltip,
      ),
    );
  }
}
