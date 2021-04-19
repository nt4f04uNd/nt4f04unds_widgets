/*---------------------------------------------------------------------------------------------
*  Copyright (c) nt4f04und. All rights reserved.
*  Licensed under the BSD-style license. See LICENSE in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:nt4f04unds_widgets/src/constants.dart';
import 'package:nt4f04unds_widgets/nt4f04unds_widgets.dart';


/// Possible appearance variants for [NFButton].
enum NFButtonVariant { raised, flat }

const kNFButtonVariant = NFButtonVariant.flat;

enum _NFButtonFlavor { accept, cancel, close }

/// todo: remove this
/// Temporarily [ColorScheme.onSecondary] used for default text color
class NFButton extends StatelessWidget {
  const NFButton({
    Key? key,
    this.text,
    this.textStyle,
    this.color,
    this.splashColor,
    this.loading = false,
    this.onPressed,
    this.variant = kNFButtonVariant,
    this.padding = const EdgeInsets.symmetric(horizontal: 15.0),
    this.borderRadius = 15.0,
    this.materialTapTargetSize = MaterialTapTargetSize.shrinkWrap,
  })  : _flavour = null,
        super(key: key);

  /// Applies a specific flavour to button to restyle it later.
  /// Primarily needed to get localizations, because they require build context.
  NFButton._createFlavor({
    required _NFButtonFlavor flavour,
    Key? key,
    this.text,
    this.textStyle,
    this.color,
    this.splashColor,
    this.loading = false,
    this.onPressed,
    this.variant = kNFButtonVariant,
    this.padding = const EdgeInsets.symmetric(horizontal: 15.0),
    this.borderRadius = 15.0,
    this.materialTapTargetSize = MaterialTapTargetSize.shrinkWrap,
  })  : _flavour = flavour,
        super(key: key);

  /// Text to show inside button
  final String? text;
  final TextStyle? textStyle;
  final Color? color;
  final Color? splashColor;

  /// Loading shows loading inside button
  final bool loading;

  /// Control the appearance of the button.
  final NFButtonVariant variant;
  final EdgeInsetsGeometry padding;
  final double borderRadius;

  /// The returned value will be passed to [Navigator.maybePop()] method call
  final Function? onPressed;

  /// Applies additional specific style.
  final _NFButtonFlavor? _flavour;

  /// Specifies whether the button will have margins or not.
  final MaterialTapTargetSize materialTapTargetSize;
  factory NFButton.accept({
    Key? key,
    String? text,
    TextStyle? textStyle,
    Color? color,
    Color? splashColor,
    bool loading = false,
    Function? onPressed,
    NFButtonVariant variant = kNFButtonVariant,
    EdgeInsetsGeometry padding = const EdgeInsets.symmetric(horizontal: 15.0),
    double borderRadius = 15.0,
    MaterialTapTargetSize materialTapTargetSize = MaterialTapTargetSize.shrinkWrap,
  }) {
    return NFButton._createFlavor(
      flavour: _NFButtonFlavor.accept,
      key: key,
      text: text,
      textStyle: textStyle,
      color: color,
      splashColor: splashColor,
      loading: loading,
      onPressed: () {
        if (onPressed != null) {
          onPressed();
        }
        return true;
      },
      variant: variant,
      padding: padding,
      borderRadius: borderRadius,
      materialTapTargetSize: materialTapTargetSize,
    );
  }

  factory NFButton.cancel({
    Key? key,
    String? text,
    TextStyle? textStyle,
    Color? color,
    Color? splashColor,
    bool loading = false,
    Function? onPressed,
    NFButtonVariant variant = kNFButtonVariant,
    EdgeInsetsGeometry padding = const EdgeInsets.symmetric(horizontal: 15.0),
    double borderRadius = 15.0,
    MaterialTapTargetSize materialTapTargetSize = MaterialTapTargetSize.shrinkWrap,
  }) {
    return NFButton._createFlavor(
      flavour: _NFButtonFlavor.cancel,
      key: key,
      text: text,
      textStyle: textStyle,
      color: color,
      splashColor: splashColor,
      loading: loading,
      onPressed: () {
        if (onPressed != null) {
          onPressed();
        }
        return false;
      },
      variant: variant,
      padding: padding,
      borderRadius: borderRadius,
      materialTapTargetSize: materialTapTargetSize,
    );
  }
  factory NFButton.close({
    Key? key,
    String? text,
    TextStyle? textStyle,
    Color? color,
    Color? splashColor,
    bool loading = false,
    Function? onPressed,
    NFButtonVariant variant = kNFButtonVariant,
    EdgeInsetsGeometry padding = const EdgeInsets.symmetric(horizontal: 15.0),
    double borderRadius = 15.0,
    MaterialTapTargetSize materialTapTargetSize = MaterialTapTargetSize.shrinkWrap,
  }) {
    return NFButton._createFlavor(
      flavour: _NFButtonFlavor.close,
      key: key,
      text: text,
      textStyle: textStyle,
      color: color,
      splashColor: splashColor,
      loading: loading,
      onPressed: () {
        if (onPressed != null) {
          onPressed();
        }
        return false;
      },
      variant: variant,
      padding: padding,
      borderRadius: borderRadius,
      materialTapTargetSize: materialTapTargetSize,
    );
  }

  /// Returns localized button text based on the button flavour.
  String _getDefaultButtonText(BuildContext context) {
    final l10n = NFLocalizations.of(context);
    switch (_flavour) {
      case _NFButtonFlavor.accept:
        return l10n.accept;
      case _NFButtonFlavor.cancel:
        return l10n.cancel;
      case _NFButtonFlavor.close:
        return l10n.close;
      default:
        return '';
    }
  }

  Future<void> _handleOnPressed(BuildContext context) async {
    final res = await onPressed?.call();
    if (_flavour != null) {
      Navigator.of(context).maybePop(res);
    }
  }

  Widget _buildChild(BuildContext context) {
    final theme = Theme.of(context);
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      child: loading
          ? SizedBox(
              width: 25.0,
              height: 25.0,
              child: const CircularProgressIndicator(
                strokeWidth: 3.0,
                valueColor: AlwaysStoppedAnimation(Colors.white),
              ),
            )
          : Text(
              text ?? _getDefaultButtonText(context),
              style: TextStyle(
                color: variant == NFButtonVariant.raised
                    ? theme.colorScheme.onPrimary
                    : theme.colorScheme.onSecondary,
                fontWeight: FontWeight.w900,
              ).merge(textStyle),
            ),
    );
  }

  Widget _buildButton(BuildContext context) {
    final theme = Theme.of(context);
    switch (variant) {
      case NFButtonVariant.raised:
        return RaisedButton(
          color: color ?? theme.colorScheme.primary,
          splashColor: splashColor ?? Colors.black.withOpacity(0.18),
          highlightColor: Colors.transparent,
          onPressed: () => _handleOnPressed(context),
          padding: padding,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          materialTapTargetSize: materialTapTargetSize,
          child: _buildChild(context),
        );
      case NFButtonVariant.flat:
        return FlatButton(
          color: color ?? Colors.transparent,
          splashColor: splashColor ?? theme.splashColor,
          highlightColor: Colors.transparent,
          onPressed: () => _handleOnPressed(context),
          padding: padding,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          materialTapTargetSize: materialTapTargetSize,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            child: _buildChild(context),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        splashFactory: NFListTileInkRipple.splashFactory,
      ),
      child: _buildButton(context),
    );
  }
}

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

/// Creates an icon copy button, which, when preseed,
/// will copy [text] to clipboard.
class NFCopyButton extends StatelessWidget {
  const NFCopyButton({
    Key? key,
    this.text,
    this.size = 44.0,
  }) : super(key: key);

  /// Text that will be copied when button is pressed.
  final String? text;

  /// Button size.
  final double size;

  @override
  Widget build(BuildContext context) {
    final l10n = NFLocalizations.of(context);
    return NFIconButton(
      icon: const Icon(Icons.content_copy_rounded),
      size: size,
      onPressed: text == null
          ? null
          : () {
              Clipboard.setData(
                ClipboardData(text: text),
              );
              NFSnackbarController.showSnackbar(
                NFSnackbarEntry(
                  child: NFSnackbar(
                    title: Text(l10n.copied),
                    titlePadding: const EdgeInsets.only(left: 8.0),
                    leading: Icon(
                      Icons.content_copy_rounded,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                ),
              );
            },
    );
  }
}

/// An icon button, that can be toggled visually on and off with [enabled],
/// for example to repesent some logical state, like `on / off`.
/// 
/// Color changes will be implicitly animated.
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
  }) : super(key: key);

  /// An icon to use.
  final Widget icon;

  /// Callback that will be called on button press.
  ///
  /// If `null`, [disabledColor] is applied.
  final VoidCallback? onPressed;

  /// The duration used to animate color changes.
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
    final nftheme = NFTheme.of(context);
    final colorAnimation = ColorTween(
      begin: widget.inactiveColor ?? Theme.of(context).unselectedWidgetColor,
      end: widget.color ?? Theme.of(context).iconTheme.color,
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
        disabledColor: widget.disabledColor,
      ),
    );
  }
}
