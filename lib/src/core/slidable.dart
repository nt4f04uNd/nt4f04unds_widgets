/*---------------------------------------------------------------------------------------------
*  Copyright (c) nt4f04und. All rights reserved.
*  Licensed under the BSD-style license. See LICENSE in the project root for license information.
*
*  Copyright (c) The Flutter Authors.
*  See ThirdPartyNotices.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/rendering.dart';
import 'package:nt4f04unds_widgets/nt4f04unds_widgets.dart';

const double _kMinFlingVelocity = 700.0;
const double _kMinFlingVelocityDelta = 400.0;
const double _kFlingVelocityScale = 1.0 / 300.0;
const double _kExpandThreshold = 0.4;

/// The fling velocity to back to some state,
/// for example when user releases the finger in some intermediate state
const double _kBackToStateVelocity = 1.0;

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

/// Used by [DragEventListenersMixin.addDragEventListener].
typedef void DragEventListener(SlidableDragEvent status);

/// Signature for when the controller value changes.
///
/// Used by [Slidable.onSlideChange].
typedef void SlideChangeCallback(double value);

/// Signature for when the slidable drag begins.
///
/// Used by [Slidable.onDragStart].
typedef void SlideStartCallback(SlideDirection direction);

/// Signature for when the slidable drag updates.
///
/// Used by [Slidable.onDragUpdate].
typedef void SlideUpdateCallback(
  SlideDirection direction,
  DragUpdateDetails details,
);

/// Signature for when the slidable drag updates.
///
/// The [result] indicates whether the slidable will return to start offset (if its `false`)
/// or will be slid out to the end offset (if its `true`).
///
/// Used by [Slidable.onDragEnd]
typedef SlideEndCallback = void Function(SlideDirection direction, bool result);

/// Base class for slide drag events.
abstract class SlidableDragEvent extends Equatable {
  const SlidableDragEvent({@required this.direction});
  final SlideDirection direction;

  @override
  get props => [direction];
}

/// Emitted when user starts dragging the slidable.
class SlidableDragStart extends SlidableDragEvent {
  const SlidableDragStart({@required this.direction});
  @override
  final SlideDirection direction;

  @override
  get props => [direction];
}

/// Emitted on updates of drag on the slidable.
class SlidableDragUpdate extends SlidableDragEvent {
  SlidableDragUpdate({
    @required this.direction,
    @required this.details,
  }) : assert(details != null);

  @override
  final SlideDirection direction;
  final DragUpdateDetails details;

  @override
  get props => [direction, details];
}

/// Emitted when user end dragging the slidable.
///
/// The [result] indicates whether the slidable will return to start offset (if its `false`)
/// or will be slid out to the end offset (if its `true`).
class SlidableDragEnd extends SlidableDragEvent {
  SlidableDragEnd({
    @required this.direction,
    @required this.result,
  }) : assert(result != null);

  @override
  final SlideDirection direction;
  final bool result;

  @override
  get props => [direction, result];
}

/// todo: move flexible drag directions, allow pan probably
/// todo: snap points api
/// todo: rewrite events to display the actual drag direction (and other events too),
/// and document the events and their signatures about what slide direction means in them.
/// now they work wrong, always displaying the direction was provided to the slidable itself,
/// rather than the actual one
///
/// A widget that allows to slide it's content in the indictaed [direction].
///
/// See also:
///  * [SlideDirection], the direction in which a slidable can be slid.
///  * [SlidableController], a controller to use with slidable
///  * [SlidableControllerProvider], inherited widget to provide the [SlidableController]
class Slidable extends StatefulWidget {
  /// Creates a widget that can be expanded.
  const Slidable({
    Key key,
    @required this.child,
    this.controller,
    this.springDescription,
    this.startOffset = Offset.zero,
    this.endOffset = const Offset(1.0, 0.0),
    this.onDragStart,
    this.onDragUpdate,
    this.onDragEnd,
    this.onSlideChange,
    this.shouldGiveUpGesture,
    this.barrierIgnoringStrategy = const IgnoringStrategy(
      dismissed: true,
      reverse: true,
    ),
    this.catchIgnoringStrategy = const MovingIgnoringStrategy(),
    this.hitTestBehaviorStrategy = const HitTestBehaviorStrategy(),
    this.notIgnoringHitTestBehaviorStrategy =
        const HitTestBehaviorStrategy.opaque(),
    this.onBarrierTap,
    this.direction = SlideDirection.upFromBottom,
    this.slideThresholds = const <SlideDirection, double>{},
    this.duration = const Duration(milliseconds: 200),
    this.barrier,
    this.invertBarrierProgress = false,
    this.dragStartBehavior = DragStartBehavior.start,
  })  : assert(springDescription == null || controller == null),
        assert(dragStartBehavior != null),
        super(key: key);

  /// The widget below this widget in the tree.
  ///
  /// {@macro flutter.widgets.child}
  final Widget child;

  /// The animation controller to use instead of the default one.
  final SlidableController controller;

  /// The spring to use with default [controller].
  /// If you specify this value, [controller] must be null.
  final SpringDescription springDescription;

  /// Called when user starts dragging the slidable.
  final SlideStartCallback onDragStart;

  /// Called on updates of drag on the slidable.
  final SlideUpdateCallback onDragUpdate;

  /// Called when user end dragging the slidable.
  final SlideEndCallback onDragEnd;

  /// Fires whenever value of the [controller] changes.
  final SlideChangeCallback onSlideChange;

  /// Called on each pointer move event (even before the drag was accepted).
  ///
  /// Return `false` to give up the gesture.
  final ShouldGiveUpCallback shouldGiveUpGesture;

  /// When to ignore the barrier.
  ///
  /// Ignores dismissed and reverse states by default.
  final IgnoringStrategy barrierIgnoringStrategy;

  /// Describes the ability to "catch" currently moving slidable.
  /// If some of the statuses, let's say, [AnimatingIgnoringStrategy.forward] is disabled,
  /// then you won't be able to stop the slidable while it's animating forward.
  final MovingIgnoringStrategy catchIgnoringStrategy;

  /// What [HitTestBehavior] to apply to the gesture detector (based on the current controller status)
  /// in default case. In other cases [notIgnoringHitTestBehaviorStrategy] is applied.
  ///
  /// By default applies [HitTestBehavior.deferToChild], as most of the time we don't want our
  /// slidable gesture detector to block the events from other gesture detectors, when the animation
  /// associated with it is dismissed.
  final HitTestBehaviorStrategy hitTestBehaviorStrategy;

  /// What [HitTestBehavior] to apply to the gesture detector (based on the current controller status)
  /// when the slidable is being dragged, or when the [barrierIgnoringStrategy] evaluates to be `false`,
  /// which means that the barrier should be touchable.
  ///
  /// By default applies [HitTestBehavior.opaque].
  final HitTestBehaviorStrategy notIgnoringHitTestBehaviorStrategy;

  final Function onBarrierTap;

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

  @override
  SlidableState createState() => SlidableState();
}

enum _FlingGestureKind { none, forward, reverse }

class SlidableState extends State<Slidable>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  @override
  void initState() {
    super.initState();
    _controller = (widget.controller ??
        SlidableController(
          vsync: this,
          duration: widget.duration,
          springDescription: widget.springDescription,
        ));
    if (widget.onSlideChange != null) {
      _controller.addListener(_handleControllerChange);
    }
    _updateAnimation();
  }

  void _handleControllerChange() {
    widget.onSlideChange(_controller.value);
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    if (widget.onSlideChange != null) {
      _controller.removeListener(_handleControllerChange);
    }
    super.dispose();
  }

  double _textScaleFactor;
  SlidableController _controller;
  Animation<Offset> _animation;

  double _dragExtent = 0.0;

  @override
  bool get wantKeepAlive => _controller?.isAnimating == true;

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

  double get _overallDragAxisExtent {
    final Size size = context.size;
    return _directionIsXAxis ? size.width : size.height;
  }

  void _handleDragStart(DragStartDetails details) {
    _controller._dragged = true;
    double sign = 1.0;
    if (_controller.status != AnimationStatus.dismissed) {
      if (widget.direction == SlideDirection.upFromBottom ||
          widget.direction == SlideDirection.endToStart) {
        sign = -1.0;
      }
      // wrong behaviour tests
      // 0.5 0.0 upFromBottom
      // -0.5 0.0 upFromBottom
      // -0.5 0.0 endToStart
      // 0.0 0.5 endToStart
      // 0.0 0.5 upFromBottom
      // 0.0 -0.5 upFromBottom
      // 0.0 -0.5 endToStart
    }
    _dragExtent = _controller.value * _overallDragAxisExtent * sign;
    if (_controller.status == AnimationStatus.forward &&
            !widget.catchIgnoringStrategy.forward ||
        _controller.status == AnimationStatus.reverse &&
            !widget.catchIgnoringStrategy.reverse) {
      _controller.stop();
    }
    if (widget.onDragStart != null) {
      // todo: rewrite this to display the actual drag direction (and other events too)
      widget.onDragStart(_slideDirection);
    }
    _controller.notifyDragEventListeners(
      SlidableDragStart(direction: _slideDirection),
    );
    setState(() {
      _updateAnimation();
    });
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    if (!_controller.isActive || _controller.isAnimating) return;
    if (widget.onDragUpdate != null) {
      widget.onDragUpdate(_slideDirection, details);
    }
    _controller.notifyDragEventListeners(
      SlidableDragUpdate(
        direction: _slideDirection,
        details: details,
      ),
    );

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
    if (!_controller.isActive || _controller.isAnimating) return;

    _controller._dragged = false;
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
          );
          slideResult = false;
          break;
        }
        _dragExtent = flingVelocity.sign;
        _controller.fling(
          velocity: flingVelocity.abs() * _kFlingVelocityScale,
        );
        slideResult = true;
        break;
      case _FlingGestureKind.reverse:
        assert(_dragExtent != 0.0);
        assert(!_controller.isDismissed);
        _dragExtent = flingVelocity.sign;
        _controller.fling(
          velocity: -flingVelocity.abs() * _kFlingVelocityScale,
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
            );
            slideResult = true;
          } else {
            _controller.fling(
              velocity: -_kBackToStateVelocity,
            );
            slideResult = false;
          }
        }
        break;
    }
    if (slideResult != null) {
      if (widget.onDragEnd != null) {
        widget.onDragEnd(_slideDirection, slideResult);
      }
      _controller.notifyDragEventListeners(
        SlidableDragEnd(
          direction: _slideDirection,
          result: slideResult,
        ),
      );
    }

    /// Sometimes on poor framerates the [AnimatedBuilder] may not rebuild
    /// causing wrong hit test behaviour and ignoring pointer.
    /// This needed to update them and avoid this.
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // See AutomaticKeepAliveClientMixin.

    assert(!_directionIsXAxis || debugCheckHasDirectionality(context));

    final textScaleFactor = MediaQuery.of(context).textScaleFactor;
    if (_textScaleFactor != textScaleFactor) {
      // todo: rewrite this with [NFWidgetsBindingObserver]
      // Update the position on text scale scale change.
      _textScaleFactor = textScaleFactor;
      _updateAnimation();
    }

    Widget content = SlideTransition(
      position: _animation,
      child: widget.child,
    );

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        HitTestBehavior hitTestBehavior;
        final status = _controller.status;

        final ignoring = widget.barrierIgnoringStrategy.evaluateStatus(status);
        if (_controller._dragged || !ignoring) {
          hitTestBehavior =
              widget.notIgnoringHitTestBehaviorStrategy.askStatus(status);
        } else {
          hitTestBehavior = widget.hitTestBehaviorStrategy.askStatus(status);
        }

        // We are not resizing but we may be being dragging in widget.direction.
        return RawGestureDetector(
          behavior: hitTestBehavior,
          gestures: <Type, GestureRecognizerFactory>{
            if (_directionIsXAxis)
              NFHorizontalDragGestureRecognizer:
                  GestureRecognizerFactoryWithHandlers<
                      NFHorizontalDragGestureRecognizer>(
                () => NFHorizontalDragGestureRecognizer(),
                (NFHorizontalDragGestureRecognizer instance) => instance
                  ..onStart = _handleDragStart
                  ..onUpdate = _handleDragUpdate
                  ..onEnd = _handleDragEnd
                  ..dragStartBehavior = widget.dragStartBehavior
                  ..shouldGiveUp = widget.shouldGiveUpGesture,
              ),
            if (!_directionIsXAxis)
              NFVerticalDragGestureRecognizer:
                  GestureRecognizerFactoryWithHandlers<
                      NFVerticalDragGestureRecognizer>(
                () => NFVerticalDragGestureRecognizer(),
                (NFVerticalDragGestureRecognizer instance) => instance
                  ..onStart = _handleDragStart
                  ..onUpdate = _handleDragUpdate
                  ..onEnd = _handleDragEnd
                  ..dragStartBehavior = widget.dragStartBehavior
                  ..shouldGiveUp = widget.shouldGiveUpGesture,
              ),
          },
          child: widget.barrier == null
              ? content
              : () {
                  final children = [
                    IgnorePointer(
                      ignoring: ignoring,
                      child: FadeTransition(
                        opacity: widget.invertBarrierProgress
                            ? ReverseAnimation(_controller)
                            : _controller,
                        child: widget.onBarrierTap != null &&
                                status == AnimationStatus.dismissed
                            ? widget.barrier
                            : GestureDetector(
                                onTap: widget.onBarrierTap,
                                behavior: HitTestBehavior.opaque,
                                child: widget.barrier,
                              ),
                      ),
                    ),
                    content,
                  ];
                  return hitTestBehavior == HitTestBehavior.translucent
                      ? StackWithAllChildrenReceiveEvents(children: children)
                      : Stack(children: children);
                }(),
        );
      },
    );
  }
}

/// A controller to use with [Slidable], it extends an [AnimationController].
///
/// Provides an ability to listen to the drag events via [addDragEventListener]/[removeDragEventListener].
///
/// I also provided it with 3 methods to propagate/simulate drag events:
///
/// * [notifySlidablesDragStart]
/// * [notifySlidablesDragUpdate]
/// * [notifySlidablesDragEnd]
///
/// See also:
///  * [Slidable], a widget that allows you to slide it's content
///  * [SlidableControllerProvider], inherited widget to provide the controller
class SlidableController extends AnimationController
    with DragEventListenersMixin {
  SlidableController({
    this.springDescription,
    double value = 0.0,
    Duration duration = kNFRouteTransitionDuration,
    Duration reverseDuration,
    String debugLabel,
    double lowerBound = 0.0,
    double upperBound = 1.0,
    AnimationBehavior animationBehavior = AnimationBehavior.normal,
    @required TickerProvider vsync,
  }) : super(
          value: value,
          duration: duration,
          reverseDuration: reverseDuration,
          debugLabel: debugLabel,
          lowerBound: lowerBound,
          upperBound: upperBound,
          animationBehavior: animationBehavior,
          vsync: vsync,
        );

  /// The default spring description to use within the [fling].
  final SpringDescription springDescription;

  /// Indicates that the slidable is being dragged or it is animating.
  bool get isActive => _dragged || isAnimating;
  bool get opened =>
      _dragged || isCompleted || !_dragged && status == AnimationStatus.forward;
  bool get closed =>
      isDismissed || !_dragged && status == AnimationStatus.reverse;

  bool _dragged = false;
  bool get dragged => _dragged;

  @override
  TickerFuture fling({
    double velocity = 1.0,
    SpringDescription springDescription,
    AnimationBehavior animationBehavior,
  }) {
    springDescription ??= this.springDescription;
    return super.fling(
      velocity: velocity,
      springDescription: springDescription,
      animationBehavior: animationBehavior,
    );
  }

  /// Calls [fling] with default velocity to end in the [opened] state.
  TickerFuture open({SpringDescription springDescription}) {
    return fling(
      springDescription: springDescription ?? this.springDescription,
    );
  }

  /// Calls [fling] with default velocity to end in the [closed] state.
  TickerFuture close({SpringDescription springDescription}) {
    return fling(
      velocity: -1.0,
      springDescription: springDescription ?? this.springDescription,
    );
  }
}

/// [SlidableControllerProvider], inherited widget to provide the [SlidableController].
class SlidableControllerProvider<T> extends InheritedWidget {
  const SlidableControllerProvider({
    Key key,
    @required this.child,
    @required this.controller,
  })  : assert(child != null),
        assert(controller != null),
        super(key: key, child: child);

  final Widget child;
  final SlidableController controller;

  static SlidableControllerProvider<T> of<T>(BuildContext context) {
    return context
        .getElementForInheritedWidgetOfExactType<
            SlidableControllerProvider<T>>()
        .widget;
  }

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) {
    return false;
  }
}

/// A mixin that implements the [addStatusListener]/[removeStatusListener] protocol
/// and notifies all the registered listeners when [notifyStatusListeners] is
/// called.
///
/// This mixin requires that the mixing class provide methods [didRegisterListener]
/// and [didUnregisterListener]. Implementations of these methods can be obtained
/// by mixing in another mixin from this library, such as [AnimationLazyListenerMixin].
mixin DragEventListenersMixin {
  final ObserverList<DragEventListener> _dragEventListeners =
      ObserverList<DragEventListener>();

  /// Called immediately before a drag event listener is added via [addStatusListener].
  ///
  /// At the time this method is called the registered listener is not yet
  /// notified by [notifyDragEventListeners].
  void didRegisterListener();

  /// Called immediately after a drag event listener is removed via [removeDragEventListener].
  ///
  /// At the time this method is called the removed listener is no longer
  /// notified by [notifyDragEventListeners].
  void didUnregisterListener();

  /// Calls listener every time the status of the drag changes.
  ///
  /// Listeners can be removed with [removeDragEventListener].
  void addDragEventListener(DragEventListener listener) {
    didRegisterListener();
    _dragEventListeners.add(listener);
  }

  /// Stops calling the listener every time the status of the drag changes.
  ///
  /// Listeners can be added with [addDragEventListener].
  void removeDragEventListener(DragEventListener listener) {
    final bool removed = _dragEventListeners.remove(listener);
    if (removed) {
      didUnregisterListener();
    }
  }

  /// Calls all the drag event listeners.
  ///
  /// If listeners are added or removed during this function, the modifications
  /// will not change which listeners are called during this iteration.
  void notifyDragEventListeners(SlidableDragEvent event) {
    final List<DragEventListener> localListeners =
        List<DragEventListener>.from(_dragEventListeners);
    for (final DragEventListener listener in localListeners) {
      if (_dragEventListeners.contains(listener)) listener(event);
    }
  }
}
