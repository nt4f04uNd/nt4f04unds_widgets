/*---------------------------------------------------------------------------------------------
*  Copyright (c) nt4f04und. All rights reserved.
*  Licensed under the BSD-style license. See LICENSE in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// A controller for a selection.
///
/// Holds:
///
/// * Selection [data] set
/// * Parent [animationController]
///
/// Status listeners will notify about selection state change.
///
/// Listeners will notify about add/remove selection events.
class SelectionController<T> extends Listenable
    with AnimationLocalListenersMixin, AnimationEagerListenerMixin, AnimationLocalStatusListenersMixin {
  /// Creates a [SelectionController].
  SelectionController({
    required AnimationController animationController,
    Set<T>? data,
    bool closeSelectionWhenEmpty = true,
  }) : _animationController = animationController,
       data = data ?? {},
       _closeSelectionWhenEmpty = closeSelectionWhenEmpty {
    animationController.addStatusListener(notifyStatusListeners);
  }

  /// Creates a [SelectionController] with immutable, always in selection state.
  SelectionController.alwaysInSelection({Set<T>? data})
    : _animationController = null,
      data = data ?? {},
      _closeSelectionWhenEmpty = false;

  /// An [Animation] associated with this selection controller.
  /// If [alwaysInSelection] is true, this will return [kAlwaysCompleteAnimation].
  Animation<double> get animation => _animationController?.view ?? kAlwaysCompleteAnimation;

  /// The [AnimationController] associated with this selection controller.
  AnimationController get animationController {
    if (kDebugMode) {
      debugAssertNotAlwaysInSelection();
    }
    return _animationController!;
  }

  AnimationController? _animationController;
  set animationController(AnimationController value) {
    if (kDebugMode) {
      debugAssertNotAlwaysInSelection();
    }
    if (!alwaysInSelection && value != _animationController) {
      _animationController!.removeStatusListener(notifyStatusListeners);
      _animationController = value;
      _animationController!.addStatusListener(notifyStatusListeners);
    }
  }

  /// The set of selected items.
  final Set<T> data;

  /// If this is true, when the [data] becomes empty, the controller will
  /// automatically close the selection.
  ///
  /// Changing this property will throw if [alwaysInSelection] is true.
  bool get closeSelectionWhenEmpty => _closeSelectionWhenEmpty;
  bool _closeSelectionWhenEmpty;
  set closeSelectionWhenEmpty(bool value) {
    if (kDebugMode) {
      debugAssertNotAlwaysInSelection();
    }
    _closeSelectionWhenEmpty = value;
  }

  /// Whether the selection controller was created with [SelectionController.alwaysInSelection],
  /// and is in selection state on its entire lifecycle.
  bool get alwaysInSelection => _animationController == null;

  /// Asserts [alwaysInSelection] is false.
  void debugAssertNotAlwaysInSelection() {
    assert(
      !alwaysInSelection,
      "This method cannot to be used when `alwaysInSelection` is true.\n"
      "Controller selection state is considered immutable",
    );
  }

  int _prevLength = 0;

  /// Selection status.
  AnimationStatus get status => _animationController?.status ?? AnimationStatus.completed;

  /// Returns true if controller was never in the in selection state.
  bool get wasEverSelected => _wasEverSelected;
  final bool _wasEverSelected = false;

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

  /// Adds an item to selection set and notifies click listeners.
  ///
  /// Returns a [TickerFuture] from the [AnimationController.forward].
  TickerFuture? selectItem(T item) {
    if (notInSelection) data.clear();
    _prevLength = data.length;
    data.add(item);
    notifyListeners();
    if (!alwaysInSelection) return _animationController!.forward();
    return null;
  }

  /// Removes an item to selection set and notifies click listeners.
  ///
  /// Returns a [TickerFuture] from the [AnimationController.reverse],
  /// which is triggered when the unselected item was last.
  TickerFuture? unselectItem(T item) {
    _prevLength = data.length;
    data.remove(item);
    notifyListeners();
    if (!alwaysInSelection && closeSelectionWhenEmpty && inSelection && data.isEmpty) {
      return _animationController!.reverse();
    }
    return null;
  }

  /// Adds item in selection, if item is already selected, unselects it.
  TickerFuture? toggleItem(T item) {
    if (data.contains(item)) return unselectItem(item);
    return selectItem(item);
  }

  /// Clears the set and performs the unselect animation.
  ///
  /// Returns a [TickerFuture] from the [AnimationController.reverse].
  TickerFuture? close() {
    clear();
    if (!alwaysInSelection) return _animationController!.reverse();
    return null;
  }

  /// Clears the set and notifies the listeners.
  void clear() {
    _prevLength = data.length;
    data.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    clearStatusListeners();
    clearListeners();
    _animationController?.dispose();
    super.dispose();
  }
}
