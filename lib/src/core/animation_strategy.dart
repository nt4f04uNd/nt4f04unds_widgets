/*---------------------------------------------------------------------------------------------
*  Copyright (c) nt4f04und. All rights reserved.
*  Licensed under the BSD-style license. See LICENSE in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import 'package:flutter/material.dart';

/// Describes what to do when depending on the current animation status.
/// An interface for other animation strategies.
@immutable
abstract class AnimationStrategy<T> implements MovingAnimationStrategy<T> {
  const AnimationStrategy({
    required this.dismissed,
    required this.forward,
    required this.completed,
    required this.reverse,
  });

  final T dismissed;
  @override
  final T forward;
  final T completed;
  @override
  final T reverse;

  /// Decides what to do based on current animation status.
  @override
  T ask(Animation animation) {
    return decide(animation.status);
  }

  /// Decides what to do based on [status].
  @override
  T decide(AnimationStatus status) {
    switch (status) {
      case AnimationStatus.dismissed:
        return dismissed;
      case AnimationStatus.forward:
        return forward;
      case AnimationStatus.completed:
        return completed;
      case AnimationStatus.reverse:
        return reverse;
    }
  }

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) return false;
    return other is AnimationStrategy &&
        other.dismissed == dismissed &&
        other.forward == forward &&
        other.completed == completed &&
        other.reverse == reverse;
  }

  @override
  int get hashCode => Object.hash(dismissed, forward, completed, reverse);
}

/// Describes what to do when depending on the current animation status, that's either [AnimationStatus.forward], or [AnimationStatus.reverse].
/// An interface for other animation strategies.
@immutable
abstract class MovingAnimationStrategy<T> {
  const MovingAnimationStrategy({required this.forward, required this.reverse});

  final T forward;
  final T reverse;

  /// Decides what to do based on current animation status.
  ///
  /// Will return null if the status is not moving, which is
  /// [AnimationStatus.dismissed], or [AnimationStatus.completed].
  T? ask(Animation animation) {
    return decide(animation.status);
  }

  /// Decides what to do based on [status].
  ///
  /// Will return null if the status is not moving, which is
  /// [AnimationStatus.dismissed], or [AnimationStatus.completed].
  T? decide(AnimationStatus status) {
    switch (status) {
      case AnimationStatus.forward:
        return forward;
      case AnimationStatus.reverse:
        return reverse;
      default:
        return null;
    }
  }

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) return false;
    return other is AnimationStrategy && other.forward == forward && other.reverse == reverse;
  }

  @override
  int get hashCode => Object.hash(forward, reverse);
}

/// Describes what [HitTestBehavior] should be applied, depending on [AnimationStatus].
class HitTestBehaviorStrategy extends AnimationStrategy<HitTestBehavior> {
  const HitTestBehaviorStrategy({
    super.dismissed = HitTestBehavior.deferToChild,
    super.forward = HitTestBehavior.deferToChild,
    super.reverse = HitTestBehavior.deferToChild,
    super.completed = HitTestBehavior.deferToChild,
  });

  const HitTestBehaviorStrategy.translucent({
    super.dismissed = HitTestBehavior.translucent,
    super.forward = HitTestBehavior.translucent,
    super.reverse = HitTestBehavior.translucent,
    super.completed = HitTestBehavior.translucent,
  });

  const HitTestBehaviorStrategy.opaque({
    super.dismissed = HitTestBehavior.opaque,
    super.forward = HitTestBehavior.opaque,
    super.reverse = HitTestBehavior.opaque,
    super.completed = HitTestBehavior.opaque,
  });
}

/// Describes when the [IgnoringPointer] should be applied, depending on [AnimationStatus].
class IgnoringStrategy extends AnimationStrategy<bool> {
  const IgnoringStrategy({
    super.dismissed = false,
    super.forward = false,
    super.reverse = false,
    super.completed = false,
  });

  /// Ignore in any [AnimationStatus].
  const IgnoringStrategy.all() : super(dismissed: true, forward: true, reverse: true, completed: true);

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
  const MovingIgnoringStrategy({super.forward = false, super.reverse = false});

  /// Ignore in any [AnimationStatus].
  const MovingIgnoringStrategy.all() : super(forward: true, reverse: true);

  /// Will evaluate to a single bool condition from the [animation] status.
  bool evaluate(Animation animation) {
    return evaluateStatus(animation.status);
  }

  /// Will evaluate to a single bool condition from the [status].
  bool evaluateStatus(AnimationStatus status) {
    return forward && status == AnimationStatus.forward || reverse && status == AnimationStatus.reverse;
  }
}
