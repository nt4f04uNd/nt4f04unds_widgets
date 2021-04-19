/*---------------------------------------------------------------------------------------------
*  Copyright (c) nt4f04und. All rights reserved.
*  Licensed under the BSD-style license. See LICENSE in the project root for license information.
*
*  Copyright (c) The Flutter Authors.
*  See ThirdPartyNotices.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import 'package:flutter/material.dart';

/// TODO: remove this when https://github.com/flutter/flutter/issues/80323 is fixed
///
/// A convenience widget that registers a callback for when the back button is pressed.
///
/// In order to use this widget, there must be an ancestor [Router] widget in the tree
/// that has a [RootBackButtonDispatcher]. e.g. The [Router] widget created by the
/// [MaterialApp.router] has a built-in [RootBackButtonDispatcher] by default.
///
/// It only applies to platforms that accept back button clicks, such as Android.
///
/// It can be useful for scenarios, in which you create a different state in your
/// screen but don't want to use a new page for that.
class NFBackButtonListener extends StatefulWidget {
  /// Creates a BackButtonListener widget .
  ///
  /// The [child] and [onBackButtonPressed] arguments must not be null.
  const NFBackButtonListener({
    Key? key,
    required this.child,
    required this.onBackButtonPressed,
  }) : super(key: key);

  /// The widget below this widget in the tree.
  final Widget child;

  /// The callback function that will be called when the back button is pressed.
  ///
  /// It must return a boolean future with true if this child will handle the request;
  /// otherwise, return a boolean future with false.
  final ValueGetter<Future<bool>> onBackButtonPressed;

  @override
  _BackButtonListenerState createState() => _BackButtonListenerState();
}

class _BackButtonListenerState extends State<NFBackButtonListener> {
  BackButtonDispatcher? dispatcher;

  @override
  void didChangeDependencies() {
    dispatcher?.removeCallback(widget.onBackButtonPressed);

    final BackButtonDispatcher? rootBackDispatcher = Router.of(context).backButtonDispatcher;
    assert(rootBackDispatcher != null, 'The parent router must have a backButtonDispatcher to use this widget');

    dispatcher = rootBackDispatcher!.createChildBackButtonDispatcher()
      ..addCallback(widget.onBackButtonPressed)
      ..takePriority();
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    dispatcher?.removeCallback(widget.onBackButtonPressed);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}