/*---------------------------------------------------------------------------------------------
*  Copyright (c) nt4f04und. All rights reserved.
*  Licensed under the BSD-style license. See LICENSE in the project root for license information.
*
*  Copyright (c) Draggable Scrollbar Authors.
*  See ThirdPartyNotices.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import 'scrollbar.dart';

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'dart:math' as math;
import 'package:nt4f04unds_widgets/nt4f04unds_widgets.dart';

/// Build the Scroll Thumb and label using the current configuration
typedef Widget ScrollThumbBuilder(
    Color backgroundColor,
    Animation<double> thumbAnimation,
    double height,
    double width,
    bool shouldAppear);

/// Build a Text widget using the current scroll offset.
///
/// The [progress] is the position ration of the scroll bar.
typedef Widget LabelContentBuilder(double progress);

/// A widget that will display a BoxScrollView with a ScrollThumb that can be dragged
/// for quick navigation of the BoxScrollView.
class NFDraggableScrollbar extends StatefulWidget {
  /// The view that will be scrolled with the scroll thumb
  final Widget child;

  /// A function that builds a thumb using the current configuration
  final ScrollThumbBuilder scrollThumbBuilder;

  /// The height of the scroll thumb
  final double heightScrollThumb;

  /// The width of the scroll thumb
  final double widthScrollThumb;

  /// Margin for thumb from top
  final double marginBottom;

  /// Margin for thumb from bottom
  final double marginTop;

  /// The background color of the label and thumb
  final Color backgroundColor;

  /// The amount of padding that should surround the thumb
  final EdgeInsetsGeometry padding;

  /// Determines how quickly the scrollbar will animate in and out
  final Duration scrollbarAnimationDuration;

  /// How long should the thumb be visible before fading out
  final Duration scrollbarTimeToFade;

  /// Build a Widget from the current offset in the BoxScrollView
  final LabelContentBuilder labelContentBuilder;

  /// The ScrollController for the BoxScrollView
  final ScrollController controller;

  /// Determines scrollThumb displaying. If you draw own ScrollThumb and it is true you just don't need to use animation parameters in [scrollThumbBuilder]
  final bool alwaysVisibleScrollThumb;

  NFDraggableScrollbar({
    Key key,
    this.alwaysVisibleScrollThumb = false,
    @required this.heightScrollThumb,
    @required this.backgroundColor,
    @required this.scrollThumbBuilder,
    @required this.child,
    @required this.controller,
    this.widthScrollThumb,
    this.marginBottom = 0.0,
    this.marginTop = 0.0,
    this.padding,
    this.scrollbarAnimationDuration = kScrollbarFadeDuration,
    this.scrollbarTimeToFade = kScrollbarTimeToFade,
    this.labelContentBuilder,
  })  : assert(controller != null),
        assert(scrollThumbBuilder != null),
        super(key: key);

  NFDraggableScrollbar.rrect({
    Key key,
    Key scrollThumbKey,
    this.alwaysVisibleScrollThumb = false,
    @required this.child,
    @required this.controller,
    this.heightScrollThumb = 48.0,
    this.widthScrollThumb = 16.0,
    this.marginBottom = 0.0,
    this.marginTop = 0.0,
    this.backgroundColor = Colors.white,
    this.padding,
    this.scrollbarAnimationDuration = kScrollbarFadeDuration,
    this.scrollbarTimeToFade = kScrollbarTimeToFade,
    this.labelContentBuilder,
    BorderRadiusGeometry borderRadius =
        const BorderRadius.all(Radius.circular(0.0)),
  })  : scrollThumbBuilder = _thumbRRectBuilder(
            scrollThumbKey, alwaysVisibleScrollThumb, borderRadius),
        super(key: key);

  NFDraggableScrollbar.arrows({
    Key key,
    Key scrollThumbKey,
    this.alwaysVisibleScrollThumb = false,
    @required this.child,
    @required this.controller,
    this.heightScrollThumb = 48.0,
    this.widthScrollThumb = 20.0,
    this.marginBottom = 0.0,
    this.marginTop = 0.0,
    this.backgroundColor = Colors.white,
    this.padding,
    this.scrollbarAnimationDuration = kScrollbarFadeDuration,
    this.scrollbarTimeToFade = kScrollbarTimeToFade,
    this.labelContentBuilder,
  })  : scrollThumbBuilder =
            _thumbArrowBuilder(scrollThumbKey, alwaysVisibleScrollThumb),
        super(key: key);

  NFDraggableScrollbar.semicircle({
    Key key,
    Key scrollThumbKey,
    this.alwaysVisibleScrollThumb = false,
    @required this.child,
    @required this.controller,
    this.heightScrollThumb = 48.0,
    this.widthScrollThumb,
    this.marginBottom = 0.0,
    this.marginTop = 0.0,
    this.backgroundColor = Colors.white,
    this.padding,
    this.scrollbarAnimationDuration = kScrollbarFadeDuration,
    this.scrollbarTimeToFade = kScrollbarTimeToFade,
    this.labelContentBuilder,
  })  : scrollThumbBuilder =
            _thumbSemicircleBuilder(scrollThumbKey, alwaysVisibleScrollThumb),
        super(key: key);

  @override
  _NFDraggableScrollbarState createState() => _NFDraggableScrollbarState();

  static buildScrollThumbAnimation({
    @required Widget scrollThumb,
    @required Animation<double> thumbAnimation,
    @required bool alwaysVisibleScrollThumb,
  }) {
    if (alwaysVisibleScrollThumb) {
      return scrollThumb;
    }
    return FadeTransition(
      opacity: thumbAnimation,
      child: scrollThumb,
    );
  }

  static ScrollThumbBuilder _thumbSemicircleBuilder(
      Key scrollThumbKey, bool alwaysVisibleScrollThumb) {
    return (
      Color backgroundColor,
      Animation<double> thumbAnimation,
      double height,
      double width,
      bool shouldAppear, {
      Widget labelContent,
      BoxConstraints labelConstraints,
    }) {
      final scrollThumb = CustomPaint(
        key: scrollThumbKey,
        foregroundPainter: ArrowCustomPainter(Colors.grey),
        child: Material(
          elevation: 4.0,
          child: Container(
            constraints: BoxConstraints.tight(Size(width, height * 0.6)),
          ),
          color: backgroundColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(height),
            bottomLeft: Radius.circular(height),
            topRight: Radius.circular(4.0),
            bottomRight: Radius.circular(4.0),
          ),
        ),
      );

      return buildScrollThumbAnimation(
        scrollThumb: scrollThumb,
        thumbAnimation: thumbAnimation,
        alwaysVisibleScrollThumb: shouldAppear && alwaysVisibleScrollThumb,
      );
    };
  }

  static ScrollThumbBuilder _thumbArrowBuilder(
      Key scrollThumbKey, bool alwaysVisibleScrollThumb) {
    return (
      Color backgroundColor,
      Animation<double> thumbAnimation,
      double height,
      double width,
      bool shouldAppear, {
      Widget labelContent,
      BoxConstraints labelConstraints,
    }) {
      final scrollThumb = ClipPath(
        child: Container(
          height: height,
          width: width,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.all(
              Radius.circular(12.0),
            ),
          ),
        ),
        clipper: ArrowClipper(),
      );

      return buildScrollThumbAnimation(
        scrollThumb: scrollThumb,
        thumbAnimation: thumbAnimation,
        alwaysVisibleScrollThumb: shouldAppear && alwaysVisibleScrollThumb,
      );
    };
  }

  static ScrollThumbBuilder _thumbRRectBuilder(Key scrollThumbKey,
      bool alwaysVisibleScrollThumb, BorderRadiusGeometry borderRadius) {
    return (
      Color backgroundColor,
      Animation<double> thumbAnimation,
      double height,
      double width,
      bool shouldAppear, {
      Widget labelContent,
      BoxConstraints labelConstraints,
    }) {
      final scrollThumb = Material(
          key: scrollThumbKey,
          elevation: 4.0,
          child: Container(
            constraints: BoxConstraints.tight(
              Size(width, height),
            ),
          ),
          color: backgroundColor,
          borderRadius: borderRadius);

      return buildScrollThumbAnimation(
        scrollThumb: scrollThumb,
        thumbAnimation: thumbAnimation,
        alwaysVisibleScrollThumb: shouldAppear && alwaysVisibleScrollThumb,
      );
    };
  }
}

class ScrollLabel extends StatelessWidget {
  final Animation<double> animation;
  final Color backgroundColor;
  final Widget child;

  final BoxConstraints constraints;
  static const BoxConstraints _defaultConstraints =
      BoxConstraints.tightFor(width: 72.0, height: 28.0);

  const ScrollLabel({
    Key key,
    @required this.child,
    @required this.animation,
    @required this.backgroundColor,
    this.constraints = _defaultConstraints,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: animation,
      child: Container(
        margin: const EdgeInsets.only(right: 6.0),
        child: Material(
          elevation: 20.0,
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.all(Radius.circular(11.0)),
          child: Container(
            constraints: constraints ?? _defaultConstraints,
            padding: const EdgeInsets.only(left: 12.0, right: 12.0),
            alignment: Alignment.centerLeft,
            child: child,
          ),
        ),
      ),
    );
  }
}

class _NFDraggableScrollbarState extends State<NFDraggableScrollbar>
    with TickerProviderStateMixin {
  double _barOffset;
  double _viewOffset;
  bool _isDragInProcess;

  AnimationController _thumbAnimationController;
  Animation<double> _thumbAnimation;
  AnimationController _labelAnimationController;
  Animation<double> _labelAnimation;
  Timer _fadeoutThumbTimer;
  Timer _fadeoutLabelTimer;

  double get barMaxScrollExtent =>
      context.size.height - widget.heightScrollThumb - widget.marginBottom;

  double get barMinScrollExtent => 0.0 + widget.marginTop;

  double get viewMaxScrollExtent => widget.controller.position.maxScrollExtent;

  /// Whether the scrollbar should appear on the screen
  bool get shouldAppear =>
      widget.controller.hasClients &&
      widget.controller.position.maxScrollExtent > 300.0;

  @override
  void initState() {
    super.initState();
    _barOffset = barMinScrollExtent;
    _viewOffset = 0.0;
    _isDragInProcess = false;

    _thumbAnimationController = AnimationController(
      vsync: this,
      duration: widget.scrollbarAnimationDuration,
    );
    _labelAnimationController = AnimationController(
      vsync: this,
      duration: widget.scrollbarAnimationDuration,
    );

    _thumbAnimation = DefaultAnimation(parent: _thumbAnimationController);
    _labelAnimation = DefaultAnimation(parent: _labelAnimationController);

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      /// Call setState to make shouldAppear getter available
      setState(() {});
    });
  }

  @override
  void dispose() {
    _thumbAnimationController.dispose();
    _fadeoutThumbTimer?.cancel();
    _fadeoutLabelTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget labelContent;
    if (widget.labelContentBuilder != null) {
      labelContent = widget.labelContentBuilder(
        _viewOffset + _barOffset + widget.heightScrollThumb / 2,
      );
    }

    return !shouldAppear
        ? widget.child
        : LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
            return NotificationListener<ScrollNotification>(
              onNotification: _handleScrollNotification,
              child: Stack(
                children: <Widget>[
                  RepaintBoundary(
                    child: widget.child,
                  ),
                  RepaintBoundary(
                    child: Stack(
                      children: [
                        if (labelContent != null)
                          Center(
                            // Label
                            child: FadeTransition(
                              opacity: _labelAnimation,
                              child: labelContent,
                            ),
                          ),
                        Positioned(
                          // Background pad
                          right: 0.0,
                          top: 0.0,
                          child: GestureDetector(
                            onTapDown: _onScrollbarBackgroundTapDown,
                            onVerticalDragStart:
                                _onScrollbarBackgroundVerticalDragStart,
                            onVerticalDragUpdate: _onVerticalDragUpdate,
                            onVerticalDragEnd: _onVerticalDragEnd,
                            child: Container(
                              color: Colors.transparent,
                              width: widget.widthScrollThumb,
                              height: MediaQuery.of(context).size.height,
                            ),
                          ),
                        ),
                        GestureDetector(
                          // Thumb itself
                          onVerticalDragStart: _onVerticalDragStart,
                          onVerticalDragUpdate: _onVerticalDragUpdate,
                          onVerticalDragEnd: _onVerticalDragEnd,
                          child: Container(
                            alignment: Alignment.topRight,
                            margin: EdgeInsets.only(top: _barOffset),
                            padding: widget.padding,
                            child: widget.scrollThumbBuilder(
                              widget.backgroundColor,
                              _thumbAnimation,
                              widget.heightScrollThumb,
                              widget.widthScrollThumb,
                              shouldAppear,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          });
  }

  //scroll bar has received notification that it's view was scrolled
  //so it should also changes his position
  //but only if it isn't dragged
  bool _handleScrollNotification(ScrollNotification notification) {
    if (_isDragInProcess ||
        notification.metrics.maxScrollExtent <
            notification.metrics.minScrollExtent) {
      return false;
    }

    setState(() {
      if (notification is ScrollUpdateNotification) {
        _viewOffset += notification.scrollDelta;
        if (_viewOffset < widget.controller.position.minScrollExtent) {
          _viewOffset = widget.controller.position.minScrollExtent;
        }
        if (_viewOffset > viewMaxScrollExtent) {
          _viewOffset = viewMaxScrollExtent;
        }

        _barOffset = _viewOffset *
                (barMaxScrollExtent - barMinScrollExtent) /
                viewMaxScrollExtent +
            barMinScrollExtent;
      }

      if (notification is ScrollUpdateNotification ||
          notification is OverscrollNotification) {
        if (shouldAppear &&
            _thumbAnimationController.status != AnimationStatus.forward) {
          _thumbAnimationController.forward();
        }

        _fadeoutThumbTimer?.cancel();

        _fadeoutThumbTimer =
            Timer(applyDilation(widget.scrollbarTimeToFade), () {
          _thumbAnimationController.reverse();
          _fadeoutThumbTimer = null;
        });
      }
    });

    return false;
  }

  /// Handles tap down specifically on the background of the scrollbar area.
  void _onScrollbarBackgroundTapDown(TapDownDetails details) {
    setState(() {
      _isDragInProcess = true;
      _thumbAnimationController.forward();
      _labelAnimationController.forward();

      _fadeoutThumbTimer?.cancel();
      _fadeoutLabelTimer?.cancel();

      _barOffset = math.max(
        0.0,
        details.localPosition.dy - widget.heightScrollThumb / 2,
      );
    });
    _updateView();
  }

  /// Handles drag start specifically on the background of the scrollbar area.
  void _onScrollbarBackgroundVerticalDragStart(DragStartDetails details) {
    setState(() {
      _isDragInProcess = true;
      _thumbAnimationController.forward();
      _labelAnimationController.forward();

      _fadeoutThumbTimer?.cancel();
      _fadeoutLabelTimer?.cancel();

      _barOffset = math.max(
        0.0,
        details.localPosition.dy - widget.heightScrollThumb / 2,
      );
    });
    _updateView();
  }

  void _onVerticalDragStart(DragStartDetails details) {
    setState(() {
      _isDragInProcess = true;
      _thumbAnimationController.forward();
      _labelAnimationController.forward();

      _fadeoutThumbTimer?.cancel();
      _fadeoutLabelTimer?.cancel();
    });
    _updateView();
  }

  void _updateView() {
    _viewOffset = (_barOffset - barMinScrollExtent) *
        (viewMaxScrollExtent +
            barMinScrollExtent * viewMaxScrollExtent / barMaxScrollExtent) /
        barMaxScrollExtent;

    widget.controller.jumpTo(_viewOffset);
  }

  void _onVerticalDragUpdate(DragUpdateDetails details) {
    setState(() {
      if (_thumbAnimationController.status != AnimationStatus.forward) {
        _thumbAnimationController.forward();
        _labelAnimationController.forward();
      }
      if (_isDragInProcess) {
        _barOffset += details.delta.dy;

        if (_barOffset < barMinScrollExtent) {
          _barOffset = barMinScrollExtent;
        }
        if (_barOffset > barMaxScrollExtent) {
          _barOffset = barMaxScrollExtent;
        }

        _updateView();
      }
    });
  }

  Future<void> _onVerticalDragEnd(DragEndDetails details) async {
    _isDragInProcess = false;

    _fadeoutThumbTimer = Timer(applyDilation(widget.scrollbarTimeToFade), () {
      _thumbAnimationController.reverse();
      _fadeoutThumbTimer =
          Timer(applyDilation(widget.scrollbarAnimationDuration), () {
        setState(() {});
        _fadeoutThumbTimer = null;
      });
    });

    _fadeoutLabelTimer = Timer(applyDilation(kScrollbarLabelTimeToFade), () {
      _labelAnimationController.reverse();
      _fadeoutLabelTimer = Timer(applyDilation(kScrollbarLabelTimeToFade), () {
        setState(() {});
        _fadeoutLabelTimer = null;
      });
    });
  }
}

/// Draws 2 triangles like arrow up and arrow down.
class ArrowCustomPainter extends CustomPainter {
  Color color;

  ArrowCustomPainter(this.color);

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    const width = 12.0;
    const height = 8.0;
    final baseX = size.width / 2;
    final baseY = size.height / 2;

    canvas.drawPath(
      _trianglePath(Offset(baseX, baseY - 2.0), width, height, true),
      paint,
    );
    canvas.drawPath(
      _trianglePath(Offset(baseX, baseY + 2.0), width, height, false),
      paint,
    );
  }

  static Path _trianglePath(Offset o, double width, double height, bool isUp) {
    return Path()
      ..moveTo(o.dx, o.dy)
      ..lineTo(o.dx + width, o.dy)
      ..lineTo(o.dx + (width / 2), isUp ? o.dy - height : o.dy + height)
      ..close();
  }
}

///This cut 2 lines in arrow shape.
class ArrowClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0.0, size.height);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width, 0.0);
    path.lineTo(0.0, 0.0);
    path.close();

    double arrowWidth = 8.0;
    double startPointX = (size.width - arrowWidth) / 2;
    double startPointY = size.height / 2 - arrowWidth / 2;
    path.moveTo(startPointX, startPointY);
    path.lineTo(startPointX + arrowWidth / 2, startPointY - arrowWidth / 2);
    path.lineTo(startPointX + arrowWidth, startPointY);
    path.lineTo(startPointX + arrowWidth, startPointY + 1.0);
    path.lineTo(
        startPointX + arrowWidth / 2, startPointY - arrowWidth / 2 + 1.0);
    path.lineTo(startPointX, startPointY + 1.0);
    path.close();

    startPointY = size.height / 2 + arrowWidth / 2;
    path.moveTo(startPointX + arrowWidth, startPointY);
    path.lineTo(startPointX + arrowWidth / 2, startPointY + arrowWidth / 2);
    path.lineTo(startPointX, startPointY);
    path.lineTo(startPointX, startPointY - 1.0);
    path.lineTo(
        startPointX + arrowWidth / 2, startPointY + arrowWidth / 2 - 1.0);
    path.lineTo(startPointX + arrowWidth, startPointY - 1.0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
