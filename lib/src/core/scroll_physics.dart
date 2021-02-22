/*---------------------------------------------------------------------------------------------
*  Copyright (c) nt4f04und. All rights reserved.
*  Licensed under the BSD-style license. See LICENSE in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import 'package:flutter/cupertino.dart';

/// Doesn't have glow effect on overscroll.
/// 
/// todo: remove if this is merged https://github.com/flutter/flutter/pull/76494
class GlowlessScrollBehavior extends ScrollBehavior {
  const GlowlessScrollBehavior();
  @override
  Widget buildViewportChrome(BuildContext context, Widget child, AxisDirection axisDirection) {
    return child;
  }
}
