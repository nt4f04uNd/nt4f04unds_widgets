/*---------------------------------------------------------------------------------------------
*  Copyright (c) nt4f04und. All rights reserved.
*  Licensed under the BSD-style license. See LICENSE in the project root for license information.
*
*  Copyright (c) The Flutter Authors.
*  See ThirdPartyNotices.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Holds:
///
/// * Selection set of generic type T
/// * Parent general animation controller
/// * Int switcher to add it to value key and achieve by doing so proper list updates
///
/// Status listeners will notify about in selection state change.
///
/// Listeners will notify about add/remove selection events.
class NFSelectionController<T> extends Listenable
    with
        AnimationLocalListenersMixin,
        AnimationEagerListenerMixin,
        AnimationLocalStatusListenersMixin {
  NFSelectionController({
    @required this.animationController,
    Set<T> data,
  })  : data = data ?? {},
        assert(animationController != null) {
    animationController.addStatusListener((status) {
      switch (status) {
        case AnimationStatus.forward:
          _wasEverSelected = true;
          break;
        case AnimationStatus.completed:
          break;
        case AnimationStatus.reverse:
          break;
        case AnimationStatus.dismissed:
          this.data.clear();
          break;
      }
      super.notifyStatusListeners(status);
    });
  }
  final AnimationController animationController;
  final Set<T> data;
  bool _wasEverSelected = false;
  int _prevLength = 0;

  AnimationStatus get status => animationController.status;

  /// Returns true if controller was never in the in selection state.
  bool get wasEverSelected => _wasEverSelected;

  bool get inSelection =>
      status == AnimationStatus.forward || status == AnimationStatus.completed;

  bool get notInSelection =>
      status == AnimationStatus.reverse || status == AnimationStatus.dismissed;

  /// Returns true when current selection set length is greater or equal than the previous.
  ///
  /// Convenient for tab bar count animation updates, for example.
  bool get lengthIncreased => data.length >= _prevLength;

  /// Returns true when current selection set length is less than the previous.
  ///
  /// Convenient for tab bar count animation updates, for example.
  bool get lengthReduced => data.length < _prevLength;

  void _handleSetChange() {
    _prevLength = data.length;
  }

  /// Adds an item to selection set and also notifies click listeners, in case if selection status mustn't change
  void selectItem(T item) {
    if (notInSelection) {
      data.clear();
    }
    _handleSetChange();
    data.add(item);

    if (notInSelection && data.length > 0) {
      animationController.forward();
    } else if (data.length > 1) {
      notifyListeners();
    }
  }

  /// Removes an item to selection set and also notifies click listeners, in case if selection status mustn't change
  void unselectItem(T item) {
    _handleSetChange();
    notifyListeners();
    data.remove(item);

    if (inSelection && data.length == 0) {
      animationController.reverse();
    } else {
      notifyListeners();
    }
  }

  /// Clears the set and performs the unselect animation
  void close() {
    _handleSetChange();
    animationController.reverse();
  }

  @override
  void dispose() {
    super.dispose();
    animationController.dispose();
  }
}
