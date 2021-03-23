/*---------------------------------------------------------------------------------------------
*  Copyright (c) nt4f04und. All rights reserved.
*  Licensed under the BSD-style license. See LICENSE in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:nt4f04unds_widgets/nt4f04unds_widgets.dart';

/// Describes the snackbar entry and some settings for it.
class NFSnackbarEntry {
  NFSnackbarEntry({
    required this.child,
    this.duration = const Duration(seconds: 4),
    this.important = false,
    this.overlay,
    GlobalKey<NFSnackbarEntryState>? globalKey,
  }) : globalKey = globalKey ?? GlobalKey<NFSnackbarEntryState>();

  /// Main widget to display as a snackbar
  final Widget child;

  /// How long the snackbar will be shown
  final Duration duration;

  /// If true, the snackbar will remove the current displaying snackbar entry
  /// and take its place. Because of that important snackbar only has one place in
  /// [NFSnackbarController.snackbarsQueue] - the first position.
  final bool important;

  /// Can be used to show the snackbar in custom overlay. By default the one that is
  /// provided by [NFWidgets.navigatorKey], so provide it to [NFWidgets.init] if you want to use it.
  final OverlayState? overlay;

  /// Global key to manage the snackbar.
  final GlobalKey<NFSnackbarEntryState> globalKey;

  /// Whether the snackbar is currently shown.
  bool get onScreen => _overlayEntry != null;

  /// The overlay entry to instert to overlay.
  /// 
  /// To create the entry, call [createOverlayEntry].
  OverlayEntry? _overlayEntry;

  /// Creates next [overlayEntry] and shows it on the screen.
  void _show() {
    assert(!onScreen);
    _overlayEntry = OverlayEntry(
      builder: (context) => Container(
        child: Align(
          alignment: Alignment.bottomCenter,
          child: _NFSnackbarEntryWidget(entry: this, key: globalKey),
        ),
      ),
    );
    late final OverlayState _overlay;
    if (overlay == null) {
      assert(() {
        if (NFWidgets.navigatorKey == null) {
          throw Exception("Either provide `NFWidgets.navigatorKey` to get the root navigator overlay, or pass an `overlay` directly");
        }
        return true;
      }());
    } else {
      _overlay = overlay!;
    }
    _overlay.insert(_overlayEntry!);
  }

  /// Removes [overlayEntry].
  void _remove() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }
}

/// A controller for snackbars.
/// 
/// See also:
/// * [NFSnackbar], a snackbar widget
/// * [NFSnackbarEntry], which describes a snackbar entry and some settings for it
abstract class NFSnackbarController {
  /// Max length of [snackbarsQueue].
  /// 
  /// When queue exceeds this length, it's
  static int maxQueueLength = 4; 

  /// Queue of snackbars to render.
  /// 
  /// First snackbar is the nearest to be shown, last is farthest.
  /// 
  /// If contains [NFSnackbarEntry.important], it will be always displayed at the first
  /// position.
  static List<NFSnackbarEntry> snackbarsQueue = [];

  /// Shows the [snackbar] on screen.
  static void showSnackbar(NFSnackbarEntry snackbar, { OverlayState? overlay }) async {
    if (snackbar.important && snackbarsQueue.length > 1) {
      snackbarsQueue.insert(1, snackbar);
    } else {
      snackbarsQueue.add(snackbar);
    }

    if (snackbarsQueue.length == 1) {
      snackbar._show();
    } else if (snackbar.important) {
      for (int i = 0; i < snackbarsQueue.length; i++) {
        if (snackbarsQueue[i].onScreen) {
          _dismissSnackbar(snackbarsQueue[i]);
        }
      }
      snackbar._show();
    }

    if (snackbarsQueue.length >= maxQueueLength && !snackbar.important) {
      // Remove the farthest snackbar when queue length exceeds the max length.
      snackbarsQueue.removeLast();
    }
  }

  /// Method to be called after the current snack bar has went out of screen.
  static void _handleSnackbarGone() {
    _dismissSnackbar(snackbarsQueue[0]);
    if (snackbarsQueue.isNotEmpty) {
      snackbarsQueue[0]._show();
    }
  }

  /// Removes next snackbar overlay entry from screen.
  static void _dismissSnackbar(NFSnackbarEntry snackbar) {
    snackbar._remove();
    snackbarsQueue.remove(snackbar);
  }
}

class _NFSnackbarEntryWidget extends StatefulWidget {
  _NFSnackbarEntryWidget({
    Key? key,
    required this.entry,
  }) : assert(entry != null),
       super(key: key);

  final NFSnackbarEntry entry;

  @override
  NFSnackbarEntryState createState() => NFSnackbarEntryState();
}

/// Displays the [NFSnackbarEntry].
class NFSnackbarEntryState extends State<_NFSnackbarEntryWidget> with TickerProviderStateMixin {
  late Timer _timer;
  final Stopwatch _stopwatch = Stopwatch();
  late SlidableController controller;
  late AnimationController _fadeController;
  final Key dismissibleKey = UniqueKey();
  bool _closing = false;

  @override
  void initState() {
    super.initState();
    resumeTimer();
    _fadeController = AnimationController(vsync: this, duration: const Duration(milliseconds: 270));
    controller = SlidableController(vsync: this, duration: const Duration(milliseconds: 270));
    controller.value = 1.0;
    controller.fling(velocity: -1);
    controller.addStatusListener(_handleStatusChange);
    _fadeController.forward();
  }

  @override
  void dispose() {
    stopTimer();
    controller.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _handleStatusChange(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      close();
    }
  }

  /// Closes snackbar with animation.
  Future<void> close() async {
    if (_closing)
      return;
    _closing = true;
    _fadeController.reverse();
    await controller.fling(velocity: 1);
    NFSnackbarController._handleSnackbarGone();
  }

  /// Resumes close timer.
  void resumeTimer() {
    _stopwatch.start();
    final milliseconds = widget.entry.duration.inMilliseconds - _stopwatch.elapsedMilliseconds;
    if (milliseconds > 0) {
      _timer = Timer(Duration(milliseconds: milliseconds), () {
        close();
      });
    } else {
      close();
    }
  }

  /// Stops close timer.
  void stopTimer() {
    _stopwatch.stop();
    _timer.cancel();
  }

  @override
  Widget build(BuildContext context) {
    final fadeAnimation = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      curve: Interval(0.2, 1.0, curve: Curves.easeOutCubic),
      reverseCurve: Interval(0.2, 1.0, curve: Curves.easeInCubic),
      parent: _fadeController
    ));
    return FadeTransition(
      opacity: fadeAnimation,
      child: StatefulBuilder(
        builder: (BuildContext context, setState) => Slidable(
          controller: controller,
          direction: SlideDirection.down,
          start: 0.0,
          end: 1.0,
          onDragStart: (_) => stopTimer(),
          onDragEnd: (_, __) => resumeTimer(),
          key: dismissibleKey,
          childBuilder: (animation, child) => AnimatedBuilder(
            animation: animation,
            builder: (context, child) => child!,
            child: IgnorePointer(
              ignoring: controller.status == AnimationStatus.reverse,
              child: child,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              widget.entry.child,
            ],
          ),
        ),
      ),
    );
  }
}


/// Colored snackbar widget.
/// 
/// See also:
/// * [NFSnackbarController], which allows to display snackbars
/// * [NFSnackbarEntry], which describes a snackbar entry and some settings for it
class NFSnackbar extends StatelessWidget {
  const NFSnackbar({
    Key? key,
    this.title,
    this.leading,
    this.trailing,
    this.color,
    this.titlePadding = EdgeInsets.zero,
  }) : super(key: key);
  
  /// The primary content of the snakcbar.
  final Widget? title;

  /// A widget to display before the [title].
  final Widget? leading;

  /// A widget to display after the [title].
  final Widget? trailing;
  
  /// Snackbar color. By default [ColorScheme.primary] is used.
  final Color? color;

  /// Padding to apply to [title].
  final EdgeInsetsGeometry titlePadding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Material(
        color: color ?? theme.colorScheme.primary,
        borderRadius: const BorderRadius.all(Radius.circular(10.0)),
        child: Container(
          padding: const EdgeInsets.only(
            left: 16.0,
            right: 16.0,
            top: 4.0,
            bottom: 4.0,
          ),
          constraints: const BoxConstraints(minHeight: 48.0, maxHeight: 128.0),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              if (leading != null)
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: leading,
                ),
              Expanded(
                child: title == null
                  ? const SizedBox()
                  : Padding(
                    padding: titlePadding,
                    child: title!,
                ),
              ),
              if (trailing != null)
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: trailing,
                )
            ],
          ),
        ),
      ),
    );
  }
}
