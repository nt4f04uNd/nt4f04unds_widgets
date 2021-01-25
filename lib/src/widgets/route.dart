/*---------------------------------------------------------------------------------------------
*  Copyright (c) nt4f04und. All rights reserved.
*  Licensed under the BSD-style license. See LICENSE in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import 'package:flutter/material.dart';
import 'package:nt4f04unds_widgets/nt4f04unds_widgets.dart';

const double kNFAppBarPreferredSize = 52.0;

/// Creates [Scaffold] with preferred size [AppBar]
class NFPageBase extends StatelessWidget {
  const NFPageBase({
    Key key,
    @required this.child,
    this.name = '',
    this.backgroundColor,
    this.appBarBackgroundColor,
    this.enableElevation = true,
    this.actions = const [],
    this.backButton = const NFBackButton(),
    this.resizeToAvoidBottomInset,
  })  : assert(child != null),
        super(key: key);

  /// Text that will be displayed in app bar title
  final String name;
  final Widget child;
  final Color backgroundColor;
  final bool resizeToAvoidBottomInset;
  final Color appBarBackgroundColor;
  final bool enableElevation;
  final List<Widget> actions;
  final Widget backButton;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      backgroundColor: backgroundColor,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      appBar: NFAppBar(
        title: name,
        actions: actions,
        leading: backButton,
        backgroundColor: appBarBackgroundColor,
        elevation: enableElevation ? 2.0 : 0.0,
      ),
    );
  }
}

class NFAppBar extends StatelessWidget implements PreferredSizeWidget {
  const NFAppBar({
    Key key,
    this.preferredHeight,
    this.leading,
    this.title,
    this.actions,
    this.elevation = 2.0,
    this.backgroundColor,
  }) : super(key: key);

  final double preferredHeight;
  final Widget leading;
  final String title;
  final List<Widget> actions;
  final double elevation;
  final Color backgroundColor;

  @override
  Size get preferredSize => Size.fromHeight(
        preferredHeight ?? kNFAppBarPreferredSize,
      );

  @override
  Widget build(BuildContext context) {
    return PreferredSize(
      preferredSize: preferredSize,
      child: AppBar(
        elevation: elevation,
        titleSpacing: 0.0,
        automaticallyImplyLeading: false,
        backgroundColor: backgroundColor,
        leading: leading ?? const NFBackButton(),
        actions: actions,
        title: Text(
          title,
          style: Theme.of(context).appBarTheme.textTheme.headline6.copyWith(
                fontSize: 21.0,
              ),
        ),
      ),
    );
  }
}
