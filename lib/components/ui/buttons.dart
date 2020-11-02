/*---------------------------------------------------------------------------------------------
*  Copyright (c) nt4f04und. All rights reserved.
*  Licensed under the BSD-style license. See LICENSE in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:nt4f04unds_widgets/constants.dart';
import 'package:nt4f04unds_widgets/nt4f04unds_widgets.dart';

/// Creates [Raised] with border radius, by default colored into main app color
class PrimaryRaisedButton extends StatelessWidget {
  const PrimaryRaisedButton({
    Key key,
    @required this.text,
    @required this.onPressed,
    this.loading = false,
    this.textStyle,
    this.materialTapTargetSize = MaterialTapTargetSize.shrinkWrap,
    this.color,
    this.borderRadius = 15.0,
    this.padding,
  });

  /// Text to show inside button
  final String text;
  final Function onPressed;

  /// Loading shows loading inside button
  final bool loading;

  /// Style applied to text
  final TextStyle textStyle;

  /// Specifies whether the button will have margins or not
  final MaterialTapTargetSize materialTapTargetSize;
  final Color color;
  final double borderRadius;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        splashFactory: ListTileInkRipple.splashFactory,
      ),
      child: RaisedButton(
        key: key,
        splashColor: Colors.black.withOpacity(0.18),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          child: loading
              ? SizedBox(
                  width: 25.0,
                  height: 25.0,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: const AlwaysStoppedAnimation(Colors.white),
                  ),
                )
              : Text(
                  text,
                  style: textStyle ??
                      TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary,
                        fontWeight: FontWeight.w900,
                      ),
                ),
        ),
        color: color ?? Theme.of(context).colorScheme.primary,
        onPressed: loading ? null : onPressed,
        materialTapTargetSize: materialTapTargetSize,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        padding: padding,
      ),
    );
  }
}

enum _DialogRaisedButtonFlavours { accept, cancel }

/// Possible appearance variants for [DialogButton].
enum DialogButtonVariant { raised, flat }

const kDefaultDialogButtonVariant = DialogButtonVariant.flat;

/// Creates button to use in dialogs.
class DialogButton extends StatelessWidget {
  const DialogButton({
    Key key,
    this.text,
    this.textStyle,
    this.color,
    this.variant = kDefaultDialogButtonVariant,
    this.padding = const EdgeInsets.symmetric(horizontal: 15.0),
    this.borderRadius = 15.0,
    this.onPressed,
  })  : _flavour = null,
        super(key: key);

  /// Applies a specific flavour to button to restyle it later.
  /// Primarily needed to get localizations, because they require build context.
  DialogButton._createFlavour({
    @required _DialogRaisedButtonFlavours flavour,
    Key key,
    this.text,
    this.textStyle,
    this.color,
    this.variant = kDefaultDialogButtonVariant,
    this.padding = const EdgeInsets.symmetric(horizontal: 15.0),
    this.borderRadius = 15.0,
    this.onPressed,
  })  : _flavour = flavour,
        super(key: key);

  /// Text to show inside button
  final String text;
  final TextStyle textStyle;
  final Color color;

  /// Control the appearance of the button.
  final DialogButtonVariant variant;
  final EdgeInsets padding;
  final double borderRadius;

  /// The returned value will be passed to [Navigator.maybePop()] method call
  final Function onPressed;

  /// Applies additional specific style.
  final _DialogRaisedButtonFlavours _flavour;

  /// Constructs an accept button.
  ///
  /// `true` will be always passed to [Navigator.maybePop()] call.
  factory DialogButton.accept({
    String text,
    Function onPressed,
    DialogButtonVariant variant = kDefaultDialogButtonVariant,
  }) {
    return DialogButton._createFlavour(
      text: text,
      variant: variant,
      flavour: _DialogRaisedButtonFlavours.accept,
      onPressed: () {
        if (onPressed != null) {
          onPressed();
        }
        return true;
      },
    );
  }

  /// Constructs a cancel button.
  ///
  /// `false` will be always passed to [Navigator.maybePop()] call.
  factory DialogButton.cancel({
    String text,
    Function onPressed,
    DialogButtonVariant variant = kDefaultDialogButtonVariant,
  }) {
    return DialogButton._createFlavour(
      text: text,
      variant: variant,
      flavour: _DialogRaisedButtonFlavours.cancel,
      color: const Color(0xfff1f2f4),
      textStyle: TextStyle(color: Colors.black),
      onPressed: () {
        if (onPressed != null) {
          onPressed();
        }
        return false;
      },
    );
  }

  /// Returns localized button text based on the button flavour.
  String _getDefaultButtonText(BuildContext context) {
    switch (_flavour) {
      case _DialogRaisedButtonFlavours.accept:
        return l10n.accept;
      case _DialogRaisedButtonFlavours.cancel:
        return l10n.cancel;
      default:
        return l10n.close;
    }
  }

  Future<void> _handleOnPressed(BuildContext context) async {
    var res;
    if (onPressed != null) {
      res = await onPressed();
    }
    Navigator.of(context).maybePop(res);
  }

  Widget _buildButton(BuildContext context) {
    switch (variant) {
      case DialogButtonVariant.raised:
        return RaisedButton(
          splashColor: Colors.black.withOpacity(0.18),
          child: Text(
            text ?? _getDefaultButtonText(context),
            style: textStyle ??
                TextStyle(color: Theme.of(context).colorScheme.onPrimary),
          ),
          color: color ?? Theme.of(context).colorScheme.primary,
          padding: padding,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          onPressed: () => _handleOnPressed(context),
        );
      case DialogButtonVariant.flat:
        return FlatButton(
          splashColor: Theme.of(context).splashColor,
          child: Text(
            text ?? _getDefaultButtonText(context),
            style: const TextStyle(fontWeight: FontWeight.w900),
          ),
          padding: padding,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          onPressed: () => _handleOnPressed(context),
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
        splashFactory: ListTileInkRipple.splashFactory,
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
    this.size = Constants.iconButtonSize,
    this.iconSize = Constants.iconSize,
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

class CopyButton extends StatelessWidget {
  const CopyButton({
    Key key,
    this.size = 44.0,
    @required this.text,
  }) : super(key: key);

  final double size;
  final String text;

  @override
  Widget build(BuildContext context) {
    return NFIconButton(
      icon: const Icon(Icons.content_copy_rounded),
      size: size,
      onPressed: text == null
          ? null
          : () {
              Clipboard.setData(
                ClipboardData(text: text),
              );
              SnackBarControl.showSnackBar(
                NFSnackbarSettings(
                  child: NFSnackBar(
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
class InfoButton extends StatelessWidget {
  const InfoButton({
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
    return NFIconButton(
      icon: const Icon(Icons.info_outline_rounded),
      size: size,
      onPressed: info == null
          ? null
          : () {
              ShowFunctions.showAlert(
                context,
                title: Text(infoAlertTitle ?? l10n.whatDoesItMean),
                content: Text(info),
              );
            },
    );
  }
}
