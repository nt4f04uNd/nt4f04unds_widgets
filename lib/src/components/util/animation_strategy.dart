/*---------------------------------------------------------------------------------------------
*  Copyright (c) nt4f04und. All rights reserved.
*  Licensed under the BSD-style license. See LICENSE in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import 'package:flutter/animation.dart';
import 'package:flutter/material.dart';

/// An interface for other animation strategies. You can imagine that this class sort of
/// tells someone what to do when depending on the current animation status.
abstract class AnimationStrategy<T> implements MovingAnimationStrategy<T> {
  const AnimationStrategy({
    this.dismissed,
    this.completed,
    this.forward,
    this.reverse,
  }) : super();
  final T dismissed;
  final T completed;
  final T forward;
  final T reverse;

  /// Asks for an "answer" what to do based on current status.
  // ignore: missing_return
  T ask(AnimationStatus status) {
    assert(status != null);
    switch (status) {
      case AnimationStatus.completed:
        return completed;
      case AnimationStatus.forward:
        return forward;
      case AnimationStatus.dismissed:
        return dismissed;
      case AnimationStatus.reverse:
        return reverse;
    }
  }
}

/// An interface for other animation strategies. You can imagine that this class sort of
/// tells someone what to do when animation status is either [AnimationStatus.forward], or [AnimationStatus.reverse].
abstract class MovingAnimationStrategy<T> {
  const MovingAnimationStrategy({this.forward, this.reverse});
  final T forward;
  final T reverse;

  /// Asks for an "answer" what to do based on current status.
  ///
  /// Will return null if the status is not moving, which is
  /// [AnimationStatus.dismissed], or [AnimationStatus.completed].
  T ask(AnimationStatus status) {
    switch (status) {
      case AnimationStatus.forward:
        return forward;
      case AnimationStatus.reverse:
        return reverse;
      default:
        return null;
    }
  }
}

/// Describes when the [HitTestBehavior] should be applied, depending on [AnimationStatus].
class HitTestBehaviorStrategy implements AnimationStrategy<HitTestBehavior> {
  const HitTestBehaviorStrategy({
    this.dismissed = HitTestBehavior.deferToChild,
    this.forward = HitTestBehavior.deferToChild,
    this.reverse = HitTestBehavior.deferToChild,
    this.completed = HitTestBehavior.deferToChild,
  })  : assert(dismissed != null),
        assert(forward != null),
        assert(reverse != null),
        assert(completed != null);

  const HitTestBehaviorStrategy.translucent({
    this.dismissed = HitTestBehavior.translucent,
    this.forward = HitTestBehavior.translucent,
    this.reverse = HitTestBehavior.translucent,
    this.completed = HitTestBehavior.translucent,
  })  : assert(dismissed != null),
        assert(forward != null),
        assert(reverse != null),
        assert(completed != null);

  const HitTestBehaviorStrategy.opaque({
    this.dismissed = HitTestBehavior.opaque,
    this.forward = HitTestBehavior.opaque,
    this.reverse = HitTestBehavior.opaque,
    this.completed = HitTestBehavior.opaque,
  })  : assert(dismissed != null),
        assert(forward != null),
        assert(reverse != null),
        assert(completed != null);

  /// What [HitTestBehavior] to apply when [AnimationStatus.dismissed].
  @override
  final HitTestBehavior dismissed;

  /// What [HitTestBehavior] to apply when [AnimationStatus.forward].
  @override
  final HitTestBehavior forward;

  /// What [HitTestBehavior] to apply when [AnimationStatus.reverse].
  @override
  final HitTestBehavior reverse;

  /// What [HitTestBehavior] to apply when [AnimationStatus.completed].
  @override
  final HitTestBehavior completed;

  /// Asks for an "answer" what to do based on current status.
  // ignore: missing_return
  HitTestBehavior ask(AnimationStatus status) {
    assert(status != null);
    switch (status) {
      case AnimationStatus.completed:
        return completed;
      case AnimationStatus.forward:
        return forward;
      case AnimationStatus.dismissed:
        return dismissed;
      case AnimationStatus.reverse:
        return reverse;
    }
  }
}

/// Describes when the [IgnoringPointer] should be applied, depending on [AnimationStatus].
class IgnoringStrategy implements AnimationStrategy<bool> {
  const IgnoringStrategy({
    this.dismissed = false,
    this.forward = false,
    this.reverse = false,
    this.completed = false,
  })  : assert(dismissed != null),
        assert(forward != null),
        assert(reverse != null),
        assert(completed != null);

  /// Ignore in any [AnimationStatus].
  const IgnoringStrategy.all()
      : dismissed = true,
        forward = true,
        reverse = true,
        completed = true;

  /// Whether to ignore when [AnimationStatus.dismissed].
  @override
  final bool dismissed;

  /// Whether to ignore when [AnimationStatus.forward].
  @override
  final bool forward;

  /// Whether to ignore when [AnimationStatus.reverse].
  @override
  final bool reverse;

  /// Whether to ignore when [AnimationStatus.completed].
  @override
  final bool completed;

  /// Asks for an "answer" what to do based on current status.
  // ignore: missing_return
  bool ask(AnimationStatus status) {
    assert(status != null);
    switch (status) {
      case AnimationStatus.completed:
        return completed;
      case AnimationStatus.forward:
        return forward;
      case AnimationStatus.dismissed:
        return dismissed;
      case AnimationStatus.reverse:
        return reverse;
    }
  }

  /// Will evaluate to a single bool condition.
  bool evaluate(AnimationStatus status) {
    return dismissed && status == AnimationStatus.dismissed ||
        forward && status == AnimationStatus.forward ||
        reverse && status == AnimationStatus.reverse ||
        completed && status == AnimationStatus.completed;
  }
}

/// Describes when the [IgnoringPointer] should be applied, if animation is moving.
///
/// See also:
/// * [IgnoringStrategy] to also respect dismissed and completed animation statues
class MovingIgnoringStrategy implements MovingAnimationStrategy<bool> {
  const MovingIgnoringStrategy({
    this.forward = false,
    this.reverse = false,
  })  : assert(forward != null),
        assert(reverse != null);

  /// Ignore in any [AnimationStatus].
  const MovingIgnoringStrategy.all()
      : forward = true,
        reverse = true;

  /// Whether to ignore when [AnimationStatus.forward].
  @override
  final bool forward;

  /// Whether to ignore when [AnimationStatus.reverse].
  @override
  final bool reverse;

  /// Asks for an "answer" what to do based on current status.
  // ignore: missing_return
  bool ask(AnimationStatus status) {
    switch (status) {
      case AnimationStatus.forward:
        return forward;
      case AnimationStatus.reverse:
        return reverse;
      default:
        return null;
    }
  }

  /// Will evaluate to a single bool condition.
  bool evaluate(AnimationStatus status) {
    return forward && status == AnimationStatus.forward ||
        reverse && status == AnimationStatus.reverse;
  }
}
