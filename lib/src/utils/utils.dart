/*---------------------------------------------------------------------------------------------
*  Copyright (c) nt4f04und. All rights reserved.
*  Licensed under the BSD-style license. See LICENSE in the project root for license information.
*--------------------------------------------------------------------------------------------*/

export 'duration.dart';
export 'switcher.dart';
export 'types.dart';

import 'package:flutter/scheduler.dart';

/// Function to slow down duration by [timeDilation]
Duration dilate(Duration duration) {
  return duration * timeDilation;
}