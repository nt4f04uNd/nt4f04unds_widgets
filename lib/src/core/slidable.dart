/*---------------------------------------------------------------------------------------------
*  Copyright (c) nt4f04und. All rights reserved.
*  Licensed under the BSD-style license. See LICENSE in the project root for license information.
*
*  Copyright (c) The Flutter Authors.
*  See ThirdPartyNotices.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/rendering.dart';
import 'package:nt4f04unds_widgets/nt4f04unds_widgets.dart';

// todo: compose to allow backdrop filter's use?
// todo: https://github.com/material-components/material-components-flutter/blob/develop/docs/components/expanding-bottom-sheet.md

const double _kMinFlingVelocity = 700.0;
const double _kMinFlingVelocityDelta = 400.0;
const double _kFlingVelocityScale = 1.0 / 300.0;

/// The fling velocity to back to some state,
/// for example when user releases the finger in some intermediate state
const double _kBackToStateVelocity = 1.0;


/// The direction in which a [Slidable] can be slid.
enum SlideDirection {
  /// The [Slidable] can be slid by dragging left only.
  left,

  /// The [Slidable] can be slid by dragging right only.
  right,

  /// The [Slidable] can be slid by dragging up only.
  up,

  /// The [Slidable] can be slid by dragging down only.
  down,

  /// The [Slidable] cannot be slid by dragging.
  none,
}

/// todo: might be split up to framework.dart as new builder signature?
/// todo: change name and docs
typedef _Builder = Widget Function(Animation<double> animation, Widget child);

/// Used by [DragEventListenersMixin.addDragEventListener].
typedef void SlidableDragEventListener(SlidableDragEvent status);

/// Signature for a function used to notify about controller value changes.
///
/// Used by [Slidable.onSlideChange].
typedef void SlideChangeCallback(double value);

/// Signature for a function used to notify about slidable drag begins.
///
/// Used by [Slidable.onDragStart].
typedef void SlideStartCallback(DragStartDetails dragDetails);

/// Signature for a function used to notify about slidable drag updates.
///
/// Used by [Slidable.onDragUpdate].
typedef void SlideUpdateCallback(DragUpdateDetails details);

/// Signature for a function used to notify about slidable drag ends.
///
/// The [result] indicates whether the slidable will return to start offset (if its `false`)
/// or will be slid out to the end offset (if its `true`).
///
/// Used by [Slidable.onDragEnd]
typedef SlideEndCallback = void Function(DragEndDetails details, bool result);

/// Base class for slide drag events.
abstract class SlidableDragEvent {
  const SlidableDragEvent();
}

/// Emitted when user starts dragging slidable.
class SlidableDragStart extends SlidableDragEvent {
  const SlidableDragStart({ required this.details });
  final DragStartDetails details;
}

/// Emitted on updates of drag on slidable.
class SlidableDragUpdate extends SlidableDragEvent {
  const SlidableDragUpdate({ required this.details });
  final DragUpdateDetails details;
}

/// Emitted when user ends dragging slidable.
///
/// The [closing] indicates whether the slidable will return to start offset (if its `false`)
/// or will be slid out to the end offset (if its `true`).
class SlidableDragEnd extends SlidableDragEvent {
  const SlidableDragEnd({ required this.details, required this.closing });
  final DragEndDetails details;
  final bool closing;
}

/// todo: should add panning or no?
/// todo: snapping points
///
/// A widget that allows to slide its child in the indictaed [direction].
///
/// See also:
///  * [SlideDirection], the direction in which a slidable can be slid.
///  * [SlidableController], a controller to use with slidable
///  * [SlidableControllerProvider], inherited widget to provide a [SlidableController]
class Slidable extends StatefulWidget {
  const Slidable({
    Key? key,
    required this.child,
    this.direction = SlideDirection.up,
    this.start = 1.0,
    this.end = 0.0,
    this.controller,
    this.childBuilder,
    this.barrier,
    this.barrierBuilder = _defaultBarrierBuilder,
    this.springDescription,
    this.onBarrierTap,
    this.onDragStart,
    this.onDragUpdate,
    this.onDragEnd,
    this.onSlideChange,
    this.shouldGiveUpGesture,
    this.disableSlideTransition = false,
    this.barrierIgnoringStrategy = const IgnoringStrategy(dismissed: true, reverse: true),
    this.catchIgnoringStrategy = const MovingIgnoringStrategy(),
    this.hitTestBehaviorStrategy = const HitTestBehaviorStrategy(),
    this.threshold = 0.4,
    this.dragStartBehavior = DragStartBehavior.start,
  }) : assert(springDescription == null || controller == null),
       assert(start <= end && (direction == SlideDirection.right || direction == SlideDirection.down) ||
              start >= end && (direction == SlideDirection.left || direction == SlideDirection.up), 
              'start and end must correspond with direction'),
       super(key: key);

  static Widget _defaultBarrierBuilder(Animation<double> animation, Widget child) {
    return FadeTransition(
      opacity: animation,
      child: child,
    );
  }

  /// The widget below this widget in the tree.
  ///
  /// {@macro flutter.widgets.child}
  final Widget child;

  /// The direction in which the slide will be performed.
  /// 
  /// This sets the used slide axis and positive drag direction.
  /// 
  /// The negative drag direction is set automatically to the opposite.
  /// For example for [SlideDirection.up], the opposite is [SlideDirection.down].
  final SlideDirection direction;

  /// Defines the start position in terms of used [direction] axis in [FractionalOffset].
  final double start;

  /// Defines the end position in terms of used [direction] axis in [FractionalOffset].
  final double end;

  /// A controller to use with this slidable.
  /// 
  /// When passing a controller, [springDescription] must be null.
  /// If none given, instead the default one will be used.
  final SlidableController? controller;

  //todo: docs
  final _Builder? childBuilder;

  /// The widget to show on `Offset.zero`, can be used for barriers.
  /// todo: better doc regarding barrier, onBarrierTap and ignoring strategy
  final Widget? barrier;
  
  //todo: docs
  final _Builder barrierBuilder;

  /// A spring to use with default slidable controller.
  /// If this was specified, [controller] must be null.
  final SpringDescription? springDescription;

  /// Called on tap on [barrier].
  ///
  /// By default, corresponding to [barrierIgnoringStrategy], it can be tapped when
  /// slidable is opening or already opened.
  final VoidCallback? onBarrierTap;

  /// Called when user starts dragging the slidable.
  final SlideStartCallback? onDragStart;

  /// Called on updates of drag on the slidable.
  final SlideUpdateCallback? onDragUpdate;

  /// Called when user ends dragging the slidable.
  final SlideEndCallback? onDragEnd;

  /// Fires whenever value of the [controller] changes.
  final SlideChangeCallback? onSlideChange;

  /// Called on each pointer move event (even before the drag was accepted).
  ///
  /// Return `false` to give up the gesture.
  final ShouldGiveUpCallback? shouldGiveUpGesture;

  ///todo: docs
  final bool disableSlideTransition;

  /// When to ignore the taps on barrier.
  ///
  /// Ignores dismissed and reverse states by default.
  final IgnoringStrategy barrierIgnoringStrategy;

  /// Describes the ability to "catch" currently moving slidable.
  /// If some of the statuses, let's say, [AnimatingIgnoringStrategy.forward] is disabled,
  /// then you won't be able to stop the slidable while it's animating forward.
  final MovingIgnoringStrategy catchIgnoringStrategy;

  /// What [HitTestBehavior] to apply to the gesture detector.
  ///
  /// Defaults to [new HitTestBehaviorStrategy].
  final HitTestBehaviorStrategy hitTestBehaviorStrategy;

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
  /// See also:
  ///
  ///  * [direction], which controls the directions in which the items can
  ///    be slid.
  final double threshold;

  /// todo: macro
  /// 
  /// Determines the way that drag start behavior is handled.
  ///
  /// If set to [DragStartBehavior.start], the drag gesture used to dismiss a
  /// dismissible will begin upon the detection of a drag gesture. If set to
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

/// Describes the fling gesture type.
enum _FlingGestureKind {
  /// Pointer removed with no fling. 
  none,

  /// Flinged with positive velocity.
  forward,

  /// Flinged with negative velocity.
  reverse,
}

// todo: AutomaticKeepAliveClientMixin ???
class SlidableState extends State<Slidable> with TickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    _initController();
    _evaluateStrategies();
    _updateAnimation();
  }

  void _handleChange() {
    widget.onSlideChange?.call(controller.value);
  }

  void _handleStatusChange(AnimationStatus status) {
    setState(() {
      _evaluateStrategies();
    });
  }

  void _initController() {
    if (widget.controller == null) {
      // todo: try to do it with SingleTickerProviderStateMixin (now it doesn allow to creat another ticker after disposing previous one)
      _controller = SlidableController(
        vsync: this,
        springDescription: widget.springDescription,
      );
    } else {
      _controller?.dispose();
      _controller = null;
    }
    controller.addListener(_handleChange);
    controller.addStatusListener(_handleStatusChange);
  }

  void _evaluateStrategies() {
    _ignoringBarrier = widget.barrierIgnoringStrategy.evaluate(controller);
    _hitTestBehavior = widget.hitTestBehaviorStrategy.ask(controller);
  }

  @override
  void didUpdateWidget (covariant Slidable oldWidget) {
    super.didUpdateWidget(oldWidget);
    if(oldWidget.controller != widget.controller) {
      // todo: should we support attaching/unattaching controller? or it should be handled in some other way?
      oldWidget.controller?.removeListener(_handleChange);
      oldWidget.controller?.removeStatusListener(_handleStatusChange);
      _initController();
    }
    if (oldWidget.start != widget.start ||  oldWidget.end != widget.end) {
      _updateAnimation();
    }
    // We don't care about comparing the strategies to check wether they chagned,
    // it's cheaper just to evaluate them again.
    _evaluateStrategies();
  }

  @override
  void dispose() {
    _controller?.dispose();
    controller.removeListener(_handleChange);
    controller.removeStatusListener(_handleStatusChange);
    super.dispose();
  }

  SlidableController? _controller;
  SlidableController get controller => widget.controller ?? _controller!;

  late Animation<Offset> _animation;
  double _dragExtent = 0.0;

  late bool _ignoringBarrier;
  late HitTestBehavior _hitTestBehavior;

  bool get _draggable {
    return widget.direction != SlideDirection.none;
  }

  bool get _horizontal {
    return widget.direction == SlideDirection.left || widget.direction == SlideDirection.right;
  }

  double get _overallDragAxisExtent {
    final Size size = context.size!;
    return _horizontal ? size.width : size.height;
  }

  void _handleDragStart(DragStartDetails details) {
    controller._dragged = true;
    _dragExtent = controller.value * _overallDragAxisExtent;
    if (controller.status == AnimationStatus.forward && !widget.catchIgnoringStrategy.forward ||
        controller.status == AnimationStatus.reverse && !widget.catchIgnoringStrategy.reverse) {
      controller.stop();
    }
    widget.onDragStart?.call(details);
    controller.notifyDragEventListeners(SlidableDragStart(details: details));
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    if (!controller.isActive || controller.isAnimating) return;
    widget.onDragUpdate?.call(details);
    controller.notifyDragEventListeners(SlidableDragUpdate(details: details));

    final double delta = details.primaryDelta!;
    switch (widget.direction) {
      case SlideDirection.left:
        if (_dragExtent + delta < 0)
          _dragExtent += delta;
        break;
      case SlideDirection.right:
        if (_dragExtent + delta > 0)
          _dragExtent += delta;
        break;
      case SlideDirection.up:
        if (_dragExtent + delta < 0)
          _dragExtent += delta;
        break;
      case SlideDirection.down:
        if (_dragExtent + delta > 0)
          _dragExtent += delta;
        break;
      default:
        assert(false);
        break;
    }


    if (!controller.isAnimating) {
      controller.value = _dragExtent.abs() / _overallDragAxisExtent;
    }
  }

  void _updateAnimation() {
    late Offset begin;
    late Offset end;
    if (_horizontal) {
      begin = Offset(widget.start, 0.0);
      end = Offset(widget.end, 0.0);
    } else {
      begin = Offset(0.0, widget.start);
      end = Offset(0.0, widget.end);
    }
    _animation = controller.drive(Tween<Offset>(
      begin: begin,
      end: end,
    ));
  }

  _FlingGestureKind _describeFlingGesture(Velocity velocity) {
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
    // Verify that the fling is in the generally right direction and fast enough.
    if (_horizontal) {
      if (vx.abs() - vy.abs() < _kMinFlingVelocityDelta || vx.abs() < _kMinFlingVelocity)
        return _FlingGestureKind.none;
      assert(vx != 0.0);
    } else {
      if (vy.abs() - vx.abs() < _kMinFlingVelocityDelta || vy.abs() < _kMinFlingVelocity)
        return _FlingGestureKind.none;
      assert(vy != 0.0);
    }
    final double v = _horizontal ? vx : vy;
    final SlideDirection direction = widget.direction;
    if (v.sign > 0.0 && (direction == SlideDirection.right || direction == SlideDirection.down) ||
        v.sign < 0.0 && (direction == SlideDirection.left || direction == SlideDirection.up)) {
      return _FlingGestureKind.forward;
    }
    return _FlingGestureKind.reverse;
  }

  Future<void> _handleDragEnd(DragEndDetails details) async {
    if (!controller.isActive || controller.isAnimating) return;

    controller._dragged = false;
    final double flingVelocity = _horizontal
        ? details.velocity.pixelsPerSecond.dx
        : details.velocity.pixelsPerSecond.dy;
    late final bool closing;
    
    switch (_describeFlingGesture(details.velocity)) {
      case _FlingGestureKind.forward:
        assert(_dragExtent != 0.0);
        assert(!controller.isDismissed);
        if (widget.threshold >= 1.0) {
          controller.fling(velocity: -_kBackToStateVelocity);
          closing = false;
          break;
        }
        _dragExtent = flingVelocity.sign;
        controller.fling(velocity: flingVelocity.abs() * _kFlingVelocityScale);
        closing = true;
        break;
      case _FlingGestureKind.reverse:
        assert(_dragExtent != 0.0);
        assert(!controller.isDismissed);
        _dragExtent = flingVelocity.sign;
        controller.fling(velocity: -flingVelocity.abs() * _kFlingVelocityScale);
        closing = false;
        break;
      case _FlingGestureKind.none:
        if (!controller.isDismissed) {
          // we already know it's not completed, we check that above
          if (controller.value > widget.threshold) {
            controller.fling(velocity: _kBackToStateVelocity);
            closing = true;
          } else {
            controller.fling(velocity: -_kBackToStateVelocity);
            closing = false;
          }
        } else {
          closing = false;
        }
        break;
    }
    widget.onDragEnd?.call(details, closing);
    controller.notifyDragEventListeners(
      SlidableDragEnd(details: details, closing: closing)
    );
  }

  @override
  Widget build(BuildContext context) {
    assert(!_horizontal || debugCheckHasDirectionality(context));

    final Size size = MediaQuery.of(context).size;
    final Widget? barrier = widget.barrier != null
      ? widget.barrierBuilder(controller, widget.barrier!)
      : null;
    // final Widget child = Container(
    //   width: size.width,
    //   height: size.height,
    //   child: widget.childBuilder == null ? widget.child : widget.childBuilder!(controller, widget.child),
    // );
    final Widget child = widget.childBuilder == null ? widget.child : widget.childBuilder!(controller, widget.child);
    final Widget wrappedChild = widget.disableSlideTransition
      ? child
      : SlideTransition(position: _animation, child: child);

    return RepaintBoundary(
      child: RawGestureDetector(
        behavior: _hitTestBehavior,
        gestures: <Type, GestureRecognizerFactory>{
          if (_draggable && _horizontal)
            NFHorizontalDragGestureRecognizer: GestureRecognizerFactoryWithHandlers<NFHorizontalDragGestureRecognizer>(
              () => NFHorizontalDragGestureRecognizer(),
              (NFHorizontalDragGestureRecognizer instance) => instance
                ..onStart = _handleDragStart
                ..onUpdate = _handleDragUpdate
                ..onEnd = _handleDragEnd
                ..dragStartBehavior = widget.dragStartBehavior
                ..shouldGiveUp = widget.shouldGiveUpGesture,
            ),
          if (_draggable && !_horizontal)
            NFVerticalDragGestureRecognizer: GestureRecognizerFactoryWithHandlers<NFVerticalDragGestureRecognizer>(
              () => NFVerticalDragGestureRecognizer(),
              (NFVerticalDragGestureRecognizer instance) => instance
                ..onStart = _handleDragStart
                ..onUpdate = _handleDragUpdate
                ..onEnd = _handleDragEnd
                ..dragStartBehavior = widget.dragStartBehavior
                ..shouldGiveUp = widget.shouldGiveUpGesture,
            ),
        },
        child: barrier == null
          ? wrappedChild
          : () {
              final List<Widget> children = [
                IgnorePointer(
                  ignoring: _ignoringBarrier,
                  child: widget.onBarrierTap == null
                    ? barrier
                    : GestureDetector(
                        onTap: widget.onBarrierTap,
                        behavior: HitTestBehavior.opaque,
                        child: barrier,
                      ),
                ),
                wrappedChild,
              ];
              return _hitTestBehavior == HitTestBehavior.translucent
                  // todo: remove/update this when https://github.com/flutter/flutter/issues/75099 is resolved
                  ? StackWithAllChildrenReceiveEvents(children: children)
                  : Stack(children: children);
            }(),
      ),
    );
  }
}

/// A controller for a [Slidable].
///
/// Provides an ability to listen to the drag events, see [addDragEventListener]/[removeDragEventListener].
///
/// See also:
///  * [Slidable], a widget that allows you to slide it's content
///  * [SlidableControllerProvider], inherited widget that provides access to the controller
class SlidableController extends AnimationController with _DragEventListenersMixin {
  SlidableController({
    double value = 0.0,
    Duration? duration,
    Duration? reverseDuration,
    String? debugLabel,
    double lowerBound = 0.0,
    double upperBound = 1.0,
    SpringDescription? springDescription,
    AnimationBehavior animationBehavior = AnimationBehavior.normal,
    required TickerProvider vsync,
  }) : springDescription = springDescription, 
       super(
         value: value,
         duration: duration,
         reverseDuration: reverseDuration,
         debugLabel: debugLabel,
         lowerBound: lowerBound,
         upperBound: upperBound,
        //  springDescription: springDescription,
         animationBehavior: animationBehavior,
         vsync: vsync,
       );

  bool _dragged = false;

  /// Indicates wether the slidable is currently dragged.
  bool get dragged => _dragged;

  /// Indicates that the slidable is being dragged or it is animating.
  bool get isActive => _dragged || isAnimating;

  /// True when slidable is fully opened, or when it has accepted
  /// a gesture to be opened and currently is animating to this state.
  bool get opened => _dragged || isCompleted || !_dragged && status == AnimationStatus.forward;

  /// True when slidable is fully closed, or when it has accepted
  /// a gesture to be closed and currently is animating to this state.
  bool get closed => isDismissed || !_dragged && status == AnimationStatus.reverse;

  // todo: remove if https://github.com/flutter/flutter/pull/76017 gets merged
  SpringDescription? springDescription;

  @override
  TickerFuture fling({ double velocity = 1.0, SpringDescription? springDescription, AnimationBehavior? animationBehavior }) {
    return super.fling(velocity: velocity, springDescription: springDescription ?? this.springDescription, animationBehavior: animationBehavior);
  }

  /// Calls [fling] with default velocity to end in the [opened] state.
  TickerFuture open({ SpringDescription? springDescription, AnimationBehavior? animationBehavior }) {
    return fling(springDescription: springDescription ?? this.springDescription, animationBehavior: animationBehavior);
  }

  /// Calls [fling] with default velocity to end in the [closed] state.
  TickerFuture close({ SpringDescription? springDescription, AnimationBehavior? animationBehavior }) {
    return fling(velocity: -1.0, springDescription: springDescription ?? this.springDescription, animationBehavior: animationBehavior);
  }
}

/// Provides access to the [SlidableController].
/// 
/// Type parameter [T] is used to distunguish different types of controllers.
class SlidableControllerProvider<T> extends InheritedWidget {
  const SlidableControllerProvider({
    Key? key,
    required this.child,
    required this.controller,
  }) : super(key: key, child: child);

  final Widget child;
  final SlidableController controller;

  static SlidableControllerProvider<T>? of<T>(BuildContext context) {
    return context.getElementForInheritedWidgetOfExactType<SlidableControllerProvider<T>>()?.widget as SlidableControllerProvider<T>?;
  }

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) {
    return false;
  }
}

mixin _DragEventListenersMixin {
  final ObserverList<SlidableDragEventListener> _dragEventListeners = ObserverList<SlidableDragEventListener>();

  void addDragEventListener(SlidableDragEventListener listener) {
    _dragEventListeners.add(listener);
  }

  void removeDragEventListener(SlidableDragEventListener listener) {
    _dragEventListeners.remove(listener);
  }

  void notifyDragEventListeners(SlidableDragEvent event) {
    final List<SlidableDragEventListener> localListeners = List<SlidableDragEventListener>.from(_dragEventListeners);
    for (final SlidableDragEventListener listener in localListeners) {
      if (_dragEventListeners.contains(listener)) listener(event);
    }
  }
}
