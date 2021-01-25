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
  })  : assert(dismissed != null),
        assert(forward != null),
        assert(reverse != null),
        assert(completed != null);

  final T dismissed;
  final T completed;
  final T forward;
  final T reverse;

  /// Asks for an "answer" what to do based on current status.
  T ask(Animation animation) {
    return askStatus(animation.status);
  }

  /// Asks for an "answer" what to do based on current status.
  T askStatus(AnimationStatus status) {
    switch (status) {
      case AnimationStatus.completed:
        return completed;
      case AnimationStatus.forward:
        return forward;
      case AnimationStatus.dismissed:
        return dismissed;
      case AnimationStatus.reverse:
        return reverse;
      default:
        assert(status != null);
        return null;
    }
  }
}

/// An interface for other animation strategies. You can imagine that this class sort of
/// tells someone what to do when animation status is either [AnimationStatus.forward], or [AnimationStatus.reverse].
abstract class MovingAnimationStrategy<T> {
  const MovingAnimationStrategy({
    this.forward,
    this.reverse,
  })  : assert(forward != null),
        assert(reverse != null);

  final T forward;
  final T reverse;

  /// Asks for an "answer" what to do based on current [animation] status.
  ///
  /// Will return null if the status is not moving, which is
  /// [AnimationStatus.dismissed], or [AnimationStatus.completed].
  T ask(Animation animation) {
    return askStatus(animation.status);
  }

  /// Asks for an "answer" what to do based on current [status].
  ///
  /// Will return null if the status is not moving, which is
  /// [AnimationStatus.dismissed], or [AnimationStatus.completed].
  T askStatus(AnimationStatus status) {
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
class HitTestBehaviorStrategy extends AnimationStrategy<HitTestBehavior> {
  const HitTestBehaviorStrategy({
    HitTestBehavior dismissed = HitTestBehavior.deferToChild,
    HitTestBehavior forward = HitTestBehavior.deferToChild,
    HitTestBehavior reverse = HitTestBehavior.deferToChild,
    HitTestBehavior completed = HitTestBehavior.deferToChild,
  }) : super(
          dismissed: dismissed,
          forward: forward,
          reverse: reverse,
          completed: completed,
        );

  const HitTestBehaviorStrategy.translucent({
    HitTestBehavior dismissed = HitTestBehavior.translucent,
    HitTestBehavior forward = HitTestBehavior.translucent,
    HitTestBehavior reverse = HitTestBehavior.translucent,
    HitTestBehavior completed = HitTestBehavior.translucent,
  }) : super(
          dismissed: dismissed,
          forward: forward,
          reverse: reverse,
          completed: completed,
        );

  const HitTestBehaviorStrategy.opaque({
    HitTestBehavior dismissed = HitTestBehavior.opaque,
    HitTestBehavior forward = HitTestBehavior.opaque,
    HitTestBehavior reverse = HitTestBehavior.opaque,
    HitTestBehavior completed = HitTestBehavior.opaque,
  }) : super(
          dismissed: dismissed,
          forward: forward,
          reverse: reverse,
          completed: completed,
        );
}

/// Describes when the [IgnoringPointer] should be applied, depending on [AnimationStatus].
class IgnoringStrategy extends AnimationStrategy<bool> {
  const IgnoringStrategy({
    bool dismissed = false,
    bool forward = false,
    bool reverse = false,
    bool completed = false,
  }) : super(
          dismissed: dismissed,
          forward: forward,
          reverse: reverse,
          completed: completed,
        );

  /// Ignore in any [AnimationStatus].
  const IgnoringStrategy.all()
      : super(
          dismissed: true,
          forward: true,
          reverse: true,
          completed: true,
        );

  /// Will evaluate to a single bool condition from the [animation] status.
  bool evaluate(Animation animation) {
    return evaluateStatus(animation.status);
  }

  /// Will evaluate to a single bool condition from the [status].
  bool evaluateStatus(AnimationStatus status) {
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
class MovingIgnoringStrategy extends MovingAnimationStrategy<bool> {
  const MovingIgnoringStrategy({
    bool forward = false,
    bool reverse = false,
  }) : super(forward: forward, reverse: reverse);

  /// Ignore in any [AnimationStatus].
  const MovingIgnoringStrategy.all() : super(forward: true, reverse: true);

  /// Will evaluate to a single bool condition from the [animation] status.
  bool evaluate(Animation animation) {
    return evaluateStatus(animation.status);
  }

  /// Will evaluate to a single bool condition from the [status].
  bool evaluateStatus(AnimationStatus status) {
    return forward && status == AnimationStatus.forward ||
        reverse && status == AnimationStatus.reverse;
  }
}
