/*---------------------------------------------------------------------------------------------
*  Copyright (c) nt4f04und. All rights reserved.
*  Licensed under the BSD-style license. See LICENSE in the project root for license information.
*
*  Copyright (c) The Flutter Authors.
*  See ThirdPartyNotices.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

// todo: propose changes to the scrollbar in the framework and delete this.

export 'draggable_scrollbar.dart';

import 'dart:async';

import 'package:flutter/material.dart';

const double _kScrollbarHeight = 40.0;
const double _kScrollbarThickness = 6.0;
const Duration kScrollbarFadeDuration = Duration(milliseconds: 500);
const Duration kScrollbarTimeToFade = Duration(milliseconds: 1000);
const Duration kScrollbarLabelTimeToFade = Duration(milliseconds: 800);

/// A material design scrollbar.
///
/// A scrollbar indicates which portion of a [Scrollable] widget is actually
/// visible.
///
/// To add a scrollbar to a [ScrollView], simply wrap the scroll view widget in
/// a [Scrollbar] widget.
///
class NFScrollbar extends StatefulWidget {
  /// Creates a material design scrollbar that wraps the given [child].
  ///
  /// The [child] should be a source of [ScrollNotification] notifications,
  /// typically a [Scrollable] widget.
  const NFScrollbar({
    Key? key,
    required this.child,
    this.color,
    this.thickness = _kScrollbarThickness,
    this.padding = EdgeInsets.zero,
    this.mainAxisMargin = 3.0,
    this.crossAxisMargin = 0.0,
    this.radius = const Radius.circular(8.0),
    this.minLength = _kScrollbarHeight,
    this.minOverscrollLength,
  }) : super(key: key);

  /// The widget below this widget in the tree.
  ///
  /// The scrollbar will be stacked on top of this child. This child (and its
  /// subtree) should include a source of [ScrollNotification] notifications.
  ///
  /// Typically a [ListView] or [CustomScrollView].
  final Widget child;

  /// These are just properties from the [ScrollbarPainter]
  final Color? color;
  final double thickness;
  final EdgeInsets padding;
  final double mainAxisMargin;
  final double crossAxisMargin;
  final Radius radius;
  final double minLength;
  final double? minOverscrollLength;

  @override
  _NFScrollbarState createState() => _NFScrollbarState();
}

class _NFScrollbarState extends State<NFScrollbar> with SingleTickerProviderStateMixin {
  late ScrollbarPainter _scrollbarPainter;
  late TextDirection _textDirection;
  late Color _themeColor;
  late AnimationController _fadeoutAnimationController;
  late Animation<double> _fadeoutOpacityAnimation;
  Timer? _fadeoutTimer;

  @override
  void initState() {
    super.initState();
    _fadeoutAnimationController = AnimationController(vsync: this, duration: kScrollbarFadeDuration);
    _fadeoutOpacityAnimation = CurvedAnimation(parent: _fadeoutAnimationController, curve: Curves.fastOutSlowIn);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final ThemeData theme = Theme.of(context);
    switch (theme.platform) {
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
      case TargetPlatform.linux:
      case TargetPlatform.windows:
        _themeColor = theme.colorScheme.primary;
        _textDirection = Directionality.of(context);
        _scrollbarPainter = _buildScrollbarPainter();
        break;
    }
  }

  ScrollbarPainter _buildScrollbarPainter() {
    return ScrollbarPainter(
      color: widget.color ?? _themeColor,
      thickness: widget.thickness,
      padding: widget.padding,
      mainAxisMargin: widget.mainAxisMargin,
      crossAxisMargin: widget.crossAxisMargin,
      radius: widget.radius,
      minLength: widget.minLength,
      minOverscrollLength: widget.minOverscrollLength,
      fadeoutOpacityAnimation: _fadeoutOpacityAnimation,
      textDirection: _textDirection,
    );
  }

  bool _handleScrollNotification(ScrollNotification notification) {
    final ScrollMetrics metrics = notification.metrics;
    if (metrics.maxScrollExtent <= metrics.minScrollExtent) {
      return false;
    }

    // iOS sub-delegates to the CupertinoScrollbar instead and doesn't handle
    // scroll notifications here.
    if ((notification is ScrollUpdateNotification || notification is OverscrollNotification)) {
      if (_fadeoutAnimationController.status != AnimationStatus.forward) {
        _fadeoutAnimationController.forward();
      }

      _scrollbarPainter.update(notification.metrics, notification.metrics.axisDirection);
      _fadeoutTimer?.cancel();
      _fadeoutTimer = Timer(kScrollbarTimeToFade, () {
        _fadeoutAnimationController.reverse();
        _fadeoutTimer = null;
      });
    }
    return false;
  }

  @override
  void dispose() {
    _fadeoutAnimationController.dispose();
    _fadeoutTimer?.cancel();
    _scrollbarPainter.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: _handleScrollNotification,
      child: RepaintBoundary(
        child: CustomPaint(foregroundPainter: _scrollbarPainter, child: RepaintBoundary(child: widget.child)),
      ),
    );
  }
}
