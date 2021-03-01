/*---------------------------------------------------------------------------------------------
*  Copyright (c) nt4f04und. All rights reserved.
*  Licensed under the BSD-style license. See LICENSE in the project root for license information.
*--------------------------------------------------------------------------------------------*/

// @dart = 2.12

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// A controller for a selection.
///
/// Holds:
///
/// * Parent [animationController]
/// * Selection [data] set
///
/// Status listeners will notify about selection state change.
///
/// Listeners will notify about add/remove selection events.
class SelectionController<T> extends Listenable
    with AnimationLocalListenersMixin,
        AnimationEagerListenerMixin,
        AnimationLocalStatusListenersMixin {
  
  /// Creates the [SelectionController].
  SelectionController({
    required AnimationController animationController,
    Set<T>? data,
  }) : _animationController = animationController,
       data = data ?? {},
       assert(animationController != null) {
    animationController.addStatusListener(_handleStatusChange);
  }

  void _handleStatusChange(AnimationStatus status) {
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
  }

  AnimationController _animationController;
  /// The [AnimationController] associated with this selection controller.
  AnimationController get animationController => _animationController;
  set animationController(AnimationController value) {
    if (value != _animationController) {
      _animationController.removeStatusListener(_handleStatusChange);
      _animationController = value;
      _animationController.addStatusListener(_handleStatusChange);
    }
  }

  final Set<T> data;
  bool _wasEverSelected = false;
  int _prevLength = 0;

  AnimationStatus get status => animationController.status;

  /// Returns true if controller was never in the in selection state.
  bool get wasEverSelected => _wasEverSelected;

  /// True when controller goes into selection or already in it.
  /// 
  /// For UI this means that any selection controls should be available for touches.
  bool get inSelection => status == AnimationStatus.forward || status == AnimationStatus.completed;

  /// True when controller goes out of selection or already in it.
  /// 
  /// For UI this means that any selection controls should be ignored for touches.
  bool get notInSelection => status == AnimationStatus.reverse || status == AnimationStatus.dismissed;

  /// Returns true when current selection set length is greater or equal than the previous.
  /// 
  /// Convenient for tab bar count animation updates, for example.
  bool get lengthIncreased => data.length >= _prevLength;

  /// Returns true when current selection set length is less than the previous.
  ///
  /// Convenient for tab bar count animation updates, for example.
  bool get lengthReduced => data.length < _prevLength;

  /// Adds an item to selection set and notifies click listeners
  /// (latter only in case if selection status won't change).
  void selectItem(T item) {
    if (notInSelection) {
      data.clear();
    }
    _prevLength = data.length;
    data.add(item);

    if (notInSelection && data.length > 0) {
      animationController.forward();
    } else if (data.length > 1) {
      notifyListeners();
    }
  }

  /// Removes an item to selection set and notifies click listeners
  /// (latter only in case if selection status won't change).
  void unselectItem(T item) {
    _prevLength = data.length;
    notifyListeners();
    data.remove(item);

    if (inSelection && data.length == 0) {
      animationController.reverse();
    } else {
      notifyListeners();
    }
  }

  /// Clears the set and performs the unselect animation.
  void close() {
    _prevLength = data.length;
    animationController.reverse();
  }

  @override
  void dispose() {
    super.dispose();
    animationController.dispose();
  }
}
