/*---------------------------------------------------------------------------------------------
*  Copyright (c) nt4f04und. All rights reserved.
*  Licensed under the BSD-style license. See LICENSE in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nt4f04unds_widgets/nt4f04unds_widgets.dart';

enum NFSpinnerVariant {
  material,
  cupertino,
  adaptive,
}

/// What size and stroke spinner will have.
enum NFSpinnerSize {
  /// Creates a smaller variant of a spinner.
  small,

  /// Creates a larger variant of a spinner.
  large,

  /// Allows to specify custom spinner size and stroke.
  custom,
}

/// Just a regular spinner widget.
class NFSpinner extends StatelessWidget {
  /// Prefer using named constructors instead of this.
  const NFSpinner({
    Key? key,
    this.size = NFSpinnerSize.large,
    this.sizeValue = 30.0,
    this.strokeWidth = 4.0,
    this.radius = 10.0,
    this.animating = true,
    this.variant = NFSpinnerVariant.material,
    this.color,
  })  : assert(variant != null),
        super(key: key);

  /// Creates a material circular spinner.
  const NFSpinner.material({
    Key? key,
    this.size = NFSpinnerSize.large,
    this.sizeValue,
    this.strokeWidth,
    this.color,
  })  : assert(
          size != NFSpinnerSize.custom &&
          sizeValue == null &&
          strokeWidth == null ||
            size == NFSpinnerSize.custom &&
            sizeValue != null &&
            strokeWidth != null,
          'If you use NFSpinnerSize.custom or sizeValue or strokeWidth, you have to provide all of them together',
        ),
        radius = null,
        animating = null,
        variant = NFSpinnerVariant.material,
        super(key: key);

  /// Creates a cupertino activity indicator.
  const NFSpinner.cupertino({
    Key? key,
    this.radius = 10.0,
    this.animating = true,
  })  : size = null,
        sizeValue = null,
        strokeWidth = null,
        color = null,
        variant = NFSpinnerVariant.cupertino,
        super(key: key);

  /// Creates an adaptive circular spinner.
  ///
  /// On Android it will show [NFSpinnerVariant.material].
  /// On iOS it will show [NFSpinnerVariant.cupertino].
  const NFSpinner.adaptive({
    Key? key,
    this.size = NFSpinnerSize.large,
    this.sizeValue = 30.0,
    this.strokeWidth = 4.0,
    this.radius = 10.0,
    this.animating = true,
    this.color,
  })  : variant = NFSpinnerVariant.adaptive,
        super(key: key);

  /// Size variawnt to apply.
  /// Only for material spinner.
  final NFSpinnerSize? size;

  /// Actual size of the spinner.
  /// 
  /// Set [size] to [NFSpinnerSize.custom] to use this.
  /// 
  /// Only for material spinner.
  final double? sizeValue;

  /// Set [size] to [NFSpinnerSize.custom] to use this.
  /// 
  /// Only for material spinner.
  final double? strokeWidth;

  /// Only for cupertino spinner.
  final double? radius;

  /// Only for cupertino spinner.
  final bool? animating;

  /// What spinner to show.
  final NFSpinnerVariant variant;

  /// If not specified, the primary color will be used instead.
  final Color? color;

  Widget _material(context) {
    final theme = Theme.of(context);
    double _size;
    double _strokeWidth;
    if (size == NFSpinnerSize.small) {
      _size = pickSize(24.0, small: 18.0, tablet: 34.0);
      _strokeWidth = pickSize(3.0, small: 2.6, tablet: 5.0);
    } else if (size == NFSpinnerSize.large) {
      _size = pickSize(32.0, small: 28.0, tablet: 40.0);
      _strokeWidth = pickSize(4.0, small: 3.0, tablet: 5.0);
    } else {
      _size = sizeValue!;
      _strokeWidth = strokeWidth!;
    }
    return Center(
      child: SizedBox(
        width: _size,
        height: _size,
        child: CircularProgressIndicator(
          valueColor:
              AlwaysStoppedAnimation(color ?? theme.colorScheme.primary),
          strokeWidth: _strokeWidth,
        ),
      ),
    );
  }

  Widget get _cupertino => Center(
        child: CupertinoActivityIndicator(
          radius: radius!,
          animating: animating!,
        ),
      );

  @override
  Widget build(BuildContext context) {
    switch (variant) {
      case NFSpinnerVariant.material:
        return _material(context);
      case NFSpinnerVariant.cupertino:
        return _cupertino;
      case NFSpinnerVariant.adaptive:
        if (Platform.isAndroid) {
          return _material(context);
        }
        return _cupertino;
    }
  }
}
