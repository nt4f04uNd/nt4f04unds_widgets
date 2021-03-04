/*---------------------------------------------------------------------------------------------
*  Copyright (c) nt4f04und. All rights reserved.
*  Licensed under the BSD-style license. See LICENSE in the project root for license information.
*
*  Copyright (c) The Chromium Authors.
*  See ThirdPartyNotices.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

// todo: propose changes to the icon button in the framework and delete this. blocked by splash fidelity issue https://github.com/flutter/flutter/issues/73163

// @dart = 2.12

import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:nt4f04unds_widgets/src/constants.dart';
import 'package:nt4f04unds_widgets/nt4f04unds_widgets.dart';

/// A material design icon button.
///
/// An icon button is a picture printed on a [Material] widget that reacts to
/// touches by filling with color (ink).
///
/// Icon buttons are commonly used in the [AppBar.actions] field, but they can
/// be used in many other places as well.
///
/// If the [onPressed] callback is null, then the button will be disabled and
/// will not react to touch.
///
/// Requires one of its ancestors to be a [Material] widget.
///
/// The hit region of an icon button will, if possible, be at least
/// kMinInteractiveDimension pixels in size, regardless of the actual
/// [iconSize], to satisfy the [touch target size](https://material.io/guidelines/layout/metrics-keylines.html#metrics-keylines-touch-target-size)
/// requirements in the Material Design specification. The [alignment] controls
/// how the icon itself is positioned within the hit region.
///
/// {@tool snippet --template=stateful_widget_scaffold_center}
///
/// This sample shows an [IconButton] that uses the Material icon "volume_up" to
/// increase the volume.
///
/// ![](https://flutter.github.io/assets-for-api-docs/assets/material/icon_button.png)
///
/// ```dart preamble
/// double _volume = 0.0;
/// ```
///
/// ```dart
/// Widget build(BuildContext context) {
///   return Column(
///     mainAxisSize: MainAxisSize.min,
///     children: <Widget>[
///       IconButton(
///         icon: Icon(Icons.volume_up),
///         tooltip: 'Increase volume by 10',
///         onPressed: () {
///           setState(() {
///             _volume += 10;
///           });
///         },
///       ),
///       Text('Volume : $_volume')
///     ],
///   );
/// }
/// ```
/// {@end-tool}
///
/// ### Adding a filled background
///
/// Icon buttons don't support specifying a background color or other
/// background decoration because typically the icon is just displayed
/// on top of the parent widget's background. Icon buttons that appear
/// in [AppBar.actions] are an example of this.
///
/// It's easy enough to create an icon button with a filled background
/// using the [Ink] widget. The [Ink] widget renders a decoration on
/// the underlying [Material] along with the splash and highlight
/// [InkResponse] contributed by descendant widgets.
///
/// {@tool snippet --template=stateless_widget_scaffold}
///
/// In this sample the icon button's background color is defined with an [Ink]
/// widget whose child is an [IconButton]. The icon button's filled background
/// is a light shade of blue, it's a filled circle, and it's as big as the
/// button is.
///
/// ![](https://flutter.github.io/assets-for-api-docs/assets/material/icon_button_background.png)
///
/// ```dart
/// Widget build(BuildContext context) {
///   return Material(
///     color: Colors.white,
///     child: Center(
///       child: Ink(
///         decoration: const ShapeDecoration(
///           color: Colors.lightBlue,
///           shape: CircleBorder(),
///         ),
///         child: IconButton(
///           icon: Icon(Icons.android),
///           color: Colors.white,
///           onPressed: () {},
///         ),
///       ),
///     ),
///   );
/// }
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [Icons], a library of predefined icons.
///  * [BackButton], an icon button for a "back" affordance which adapts to the
///    current platform's conventions.
///  * [CloseButton], an icon button for closing pages.
///  * [AppBar], to show a toolbar at the top of an application.
///  * [RaisedButton] and [FlatButton], for buttons with text in them.
///  * [InkResponse] and [InkWell], for the ink splash effect itself.
class NFIconButton extends StatelessWidget {
  /// Creates an icon button.
  ///
  /// Icon buttons are commonly used in the [AppBar.actions] field, but they can
  /// be used in many other places as well.
  ///
  /// Requires one of its ancestors to be a [Material] widget.
  ///
  /// The [iconSize], [padding], [autofocus], and [alignment] arguments must not
  /// be null (though they each have default values).
  ///
  /// The [icon] argument must be specified, and is typically either an [Icon]
  /// or an [ImageIcon].
  const NFIconButton({
    Key? key,
    required this.icon,
    this.size = NFConstants.iconButtonSize,
    this.iconSize = NFConstants.iconSize,
    this.color,
    this.focusColor,
    this.hoverColor,
    this.highlightColor,
    this.splashColor,
    this.disabledColor,
    required this.onPressed,
    this.focusNode,
    this.autofocus = false,
    this.tooltip,
    this.enableFeedback = true,
  })  : assert(iconSize != null),
        assert(autofocus != null),
        assert(icon != null),
        super(key: key);

  /// The size of the icon inside the button.
  ///
  /// This property must not be null. It defaults to 24.0.
  ///
  /// The size given here is passed down to the widget in the [icon] property
  /// via an [IconTheme]. Setting the size here instead of in, for example, the
  /// [Icon.size] property allows the [IconButton] to size the splash area to
  /// fit the [Icon]. If you were to set the size of the [Icon] using
  /// [Icon.size] instead, then the [IconButton] would default to 24.0 and then
  /// the [Icon] itself would likely get clipped.
  final double iconSize;

  /// Button size itself
  final double size;

  /// The icon to display inside the button.
  ///
  /// The [Icon.size] and [Icon.color] of the icon is configured automatically
  /// based on the [iconSize] and [color] properties of _this_ widget using an
  /// [IconTheme] and therefore should not be explicitly given in the icon
  /// widget.
  ///
  /// This property must not be null.
  ///
  /// See [Icon], [ImageIcon].
  final Widget icon;

  /// The color for the button's icon when it has the input focus.
  ///
  /// Defaults to [ThemeData.focusColor] of the ambient theme.
  final Color? focusColor;

  /// The color for the button's icon when a pointer is hovering over it.
  ///
  /// Defaults to [ThemeData.hoverColor] of the ambient theme.
  final Color? hoverColor;

  /// The color to use for the icon inside the button, if the icon is enabled.
  /// Defaults to leaving this up to the [icon] widget.
  ///
  /// The icon is enabled if [onPressed] is not null.
  ///
  /// See also [disabledColor].
  ///
  /// ```dart
  /// IconButton(
  ///   color: Colors.blue,
  ///   onPressed: _handleTap,
  ///   icon: Icons.widgets,
  /// )
  /// ```
  final Color? color;

  /// The primary color of the button when the button is in the down (pressed) state.
  /// The splash is represented as a circular overlay that appears above the
  /// [highlightColor] overlay. The splash overlay has a center point that matches
  /// the hit point of the user touch event. The splash overlay will expand to
  /// fill the button area if the touch is held for long enough time. If the splash
  /// color has transparency then the highlight and button color will show through.
  ///
  /// Defaults to the Theme's splash color, [ThemeData.splashColor].
  final Color? splashColor;

  /// The secondary color of the button when the button is in the down (pressed)
  /// state. The highlight color is represented as a solid color that is overlaid over the
  /// button color (if any). If the highlight color has transparency, the button color
  /// will show through. The highlight fades in quickly as the button is held down.
  ///
  /// Defaults to the Theme's highlight color, [ThemeData.highlightColor].
  final Color? highlightColor;

  /// The color to use for the icon inside the button, if the icon is disabled.
  /// Defaults to the [ThemeData.disabledColor] of the current [Theme].
  ///
  /// The icon is disabled if [onPressed] is null.
  ///
  /// See also [color].
  final Color? disabledColor;

  /// The callback that is called when the button is tapped or otherwise activated.
  ///
  /// If this is set to null, the button will be disabled.
  final VoidCallback? onPressed;

  /// {@macro flutter.widgets.Focus.focusNode}
  final FocusNode? focusNode;

  /// {@macro flutter.widgets.Focus.autofocus}
  final bool autofocus;

  /// Text that describes the action that will occur when the button is pressed.
  ///
  /// This text is displayed when the user long-presses on the button and is
  /// used for accessibility.
  final String? tooltip;

  /// Whether detected gestures should provide acoustic and/or haptic feedback.
  ///
  /// For example, on Android a tap will produce a clicking sound and a
  /// long-press will produce a short vibration, when feedback is enabled.
  ///
  /// See also:
  ///
  ///  * [Feedback] for providing platform-specific feedback to certain actions.
  final bool enableFeedback;

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasMaterial(context));
    Color currentColor;
    if (onPressed != null)
      currentColor = color ?? Theme.of(context).iconTheme.color!;
    else
      currentColor = disabledColor ?? Theme.of(context).disabledColor;

    Widget result = Align(
      // NOTE that align needed for container constraints get to work
      alignment: Alignment.center,
      child: Container(
        height: iconSize,
        width: iconSize,
        child: IconTheme.merge(
          data: IconThemeData(
            size: iconSize,
            color: currentColor,
          ),
          child: icon,
        ),
      ),
    );

    if (tooltip != null) {
      result = Tooltip(
        message: tooltip!,
        child: result,
      );
    }

    /// Max size of [size] and [iconSize]
    final maxSize = math.max(size, iconSize);

    return Semantics(
      button: true,
      enabled: onPressed != null,
      child: Align(
        // NOTE that align needed for container constraints get to work
        alignment: Alignment.center,
        child: Container(
          width: maxSize,
          height: maxSize,
          child: InkWell(
            splashFactory: NFIconButtonInkRipple.splashFactory(radius: size / 2),
            focusNode: focusNode,
            autofocus: autofocus,
            canRequestFocus: onPressed != null,
            onTap: onPressed,
            enableFeedback: enableFeedback,
            child: result,
            focusColor: focusColor ?? Theme.of(context).focusColor,
            hoverColor: hoverColor ?? Theme.of(context).hoverColor,
            highlightColor: highlightColor ?? Colors.transparent,
            splashColor: splashColor ?? Theme.of(context).splashColor,
            // radius: maxSize / 2,
            customBorder: CircleBorder(side: BorderSide(width: 0)),
          ),
        ),
      ),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<Widget>('icon', icon, showName: false));
    properties.add(
        StringProperty('tooltip', tooltip, defaultValue: null, quoted: false));
    properties.add(ObjectFlagProperty<VoidCallback>('onPressed', onPressed,
        ifNull: 'disabled'));
    properties.add(ColorProperty('color', color, defaultValue: null));
    properties
        .add(ColorProperty('disabledColor', disabledColor, defaultValue: null));
    properties.add(ColorProperty('focusColor', focusColor, defaultValue: null));
    properties.add(ColorProperty('hoverColor', hoverColor, defaultValue: null));
    properties.add(
        ColorProperty('highlightColor', highlightColor, defaultValue: null));
    properties
        .add(ColorProperty('splashColor', splashColor, defaultValue: null));
    properties.add(DiagnosticsProperty<FocusNode>('focusNode', focusNode,
        defaultValue: null));
  }
}
