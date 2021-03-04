/*---------------------------------------------------------------------------------------------
*  Copyright (c) nt4f04und. All rights reserved.
*  Licensed under the BSD-style license. See LICENSE in the project root for license information.
*--------------------------------------------------------------------------------------------*/

// todo: remove if this is resolved https://github.com/flutter/flutter/issues/76490

// @dart = 2.12

import 'package:flutter/cupertino.dart';

/// Doesn't have glow effect on overscroll.
class GlowlessScrollBehavior extends ScrollBehavior {
  const GlowlessScrollBehavior();
  @override
  Widget buildViewportChrome(BuildContext context, Widget child, AxisDirection axisDirection) {
    return child;
  }
}
