/*---------------------------------------------------------------------------------------------
*  Copyright (c) nt4f04und. All rights reserved.
*  Licensed under the BSD-style license. See LICENSE in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import 'package:flutter/scheduler.dart';

/// Function to slow down duration by [timeDilation]
Duration dilate(Duration duration) {
  return duration * timeDilation;
}

/// The [TickerProvider] that will be alive for the whole life of the application.
class PersistentTickerProvider extends TickerProvider {
  Ticker? _ticker;
  Ticker? get ticker => _ticker;

  @override
  Ticker createTicker(TickerCallback onTick) {
    _ticker = Ticker(onTick);
    return _ticker!;
  }
}
