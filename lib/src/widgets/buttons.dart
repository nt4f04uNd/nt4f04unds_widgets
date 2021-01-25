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

/// todo: Migrage to new buttons from flutter when they add splash customization
/// Temporarily [ColorScheme.onSecondary] used for default text color
class NFButton extends StatelessWidget {
  const NFButton({
    Key key,
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
    @required _NFButtonFlavor flavour,
    Key key,
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
  final String text;
  final TextStyle textStyle;
  final Color color;
  final Color splashColor;

  /// Loading shows loading inside button
  final bool loading;

  /// Control the appearance of the button.
  final NFButtonVariant variant;
  final EdgeInsets padding;
  final double borderRadius;

  /// The returned value will be passed to [Navigator.maybePop()] method call
  final Function onPressed;

  /// Applies additional specific style.
  final _NFButtonFlavor _flavour;

  /// Specifies whether the button will have margins or not.
  final MaterialTapTargetSize materialTapTargetSize;
  factory NFButton.accept({
    Key key,
    String text,
    TextStyle textStyle,
    Color color,
    Color splashColor,
    bool loading = false,
    Function onPressed,
    NFButtonVariant variant = kNFButtonVariant,
    EdgeInsetsGeometry padding = const EdgeInsets.symmetric(horizontal: 15.0),
    double borderRadius = 15.0,
    MaterialTapTargetSize materialTapTargetSize =
        MaterialTapTargetSize.shrinkWrap,
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
    Key key,
    String text,
    TextStyle textStyle,
    Color color,
    Color splashColor,
    bool loading = false,
    Function onPressed,
    NFButtonVariant variant = kNFButtonVariant,
    EdgeInsetsGeometry padding = const EdgeInsets.symmetric(horizontal: 15.0),
    double borderRadius = 15.0,
    MaterialTapTargetSize materialTapTargetSize =
        MaterialTapTargetSize.shrinkWrap,
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
    Key key,
    String text,
    TextStyle textStyle,
    Color color,
    Color splashColor,
    bool loading = false,
    Function onPressed,
    NFButtonVariant variant = kNFButtonVariant,
    EdgeInsetsGeometry padding = const EdgeInsets.symmetric(horizontal: 15.0),
    double borderRadius = 15.0,
    MaterialTapTargetSize materialTapTargetSize =
        MaterialTapTargetSize.shrinkWrap,
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
    if (onPressed != null) {
      final res = await onPressed();
      if (_flavour != null) {
        Navigator.of(context).maybePop(await onPressed());
      }
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
      default:
        assert(false);
        return null;
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

/// Button to go back from page
class NFBackButton extends StatelessWidget {
  const NFBackButton({
    Key key,
    this.icon,
    this.size = NFConstants.iconButtonSize,
    this.iconSize = NFConstants.iconSize,
    this.onPressed,
  }) : super(key: key);

  /// A custom icon for back button
  final IconData icon;
  final double size;
  final double iconSize;
  final Function onPressed;

  @override
  Widget build(BuildContext context) {
    return NFIconButton(
      icon: Icon(
        icon ?? Icons.arrow_back_rounded,
      ),
      size: size,
      iconSize: iconSize,
      onPressed: onPressed ?? () => Navigator.of(context).pop(),
    );
  }
}

class NFCopyButton extends StatelessWidget {
  const NFCopyButton({
    Key key,
    this.size = 44.0,
    @required this.text,
  }) : super(key: key);

  final double size;
  final String text;

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
              NFSnackbarControl.showSnackbar(
                NFSnackbarSettings(
                  child: NFSnackbar(
                    message: l10n.copied,
                    messagePadding: const EdgeInsets.only(left: 8.0),
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

/// An information button.
/// On click creates an alert with information
class NFInfoButton extends StatelessWidget {
  const NFInfoButton({
    Key key,
    this.size = 44.0,
    @required this.info,
    this.infoAlertTitle,
  }) : super(key: key);

  final double size;
  final String info;

  /// Text displayed as a title of an info window
  final String infoAlertTitle;

  @override
  Widget build(BuildContext context) {
    final l10n = NFLocalizations.of(context);
    return NFIconButton(
      icon: const Icon(Icons.info_outline_rounded),
      size: size,
      onPressed: info == null
          ? null
          : () {
              NFShowFunctions.instance.showAlert(
                context,
                title: Text(infoAlertTitle ?? l10n.whatDoesItMean),
                content: Text(info),
              );
            },
    );
  }
}

/// A default icon button, but that can be toggled on and off with [enabled],
/// and it's color will change with animation.
///
/// When [enabled] is `false`, [unselectedColor] will be applied.
///
/// Also, if [onPressed] was not specified, the [disabledColor] will be applied.
class NFAnimatedIconButton extends StatefulWidget {
  NFAnimatedIconButton({
    Key key,
    @required this.icon,
    @required this.onPressed,
    this.iconSize = NFConstants.iconSize,
    this.size = NFConstants.iconButtonSize,
    this.enabled = true,
    this.duration = NFConstants.colorAnimationDuration,
    this.color,
    this.unselectedColor,
    this.disabledColor,
  }) : super(key: key);
  final Widget icon;

  /// Button will have a disabled color if none was specified.
  final Function onPressed;
  final double iconSize;
  final double size;

  /// Can be used to set a disabled color for button, when `false`.
  /// This won't prevent taps on button, it's more like a state indicator of something.
  /// By default it is `true`.
  final bool enabled;
  final Duration duration;

  /// If none specified, theme icon color is used.
  final Color color;

  /// If none specified, [ThemeData.unselectedWidgetColor] color is used.
  final Color unselectedColor;

  /// If none specified, [ThemeData.disabledColor] color is used.
  final Color disabledColor;
  @override
  NFAnimatedIconButtonState createState() => NFAnimatedIconButtonState();
}

class NFAnimatedIconButtonState extends State<NFAnimatedIconButton>
    with SingleTickerProviderStateMixin {
  AnimationController controller;
  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    if (widget.enabled && widget.onPressed != null) {
      controller.value = 1.0;
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.enabled && widget.onPressed != null) {
      if (controller.status == AnimationStatus.dismissed ||
          controller.status == AnimationStatus.reverse) {
        controller.forward();
      }
    } else {
      if (controller.status == AnimationStatus.completed ||
          controller.status == AnimationStatus.forward) {
        controller.reverse();
      }
    }
    final colorAnimation = ColorTween(
      begin: widget.unselectedColor ?? Theme.of(context).unselectedWidgetColor,
      end: widget.color ?? Theme.of(context).iconTheme.color,
    ).animate(NFDefaultAnimation(parent: controller));
    return AnimatedBuilder(
      animation: controller,
      builder: (BuildContext context, Widget child) => NFIconButton(
        icon: widget.icon,
        iconSize: widget.iconSize,
        size: widget.size,
        color: colorAnimation.value,
        // Passing empty closure to prevent dimming that's done by default.
        onPressed: widget.onPressed,
        disabledColor: widget.disabledColor,
      ),
    );
  }
}
