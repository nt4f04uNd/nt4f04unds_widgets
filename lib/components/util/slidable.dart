/*---------------------------------------------------------------------------------------------
*  Copyright (c) nt4f04und. All rights reserved.
*  Licensed under the BSD-style license. See LICENSE in the project root for license information.
*
*  Copyright (c) The Flutter Authors.
*  See ThirdPartyNotices.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/rendering.dart';

const double _kMinFlingVelocity = 700.0;
const double _kMinFlingVelocityDelta = 400.0;
const double _kFlingVelocityScale = 1.0 / 300.0;
const double _kExpandThreshold = 0.4;

/// The fling velocity to back to some state,
/// for example when user releases the finger in some intermediate state
const double _kBackToStateVelocity = 1.0;

/// Signature used by [Slidable] to indicate that it has been expanded/shrunken in
/// the given `direction`.
///
/// Used by [Slidable.onDragStart].
typedef _SlideStartCallback = void Function(SlideDirection direction);

/// Used by [Slidable.onDragUpdate]
typedef _SlideUpdateCallback = void Function(
  SlideDirection direction,
  DragUpdateDetails details,
);

/// The result indicates whether the slidable will return into initial state (if its `false`)
/// or will be slid (if its `true`)
///
/// Used by [Slidable.onDragEnd]
typedef _SlideEndCallback = void Function(
    SlideDirection direction, bool result);

/// Used by [Slidable.onSlideChange]
typedef _SlideChangeCallback = void Function(double value);

/// The direction in which a [Slidable] can be slid.
enum SlideDirection {
  /// The [Slidable] can be slid by dragging in the reverse of the
  /// reading direction (e.g., from right to left in left-to-right languages).
  endToStart,

  /// The [Slidable] can be slid by dragging in the reading direction
  /// (e.g., from left to right in left-to-right languages).
  startToEnd,

  /// The [Slidable] can be slid by dragging up only.
  upFromBottom,

  /// The [Slidable] can be slid by dragging down only.
  downFromTop,
}

/// A widget that can be slid by dragging in the indicated [direction].
///
/// Dragging or flinging this widget in the [ExpandDirection] causes the child
/// to slide out of view.
///
/// The widget calls the [onSlideComplete] callback either after its expansion
/// and the [onSlideDismissed] after shrinking.
class Slidable extends StatefulWidget {
  /// Creates a widget that can be expanded.
  const Slidable({
    Key key,
    @required this.child,
    this.controller,
    this.startOffset = Offset.zero,
    this.endOffset = const Offset(1.0, 0.0),
    this.onDragStart,
    this.onDragUpdate,
    this.onDragEnd,
    this.onSlideChange,
    this.canReverseForward = true,
    this.canReverseReverse = true,
    this.direction = SlideDirection.upFromBottom,
    this.slideThresholds = const <SlideDirection, double>{},
    this.duration = const Duration(milliseconds: 200),
    this.barrier,
    this.ignoreBarrierForward = false,
    this.ignoreBarrierReverse = false,
    this.invertBarrierProgress = false,
    this.dragStartBehavior = DragStartBehavior.start,
    this.springDescription,
  })  : assert(dragStartBehavior != null),
        super(key: key);

  /// The widget below this widget in the tree.
  ///
  /// {@macro flutter.widgets.child}
  final Widget child;

  /// The animation controller to use instead of the default one.
  final AnimationController controller;

  /// Called when user starts dragging the slidable.
  final _SlideStartCallback onDragStart;

  /// Called on updates of drag on the slidable.
  final _SlideUpdateCallback onDragUpdate;

  /// Called when user end dragging the slidable.
  final _SlideEndCallback onDragEnd;

  /// Fires whenever value of the [controller] changes.
  final _SlideChangeCallback onSlideChange;

  /// Whether user can "catch" the slidable in forward move animation and reverse it back.
  final bool canReverseForward;

  /// Whether user can "catch" the slidable in reverse move animation and reverse it back.
  final bool canReverseReverse;

  /// The direction in which the widget can be slid.
  final SlideDirection direction;

  /// The offset threshold the item has to be dragged in order to be considered
  /// slid.
  ///
  /// Represented as a fraction, e.g. if it is 0.4 (the default), then the item
  /// has to be dragged at least 40% towards one direction to be considered
  /// slid. Clients can define different thresholds for each slide
  /// direction.
  ///
  /// Flinging is treated as being equivalent to dragging almost to 1.0, so
  /// flinging can slide an item past any threshold less than 1.0.
  ///
  /// Setting a threshold of 1.0 (or greater) prevents a drag in the given
  /// [SlideDirection] even if it would be allowed by the [direction]
  /// property.
  ///
  /// See also:
  ///
  ///  * [direction], which controls the directions in which the items can
  ///    be slid.
  final Map<SlideDirection, double> slideThresholds;

  /// Defines the duration to slide or to come back to original position if not slide is not confirmed.
  final Duration duration;

  /// Defines the start offset.
  ///
  /// For example , the `Offset(-0.5, 0.3)` will mean the -0.5 offset for the main axis and 0.3 for cross axis.
  /// The main axis for horizontal is X, for vertical directions is Y.
  ///
  /// Defaults to `Offset.zero`.
  final Offset startOffset;

  /// Defines the end offset.
  ///
  /// For example , the `Offset(-0.5, 0.3)` will mean the -0.5 offset for the main axis and 0.3 for cross axis.
  /// The main axis for horizontal is X, for vertical directions is Y.
  ///
  /// Defaults to `const Offset(1.0, 0.0)`.
  final Offset endOffset;

  /// The widget to show on `Offset.zero`, can be used for barriers.
  ///
  /// Example of a barrier:
  /// ```
  /// Container(
  ///   color: Colors.black54,
  /// )
  /// ```
  final Widget barrier;

  /// By default the barrier will be visible when slidable is in start position.
  /// If this condition is true, this behaviour will be changed diverse.
  final bool invertBarrierProgress;

  /// Whether user can "catch" the slidable in forward move animation with touching the barrier.
  final bool ignoreBarrierForward;

  /// Whether user can "catch" the slidable in reverse move animation with touching the barrier.
  final bool ignoreBarrierReverse;

  /// Determines the way that drag start behavior is handled.
  ///
  /// If set to [DragStartBehavior.start], the drag gesture used to slide a
  /// slidable will begin upon the detection of a drag gesture. If set to
  /// [DragStartBehavior.down] it will begin when a down event is first detected.
  ///
  /// In general, setting this to [DragStartBehavior.start] will make drag
  /// animation smoother and setting it to [DragStartBehavior.down] will make
  /// drag behavior feel slightly more reactive.
  ///
  /// By default, the drag start behavior is [DragStartBehavior.start].
  ///
  /// See also:
  ///
  ///  * [DragGestureRecognizer.dragStartBehavior], which gives an example for the different behaviors.
  final DragStartBehavior dragStartBehavior;

  /// Spring description for the fling animation.
  final SpringDescription springDescription;

  @override
  _SlidableState createState() => _SlidableState();
}

enum _FlingGestureKind { none, forward, reverse }

class _SlidableState extends State<Slidable>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  @override
  void initState() {
    super.initState();
    _controller = (widget.controller ??
        AnimationController(duration: widget.duration, vsync: this));
    if (widget.onSlideChange != null) {
      _controller.addListener(() {
        widget.onSlideChange(_controller.value);
      });
    }
    _updateAnimation();
  }

  double _textScaleFactor;
  AnimationController _controller;
  Animation<Offset> _animation;

  double _dragExtent = 0.0;
  bool _dragUnderway = false;

  @override
  bool get wantKeepAlive => _controller?.isAnimating == true;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _directionIsXAxis {
    return widget.direction == SlideDirection.endToStart ||
        widget.direction == SlideDirection.startToEnd;
  }

  SlideDirection _extentToDirection(double extent) {
    if (extent == 0.0) return null;
    if (_directionIsXAxis) {
      switch (Directionality.of(context)) {
        case TextDirection.rtl:
          return extent < 0
              ? SlideDirection.startToEnd
              : SlideDirection.endToStart;
        case TextDirection.ltr:
          return extent > 0
              ? SlideDirection.startToEnd
              : SlideDirection.endToStart;
      }
      assert(false);
      return null;
    }
    return extent > 0
        ? SlideDirection.downFromTop
        : SlideDirection.upFromBottom;
  }

  SlideDirection get _slideDirection => _extentToDirection(_dragExtent);

  bool get _isActive {
    return _dragUnderway || _controller.isAnimating;
  }

  double get _overallDragAxisExtent {
    final Size size = context.size;
    return _directionIsXAxis ? size.width : size.height;
  }

  void _handleDragStart(DragStartDetails details) {
    _dragUnderway = true;
    final double sign =
        _controller.status == AnimationStatus.dismissed ? 1.0 : -1.0;
    _dragExtent = _controller.value * _overallDragAxisExtent * sign;
    if (_controller.status == AnimationStatus.forward &&
        widget.canReverseForward) {
      _controller.stop();
    } else if (_controller.status == AnimationStatus.reverse &&
        widget.canReverseReverse) {
      _controller.stop();
    }
    if (widget.onDragStart != null) widget.onDragStart(_slideDirection);
    setState(() {
      _updateAnimation();
    });
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    if (!_isActive || _controller.isAnimating) return;
    if (widget.onDragUpdate != null) {
      widget.onDragUpdate(_slideDirection, details);
    }

    final double delta = details.primaryDelta;
    final double oldDragExtent = _dragExtent;
    switch (widget.direction) {
      case SlideDirection.upFromBottom:
        if (_dragExtent + delta < 0) _dragExtent += delta;
        break;

      case SlideDirection.downFromTop:
        if (_dragExtent + delta > 0) _dragExtent += delta;
        break;
      case SlideDirection.endToStart:
        switch (Directionality.of(context)) {
          case TextDirection.rtl:
            if (_dragExtent + delta > 0) _dragExtent += delta;
            break;
          case TextDirection.ltr:
            if (_dragExtent + delta < 0) _dragExtent += delta;
            break;
        }
        break;

      case SlideDirection.startToEnd:
        switch (Directionality.of(context)) {
          case TextDirection.rtl:
            if (_dragExtent + delta < 0) _dragExtent += delta;
            break;
          case TextDirection.ltr:
            if (_dragExtent + delta > 0) _dragExtent += delta;
            break;
        }
        break;
    }
    if (oldDragExtent.sign != _dragExtent.sign && _dragExtent.sign != 0.0) {
      setState(() {
        _updateAnimation();
      });
    }
    if (!_controller.isAnimating) {
      _controller.value = _dragExtent.abs() / _overallDragAxisExtent;
    }
  }

  void _updateAnimation() {
    double startDx = widget.startOffset.dx;
    double startDy = widget.startOffset.dy;
    double endDx = widget.endOffset.dx;
    double endDy = widget.endOffset.dy;
    _animation = _controller.drive(
      Tween<Offset>(
        begin: _directionIsXAxis
            ? Offset(startDx, startDy)
            : Offset(startDy, startDx),
        end: _directionIsXAxis ? Offset(endDx, endDy) : Offset(endDy, endDx),
      ),
    );
  }

  _FlingGestureKind _describeFlingGesture(Velocity velocity) {
    assert(widget.direction != null);
    if (_dragExtent == 0.0) {
      // If it was a fling, then it was a fling that was let loose at the exact
      // middle of the range (i.e. when there's no displacement). In that case,
      // we assume that the user meant to fling it back to the center, as
      // opposed to having wanted to drag it out one way, then fling it past the
      // center and into and out the other side.
      return _FlingGestureKind.none;
    }
    final double vx = velocity.pixelsPerSecond.dx;
    final double vy = velocity.pixelsPerSecond.dy;
    SlideDirection flingDirection;
    // Verify that the fling is in the generally right direction and fast enough.
    if (_directionIsXAxis) {
      if (vx.abs() - vy.abs() < _kMinFlingVelocityDelta ||
          vx.abs() < _kMinFlingVelocity) return _FlingGestureKind.none;
      assert(vx != 0.0);
      flingDirection = _extentToDirection(vx);
    } else {
      if (vy.abs() - vx.abs() < _kMinFlingVelocityDelta ||
          vy.abs() < _kMinFlingVelocity) return _FlingGestureKind.none;
      assert(vy != 0.0);
      flingDirection = _extentToDirection(vy);
    }
    assert(_slideDirection != null);
    if (flingDirection == _slideDirection) return _FlingGestureKind.forward;
    return _FlingGestureKind.reverse;
  }

  Future<void> _handleDragEnd(DragEndDetails details) async {
    if (!_isActive || _controller.isAnimating) return;

    _dragUnderway = false;
    final double flingVelocity = _directionIsXAxis
        ? details.velocity.pixelsPerSecond.dx
        : details.velocity.pixelsPerSecond.dy;
    bool slideResult;
    switch (_describeFlingGesture(details.velocity)) {
      case _FlingGestureKind.forward:
        assert(_dragExtent != 0.0);
        assert(!_controller.isDismissed);
        if ((widget.slideThresholds[_slideDirection] ?? _kExpandThreshold) >=
            1.0) {
          _controller.fling(
            velocity: -_kBackToStateVelocity,
            springDescription: widget.springDescription,
          );
          slideResult = false;
          break;
        }
        _dragExtent = flingVelocity.sign;
        _controller.fling(
          velocity: flingVelocity.abs() * _kFlingVelocityScale,
          springDescription: widget.springDescription,
        );
        slideResult = true;
        break;
      case _FlingGestureKind.reverse:
        assert(_dragExtent != 0.0);
        assert(!_controller.isDismissed);
        _dragExtent = flingVelocity.sign;
        _controller.fling(
          velocity: -flingVelocity.abs() * _kFlingVelocityScale,
          springDescription: widget.springDescription,
        );
        slideResult = false;
        break;
      case _FlingGestureKind.none:
        if (!_controller.isDismissed) {
          // we already know it's not completed, we check that above
          if (_controller.value >
              (widget.slideThresholds[_slideDirection] ?? _kExpandThreshold)) {
            _controller.fling(
              velocity: _kBackToStateVelocity,
              springDescription: widget.springDescription,
            );
            slideResult = true;
          } else {
            _controller.fling(
              velocity: -_kBackToStateVelocity,
              springDescription: widget.springDescription,
            );
            slideResult = false;
          }
        }
        break;
    }
    if (widget.onDragEnd != null && slideResult != null)
      widget.onDragEnd(_slideDirection, slideResult);
  }

  bool get _ignoringBarrier =>
      _controller.isDismissed ||
      _controller.status == AnimationStatus.forward &&
          (widget.ignoreBarrierForward || !widget.canReverseForward) ||
      _controller.status == AnimationStatus.reverse &&
          (widget.ignoreBarrierReverse || !widget.canReverseReverse);

  @override
  Widget build(BuildContext context) {
    super.build(context); // See AutomaticKeepAliveClientMixin.

    assert(!_directionIsXAxis || debugCheckHasDirectionality(context));

    final textScaleFactor = MediaQuery.of(context).textScaleFactor;
    if (_textScaleFactor != textScaleFactor) {
      _textScaleFactor = textScaleFactor;
      _updateAnimation();
    }

    Widget content = SlideTransition(
      position: _animation,
      child: widget.child,
    );

    // We are not resizing but we may be being dragging in widget.direction.
    return GestureDetector(
      onHorizontalDragStart: _directionIsXAxis ? _handleDragStart : null,
      onHorizontalDragUpdate: _directionIsXAxis ? _handleDragUpdate : null,
      onHorizontalDragEnd: _directionIsXAxis ? _handleDragEnd : null,
      onVerticalDragStart: _directionIsXAxis ? null : _handleDragStart,
      onVerticalDragUpdate: _directionIsXAxis ? null : _handleDragUpdate,
      onVerticalDragEnd: _directionIsXAxis ? null : _handleDragEnd,
      behavior: HitTestBehavior.deferToChild,
      dragStartBehavior: widget.dragStartBehavior,
      child: widget.barrier == null
          ? content
          : Stack(
              children: [
                AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      return IgnorePointer(
                        ignoring: _ignoringBarrier,
                        child: FadeTransition(
                          opacity: widget.invertBarrierProgress
                              ? ReverseAnimation(_controller)
                              : _controller,
                          child: widget.barrier,
                        ),
                      );
                    }),
                content,
              ],
            ),
    );
  }
}
