/*---------------------------------------------------------------------------------------------
*  Copyright (c) nt4f04und. All rights reserved.
*  Licensed under the BSD-style license. See LICENSE in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class NFWidgetsBindingObserver extends WidgetsBindingObserver {
  NFWidgetsBindingObserver({
    this.onInactive,
    this.onPaused,
    this.onDetached,
    this.onResumed,
    this.onTextScaleFactorChanged,
    this.onChangeMetrics,
  });

  final AsyncCallback onInactive;
  final AsyncCallback onPaused;
  final AsyncCallback onDetached;
  final AsyncCallback onResumed;
  final VoidCallback onTextScaleFactorChanged;
  final VoidCallback onChangeMetrics;

  @override
  Future<Null> didChangeAppLifecycleState(AppLifecycleState state) async {
    switch (state) {
      case AppLifecycleState.inactive:
        if (onInactive != null) await onInactive();
        break;
      case AppLifecycleState.paused:
        if (onPaused != null) await onPaused();
        break;
      case AppLifecycleState.detached:
        if (onDetached != null) await onDetached();
        break;
      case AppLifecycleState.resumed:
        if (onResumed != null) await onResumed();
        break;
    }
  }

  @override
  void didChangeTextScaleFactor() {
    if (onTextScaleFactorChanged != null) {
      onTextScaleFactorChanged();
    }
  }

  @override
  void didChangeMetrics() {
    if (onChangeMetrics != null) {
      onChangeMetrics();
    }
  }
}
