/*---------------------------------------------------------------------------------------------
*  Copyright (c) nt4f04und. All rights reserved.
*  Licensed under the BSD-style license. See LICENSE in the project root for license information.
*
*  Copyright (c) The Chromium Authors.
*  See ThirdPartyNotices.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import 'dart:math' show min;

import 'package:flutter/material.dart';
import 'package:nt4f04unds_widgets/nt4f04unds_widgets.dart';

/// A material design [IconButton] with a slightly adjusted default style.
class NFIconButton extends IconButton {
  /// Creates an icon button.
  const NFIconButton({
    super.key,
    super.iconSize = NFConstants.iconSize,
    super.visualDensity,
    super.padding = EdgeInsets.zero,
    super.alignment,
    super.splashRadius,
    super.color,
    super.focusColor,
    super.hoverColor,
    super.highlightColor,
    super.splashColor,
    super.disabledColor,
    required super.onPressed,
    super.onHover,
    super.onLongPress,
    super.mouseCursor,
    super.focusNode,
    super.autofocus = false,
    super.tooltip,
    super.enableFeedback,
    super.constraints = const BoxConstraints(
      minWidth: NFConstants.iconButtonSize,
      minHeight: NFConstants.iconButtonSize,
    ),
    super.style,
    super.isSelected,
    super.selectedIcon,
    super.statesController,
    required super.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        splashFactory: NFIconButtonInkRipple.splashFactory(
          radius: min(constraints!.minWidth, constraints!.minHeight) / 2,
        ),
      ),
      child: IconButton(
        key: key,
        iconSize: iconSize,
        visualDensity: visualDensity,
        padding: padding,
        alignment: alignment,
        splashRadius: splashRadius,
        color: color ?? IconTheme.of(context).color,
        focusColor: focusColor,
        hoverColor: hoverColor,
        highlightColor: highlightColor,
        splashColor: splashColor,
        disabledColor: disabledColor,
        onPressed: onPressed,
        onHover: onHover,
        onLongPress: onLongPress,
        mouseCursor: mouseCursor,
        focusNode: focusNode,
        autofocus: autofocus,
        tooltip: tooltip,
        enableFeedback: enableFeedback,
        constraints: constraints,
        style: style,
        isSelected: isSelected,
        selectedIcon: selectedIcon,
        statesController: statesController,
        icon: icon,
      ),
    );
  }
}
