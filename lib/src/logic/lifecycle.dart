import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class NFWidgetBindingHandler extends WidgetsBindingObserver {
  NFWidgetBindingHandler({
    this.onInactive,
    this.onPaused,
    this.onDetached,
    this.onResumed,
  });

  final AsyncCallback onInactive;
  final AsyncCallback onPaused;
  final AsyncCallback onDetached;
  final AsyncCallback onResumed;

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
}
