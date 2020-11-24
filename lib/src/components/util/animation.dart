/*---------------------------------------------------------------------------------------------
*  Copyright (c) nt4f04und. All rights reserved.
*  Licensed under the BSD-style license. See LICENSE in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

/// Creates a usual for me curved animation which is:
///
/// Curve [Curves.easeOutCubic]
///
/// Reverse curve [Curves.easeInCubic]
class NFDefaultAnimation extends CurvedAnimation {
  NFDefaultAnimation({
    Curve curve = Curves.easeOutCubic,
    Curve reverseCurve = Curves.easeInCubic,
    @required Animation parent,
  }) : super(curve: curve, reverseCurve: reverseCurve, parent: parent);
}

/// The [TickerProvider] that will be alive for the whole life of the application.
class PersistentTickerProvider extends TickerProvider {
  Ticker _ticker;
  Ticker get ticker => _ticker;

  @override
  Ticker createTicker(TickerCallback onTick) {
    _ticker = Ticker(onTick);
    return _ticker;
  }
}
