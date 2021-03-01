/*---------------------------------------------------------------------------------------------
*  Copyright (c) nt4f04und. All rights reserved.
*  Licensed under the BSD-style license. See LICENSE in the project root for license information.
*--------------------------------------------------------------------------------------------*/

// @dart = 2.12

import 'package:flutter/material.dart';
import 'package:nt4f04unds_widgets/nt4f04unds_widgets.dart';

/// An analogue of the [AnimatedSwitcher], but based on explicit [animation] property.
class AnimationSwitcher extends StatelessWidget {
  const AnimationSwitcher({
    Key? key,
    required this.animation,
    required this.child1,
    required this.child2,
    this.builder1 = defaultBuilder,
    this.builder2 = defaultBuilder,
  })  : assert(child1 != null),
        assert(child2 != null),
        assert(animation != null),
        super(key: key);

  final Animation<double> animation;
  final Widget child1;
  final Widget child2;
  final AnimatedSwitcherTransitionBuilder builder1;
  final AnimatedSwitcherTransitionBuilder builder2;

  static Widget defaultBuilder(Widget child, Animation<double> animation) {
    return FadeTransition(
      opacity: animation,
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final reverseTween = Tween(begin: 1.0, end: 0.0);
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) => Stack(
        children: [
          IgnorePointer(
            ignoring: const IgnoringStrategy(forward: true, completed: true).ask(animation),
            child: builder1(child1, reverseTween.animate(animation)),
          ),
          IgnorePointer(
            ignoring: const IgnoringStrategy(reverse: true, dismissed: true).ask(animation),
            child: builder2(child2, animation),
          ),
        ],
      ),
    );
  }
}
