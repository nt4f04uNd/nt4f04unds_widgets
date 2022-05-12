/*---------------------------------------------------------------------------------------------
*  Copyright (c) nt4f04und. All rights reserved.
*  Licensed under the BSD-style license. See LICENSE in the project root for license information.
*
*  Copyright (c) Draggable Scrollbar Authors.
*  See ThirdPartyNotices.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:nt4f04unds_widgets/nt4f04unds_widgets.dart';
import 'dart:math' as math;

/// Build the bar and label using the current configuration.
typedef Widget BarBuilder(Color barColor, Animation<double> animation, double height, double width);

/// Signature used to build a label widget.
///
/// The [progress] is the value from `0.0` to `1.0` denoting the current bar position relative to
/// the offset that bar can have.
///
/// The [barPadHeight] is the height of the whole bar. It's not the same as max bar offset, as max
/// bar offset also repects the margins and the bar height.
///
/// Used by [NFDraggableScrollbar.labelBuilder].
typedef Widget LabelBuilder(BuildContext context, double progress, double barPadHeight);

/// Signature used to build a label animation.
///
/// Used by [NFDraggableScrollbar.labelTransitionBuilder].
typedef Widget LabelTransitionBuilder(BuildContext context, Animation<double> animation, Widget child);

/// Signature for drag callbacks.
///
/// The [progress] is the value from `0.0` to `1.0` denoting the current bar position relative to
/// the offset that bar can have.
///
/// The [barPadHeight] is the height of the whole bar. It's not the same as max bar offset, as max
/// bar offset also repects the margins and the bar height.
///
/// Used by
///  * [NFDraggableScrollbar.onDragStart]
///  * [NFDraggableScrollbar.onDragUpdate]
///  * [NFDraggableScrollbar.onDragEnd]
///  * [NFDraggableScrollbar.onScrollNotification]
typedef void DraggableScrollBarCallback(double progress, double barPadHeight);

/// A widget that will display a child with a ScrollBar that can be dragged.
///
/// Note that for the internal extent to be updated, the widget has to receive
/// a [ScrollNotification] from its child. On the first render it is always 0,
/// so if you want to set an initial index of some ListView, consider doing so
/// through it's controller, so that the scrollbar could listen to its notification
/// and update appropiately.
///
/// todo: horizontal support
class NFDraggableScrollbar extends StatefulWidget {
  /// The view that the scroll bar will receieve scroll notifications from.
  final Widget child;

  /// The height of the scroll bar.
  final double barHeight;

  /// The width of the scroll bar.
  final double barWidth;

  /// Margin for bar from top.
  final double barTopMargin;

  /// Margin for bar from bottom.
  final double barBottomMargin;

  /// The background color of the label and bar.
  final Color barColor;

  /// The amount of padding that should surround the bar.
  final EdgeInsetsGeometry? barPadding;

  /// Determines how quickly the scrollbar will animate in and out.
  final Duration barAnimationDuration;

  /// How long should the bar be visible before fading out.
  final Duration barDuration;

  /// The widget as a touchable pad behind the bar.
  ///
  /// If none specified, than default transparent container of
  /// width of the bar will be used.
  final Widget? barPad;

  /// A function that builds a bar using the current configuration.
  final BarBuilder barBuilder;

  /// Builds a label widget.
  ///
  /// The first parameter [progress] is the value from `0.0` to `1.0` denoting the current bar position relative to
  /// the seconds one offset that bar can have.
  ///
  /// The [barPadHeight] is the height of the whole bar. It's not the same as max bar offset, as max
  /// bar offset also repects the margins and the bar height.
  final LabelBuilder? labelBuilder;

  /// Builds a label animation.
  ///
  /// By default, it's a simple [FadeTransition].
  final LabelTransitionBuilder labelTransitionBuilder;

  /// Called when user start draging the bar or tap-downs the bar pad.
  ///
  /// The first parameter [progress] is the value from `0.0` to `1.0` denoting the current bar position relative to
  /// the seconds one offset that bar can have.
  ///
  /// The [barPadHeight] is the height of the whole bar. It's not the same as max bar offset, as max
  /// bar offset also repects the margins and the bar height.
  final DraggableScrollBarCallback? onDragStart;

  /// Called when user drags the bar.
  ///
  /// The first parameter [progress] is the value from `0.0` to `1.0` denoting the current bar position relative to
  /// the seconds one offset that bar can have.
  ///
  /// The [barPadHeight] is the height of the whole bar. It's not the same as max bar offset, as max
  /// bar offset also repects the margins and the bar height.
  final DraggableScrollBarCallback? onDragUpdate;

  /// Called when user ends draging the bar or tap-ups the bar pad.
  ///
  /// The first parameter [progress] is the value from `0.0` to `1.0` denoting the current bar position relative to
  /// the seconds one offset that bar can have.
  ///
  /// The [barPadHeight] is the height of the whole bar. It's not the same as max bar offset, as max
  /// bar offset also repects the margins and the bar height.
  final DraggableScrollBarCallback? onDragEnd;

  /// Called when the scroll notification is received and the position of the bar is updated.
  ///
  /// The first parameter [progress] is the value from `0.0` to `1.0` denoting the current bar position relative to
  /// the seconds one offset that bar can have.
  ///
  /// The [barPadHeight] is the height of the whole bar. It's not the same as max bar offset, as max
  /// bar offset also repects the margins and the bar height.
  final DraggableScrollBarCallback? onScrollNotification;

  /// If true, the scrollbar will be hidden, when scroll view is not scrolled,
  /// and will only appear when it is.
  final bool appearOnlyOnScroll;

  /// Whether the scrollbar should appear on the screen.
  /// For example you can set it to `false` for small amount of items.
  ///
  /// Defaults to `true`.
  final bool shouldAppear;

  NFDraggableScrollbar({
    Key? key,
    required this.barHeight,
    required this.barWidth,
    required this.barColor,
    required this.barBuilder,
    required this.child,
    this.barPad,
    this.barTopMargin = 0.0,
    this.barBottomMargin = 0.0,
    this.barPadding,
    this.barAnimationDuration = kScrollbarFadeDuration,
    this.barDuration = kScrollbarTimeToFade,
    this.labelBuilder,
    this.labelTransitionBuilder = defaultLabelTransitionBuilder,
    this.onDragStart,
    this.onDragUpdate,
    this.onDragEnd,
    this.onScrollNotification,
    this.appearOnlyOnScroll = false,
    this.shouldAppear = true,
  })  : assert(barHeight != null),
        assert(barWidth != null),
        assert(barColor != null),
        assert(barBuilder != null),
        super(key: key);

  NFDraggableScrollbar.rrect({
    Key? key,
    Key? barKey,
    required this.child,
    this.barPad,
    this.barHeight = 48.0,
    this.barWidth = 16.0,
    this.barTopMargin = 0.0,
    this.barBottomMargin = 0.0,
    this.barColor = Colors.white,
    this.barPadding,
    this.barAnimationDuration = kScrollbarFadeDuration,
    this.barDuration = kScrollbarTimeToFade,
    this.labelBuilder,
    this.labelTransitionBuilder = defaultLabelTransitionBuilder,
    this.onDragStart,
    this.onDragUpdate,
    this.onDragEnd,
    this.onScrollNotification,
    this.appearOnlyOnScroll = false,
    this.shouldAppear = true,
    BorderRadiusGeometry borderRadius = const BorderRadius.all(Radius.circular(0.0)),
  })  : barBuilder = _barRRectBuilder(barKey, appearOnlyOnScroll, borderRadius),
        super(key: key);

  NFDraggableScrollbar.arrows({
    Key? key,
    Key? barKey,
    required this.child,
    this.barPad,
    this.barHeight = 48.0,
    this.barWidth = 20.0,
    this.barTopMargin = 0.0,
    this.barBottomMargin = 0.0,
    this.barColor = Colors.white,
    this.barPadding,
    this.barAnimationDuration = kScrollbarFadeDuration,
    this.barDuration = kScrollbarTimeToFade,
    this.labelBuilder,
    this.labelTransitionBuilder = defaultLabelTransitionBuilder,
    this.onDragStart,
    this.onDragUpdate,
    this.onDragEnd,
    this.onScrollNotification,
    this.appearOnlyOnScroll = false,
    this.shouldAppear = true,
  })  : barBuilder = _barArrowBuilder(barKey, appearOnlyOnScroll),
        super(key: key);

  NFDraggableScrollbar.semicircle({
    Key? key,
    Key? barKey,
    required this.child,
    this.barPad,
    this.barHeight = 48.0,
    this.barWidth = 48.0,
    this.barTopMargin = 0.0,
    this.barBottomMargin = 0.0,
    this.barColor = Colors.white,
    this.barPadding,
    this.barAnimationDuration = kScrollbarFadeDuration,
    this.barDuration = kScrollbarTimeToFade,
    this.labelBuilder,
    this.labelTransitionBuilder = defaultLabelTransitionBuilder,
    this.onDragStart,
    this.onDragUpdate,
    this.onDragEnd,
    this.onScrollNotification,
    this.appearOnlyOnScroll = false,
    this.shouldAppear = true,
  })  : barBuilder = _barSemicircleBuilder(barKey, appearOnlyOnScroll),
        super(key: key);

  @override
  NFDraggableScrollbarState createState() => NFDraggableScrollbarState();

  static buildScrollBarAnimation({
    required Widget bar,
    required Animation<double> barAnimation,
    required bool appearOnlyOnScroll,
  }) {
    if (appearOnlyOnScroll) {
      return FadeTransition(
        opacity: barAnimation,
        child: bar,
      );
    }
    return bar;
  }

  static Widget defaultLabelTransitionBuilder(BuildContext context, Animation<double> animation, Widget child) {
    return FadeTransition(
      opacity: CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      ),
      child: child,
    );
  }

  static BarBuilder _barSemicircleBuilder(Key? barKey, bool appearOnlyOnScroll) {
    return (Color barColor, Animation<double> barAnimation, double height, double width) {
      final bar = CustomPaint(
        key: barKey,
        foregroundPainter: ArrowCustomPainter(Colors.grey),
        child: Material(
          elevation: 4.0,
          child: Container(
            constraints: BoxConstraints.tight(Size(width, height * 0.6)),
          ),
          color: barColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(height),
            bottomLeft: Radius.circular(height),
            topRight: Radius.circular(4.0),
            bottomRight: Radius.circular(4.0),
          ),
        ),
      );
      return buildScrollBarAnimation(
        bar: bar,
        barAnimation: barAnimation,
        appearOnlyOnScroll: appearOnlyOnScroll,
      );
    };
  }

  static BarBuilder _barArrowBuilder(Key? barKey, bool appearOnlyOnScroll) {
    return (Color barColor, Animation<double> animation, double height, double width) {
      final bar = ClipPath(
        child: Container(
          height: height,
          width: width,
          decoration: BoxDecoration(
            color: barColor,
            borderRadius: BorderRadius.all(
              Radius.circular(12.0),
            ),
          ),
        ),
        clipper: ArrowClipper(),
      );
      return buildScrollBarAnimation(
        bar: bar,
        barAnimation: animation,
        appearOnlyOnScroll: appearOnlyOnScroll,
      );
    };
  }

  static BarBuilder _barRRectBuilder(Key? barKey, bool appearOnlyOnScroll, BorderRadiusGeometry borderRadius) {
    return (Color barColor, Animation<double> animation, double height, double width) {
      final bar = Material(
        key: barKey,
        elevation: 4.0,
        child: Container(
          constraints: BoxConstraints.tight(Size(width, height)),
        ),
        color: barColor,
        borderRadius: borderRadius,
      );
      return buildScrollBarAnimation(
        bar: bar,
        barAnimation: animation,
        appearOnlyOnScroll: appearOnlyOnScroll,
      );
    };
  }
}

class NFDraggableScrollbarState extends State<NFDraggableScrollbar> with TickerProviderStateMixin {
  bool dragged = false;

  late AnimationController barController;
  late AnimationController labelController;
  Timer? _fadeoutBarTimer;
  Timer? _fadeoutLabelTimer;

  double _barOffset = 0.0;
  double _barPadHeight = 0.0;
  double _barMaxOffset = 0.0;
  double get barProgress => _barMaxOffset == 0.0 ? 0.0 : _barOffset / _barMaxOffset;

  /// The actual max extent.
  ///
  /// For example in [ScrollablePositionedList] after it [jumpTo] item
  /// the min scroll extent equals the negative extent before the new position after jump
  /// and the max scroll extent equals the positive extent after it.
  ///
  /// So I justfiy the value of max extent to be in range from `0.0` to `maxScrollExtent - minScrollExtent`.
  double _viewMaxOffset = 0.0;
  double _viewOffset = 0.0;

  @override
  void initState() {
    super.initState();
    barController = AnimationController(
      vsync: this,
      duration: widget.barAnimationDuration,
    );
    labelController = AnimationController(
      vsync: this,
      duration: widget.barAnimationDuration,
    );

    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      /// Call setState to make shouldAppear getter available, as
      /// at the first render [_viewMaxOffset] is `0.0`
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    barController.dispose();
    labelController.dispose();
    _fadeoutBarTimer?.cancel();
    _fadeoutLabelTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      // Update the max offset after each build.
      _barPadHeight = context.size!.height;
      _barMaxOffset = _barPadHeight -
          widget.barHeight -
          widget.barTopMargin -
          widget.barBottomMargin;
    });
    
    final Widget? label = widget.labelBuilder?.call(context, barProgress, _barPadHeight);
    final barAnimation = CurvedAnimation(
      parent: barController,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );

    return !widget.shouldAppear
        ? widget.child
        : LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
            return NotificationListener<ScrollNotification>(
              onNotification: _handleScrollNotification,
              child: Stack(
                children: <Widget>[
                  RepaintBoundary(child: widget.child),
                  RepaintBoundary(
                    child: Stack(
                      children: [
                        // Label
                        if (label != null)
                          widget.labelTransitionBuilder(
                            context,
                            labelController,
                            label,
                          ),
                        // Bar pad
                        Positioned(
                          right: 0.0,
                          top: 0.0,
                          child: GestureDetector(
                            onTapDown: _onBarPadTapDown,
                            onTapUp: (_) => _onEnd(),
                            onVerticalDragStart: _onBarPadVerticalDragStart,
                            onVerticalDragUpdate: _onVerticalDragUpdate,
                            onVerticalDragEnd: (_) => _onEnd(),
                            child: widget.barPad ??
                                Container(
                                  color: Colors.transparent,
                                  width: widget.barWidth,
                                  height: MediaQuery.of(context).size.height,
                                ),
                          ),
                        ),
                        // Bar itself
                        GestureDetector(
                          onVerticalDragStart: _onVerticalDragStart,
                          onVerticalDragUpdate: _onVerticalDragUpdate,
                          onVerticalDragEnd: (_) => _onEnd(),
                          child: Container(
                            alignment: Alignment.topRight,
                            margin: EdgeInsets.only(
                              top: math.max(0.0, widget.barTopMargin + _barOffset),
                              bottom: widget.barBottomMargin,
                            ),
                            padding: widget.barPadding,
                            child: widget.barBuilder(
                              widget.barColor,
                              barAnimation,
                              /// Force sending proper height to the builder function.
                              ///
                              /// This will take place in case of bouncing scroll physics.
                              /// In fact the `- math.max(0.0, _barOffset - _barMaxOffset)`
                              /// is not needed to display proper bar, because it's treated automaticlly,
                              /// as it reaches the bottom edge of the screen.
                              ///
                              /// Thought I do this for sake of if someone decides to use these values
                              /// for some computations.
                              widget.barHeight + math.min(0.0, _barOffset) - math.max(0.0, _barOffset - _barMaxOffset),
                              widget.barWidth,
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

  void _showBar() {
    if (barController.status != AnimationStatus.forward) {
      barController.forward();
    }
    _fadeoutBarTimer?.cancel();
  }

  void _showLabel() {
    if (labelController.status != AnimationStatus.forward) {
      labelController.forward();
    }
    _fadeoutLabelTimer?.cancel();
  }

  // Scroll bar has received notification that it's view was scrolled
  // So it should also changes his position
  // But only if it isn't dragged
  bool _handleScrollNotification(ScrollNotification notification) {
    _viewMaxOffset = notification.metrics.maxScrollExtent - notification.metrics.minScrollExtent;
    assert(_viewMaxOffset >= 0.0);
    if (dragged) {
      return false;
    }
    setState(() {
      if (notification is ScrollUpdateNotification) {
        _viewOffset = notification.metrics.pixels - notification.metrics.minScrollExtent;
        _barOffset = _viewOffset / _viewMaxOffset * _barMaxOffset;
      }

      if (notification is ScrollUpdateNotification ||
          notification is OverscrollNotification) {
        if (widget.shouldAppear) {
          if (widget.appearOnlyOnScroll &&
              barController.status != AnimationStatus.forward) {
            barController.forward();
            _fadeoutBarTimer?.cancel();
            _fadeoutBarTimer = Timer(dilate(widget.barDuration), () {
              barController.reverse();
              _fadeoutBarTimer = null;
            });
          }
        }
      }
    });

    widget.onScrollNotification?.call(barProgress, _barPadHeight);
    return false;
  }

  /// Handles tap down specifically on the background of the scrollbar area.
  void _onBarPadTapDown(TapDownDetails details) {
    setState(() {
      dragged = true;
      _showBar();
      _showLabel();
      _barOffset = (details.localPosition.dy - widget.barHeight / 2).clamp(0.0, _barMaxOffset);
    });
    widget.onDragStart?.call(barProgress, _barPadHeight);
  }

  /// Handles drag start specifically on the background of the scrollbar area.
  void _onBarPadVerticalDragStart(DragStartDetails details) {
    setState(() {
      dragged = true;
      _showBar();
      _showLabel();
      _barOffset = (details.localPosition.dy - widget.barHeight / 2).clamp(0.0, _barMaxOffset);
    });
    widget.onDragStart?.call(barProgress, _barPadHeight);
  }

  void _onVerticalDragStart(DragStartDetails details) {
    widget.onDragStart?.call(barProgress, _barPadHeight);
    setState(() {
      dragged = true;
      _showBar();
      _showLabel();
    });
  }

  void _onVerticalDragUpdate(DragUpdateDetails details) {
    if (barController.status != AnimationStatus.forward) {
      barController.forward();
    }
    if (labelController.status != AnimationStatus.forward) {
      labelController.forward();
    }
    setState(() {
      if (dragged) {
        _barOffset = (_barOffset + details.delta.dy).clamp(0.0, _barMaxOffset);
      }
    });
    widget.onDragUpdate?.call(barProgress, _barPadHeight);
  }

  void _onEnd() {
    widget.onDragEnd?.call(barProgress, _barPadHeight);
    dragged = false;

    _fadeoutBarTimer = Timer(dilate(widget.barDuration), () {
      barController.reverse();
      _fadeoutBarTimer = Timer(dilate(widget.barAnimationDuration), () {
        setState(() {});
        _fadeoutBarTimer = null;
      });
    });

    _fadeoutLabelTimer = Timer(dilate(kScrollbarLabelTimeToFade), () {
      labelController.reverse();
      _fadeoutLabelTimer = Timer(dilate(kScrollbarLabelTimeToFade), () {
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

/// This cut 2 lines in arrow shape.
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
    path.lineTo(startPointX + arrowWidth / 2, startPointY - arrowWidth / 2 + 1.0);
    path.lineTo(startPointX, startPointY + 1.0);
    path.close();

    startPointY = size.height / 2 + arrowWidth / 2;
    path.moveTo(startPointX + arrowWidth, startPointY);
    path.lineTo(startPointX + arrowWidth / 2, startPointY + arrowWidth / 2);
    path.lineTo(startPointX, startPointY);
    path.lineTo(startPointX, startPointY - 1.0);
    path.lineTo(startPointX + arrowWidth / 2, startPointY + arrowWidth / 2 - 1.0);
    path.lineTo(startPointX + arrowWidth, startPointY - 1.0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class NFScrollLabel extends StatelessWidget {
  const NFScrollLabel({
    Key? key,
    required this.text,
    this.size = 70.0,
    this.color,
    this.fontColor,
  }) : super(key: key);

  final String text;

  /// The size of the label container.
  /// The font size is calculated automatically based on that.
  /// Also respects [MediaQueryData.textScaleFactor].
  final double size;
  final Color? color;
  final Color? fontColor;

  @override
  Widget build(BuildContext context) {
    final textScaleFactor = MediaQuery.of(context).textScaleFactor;
    final fontSize = size / 2.1875;
    final theme = Theme.of(context);
    return Center(
      child: Container(
        width: size * textScaleFactor,
        height: size * textScaleFactor,
        margin: const EdgeInsets.only(bottom: 100.0),
        decoration: BoxDecoration(
          color: color ?? theme.colorScheme.primary,
          borderRadius: BorderRadius.all(
            Radius.circular(size),
          ),
        ),
        child: Center(
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: fontColor ?? theme.colorScheme.onPrimary,
              fontSize: fontSize,
            ),
          ),
        ),
      ),
    );
  }
}
