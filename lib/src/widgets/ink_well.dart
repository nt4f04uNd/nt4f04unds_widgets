/*---------------------------------------------------------------------------------------------
*  Copyright (c) nt4f04und. All rights reserved.
*  Licensed under the BSD-style license. See LICENSE in the project root for license information.
*--------------------------------------------------------------------------------------------*/

// todo: delete when i delete NFListTileInkRipple (when https://github.com/flutter/flutter/issues/73163 is resolved)

// @dart = 2.12

import 'package:flutter/material.dart';
import 'package:nt4f04unds_widgets/nt4f04unds_widgets.dart';


/// Will draw ink well with taking the splash color and splash factory from theme
class NFInkWell extends StatelessWidget {
  const NFInkWell({
    Key? key,
    this.child,
    this.borderRadius,
    this.splashColor,
    this.onTap,
  }) : super(key: key);
  final Widget? child;
  final BorderRadius? borderRadius;
  final Color? splashColor;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: child,
      splashColor: splashColor ?? Theme.of(context).splashColor,
      borderRadius: borderRadius,
      splashFactory: NFListTileInkRipple.splashFactory,
      onTap: onTap,
    );
  }
}
