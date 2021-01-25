/*---------------------------------------------------------------------------------------------
*  Copyright (c) nt4f04und. All rights reserved.
*  Licensed under the BSD-style license. See LICENSE in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import 'package:flutter/material.dart';

/// Signature to create a builder with animation.
///
/// Used by [AnimationSwitcher.builder1] and [AnimationSwitcher.builder2].
/// 
/// todo: split to separate file.
typedef Widget AnimationBuilder(
  BuildContext context,
  Animation<double> animation,
  Widget child,
);

/// An analogue of the [AnimatedSwitcher], but based on explicit [animation] property.
///
/// todo: document this
class NFAnimationSwitcher extends StatelessWidget {
  const NFAnimationSwitcher({
    Key key,
    @required this.child1,
    @required this.child2,
    this.builder1 = defaultBuilder,
    this.builder2 = defaultBuilder,
    @required this.animation,
  })  : assert(child1 != null),
        assert(child2 != null),
        assert(animation != null),
        super(key: key);

  final Widget child1;
  final Widget child2;
  final AnimationBuilder builder1;
  final AnimationBuilder builder2;
  final Animation animation;

  static Widget defaultBuilder(
    BuildContext context,
    Animation<double> animation,
    Widget child,
  ) {
    return FadeTransition(
      opacity: animation,
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (BuildContext context, Widget child) => Stack(
        children: [
          IgnorePointer(
            ignoring: animation.status == AnimationStatus.forward ||
                animation.status == AnimationStatus.completed,
            child: builder1(
              context,
              Tween(begin: 1.0, end: 0.0).animate(animation),
              child1,
            ),
          ),
          IgnorePointer(
            ignoring: animation.status == AnimationStatus.reverse ||
                animation.status == AnimationStatus.dismissed,
            child: builder2(
              context,
              animation,
              child2,
            ),
          ),
        ],
      ),
    );
  }
}
