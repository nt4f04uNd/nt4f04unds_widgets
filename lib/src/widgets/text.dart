/*---------------------------------------------------------------------------------------------
*  Copyright (c) nt4f04und. All rights reserved.
*  Licensed under the BSD-style license. See LICENSE in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Will return a [TextSpan] that on tap will open a [url].
/// 
/// If no [style] was specified, the default will be applied with [ThemeData.primaryColor].
TextSpan textLink({
  required BuildContext context,
  required String text,
  required String url,
  TextStyle? style,
}) {
  return TextSpan(
    text: text,
    style: style ?? TextStyle(color: Theme.of(context).primaryColor),
    recognizer: TapGestureRecognizer()
      ..onTap = () {
        launch(url);
      },
  );
}
