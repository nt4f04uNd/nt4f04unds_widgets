/*---------------------------------------------------------------------------------------------
*  Copyright (c) nt4f04und. All rights reserved.
*  Licensed under the BSD-style license. See LICENSE in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:nt4f04unds_widgets/src/constants.dart';
import 'package:nt4f04unds_widgets/nt4f04unds_widgets.dart';

const Duration kNFSnackBarAnimationDuration = Duration(milliseconds: 270);
const Duration kNFSnackBarDismissMovementDuration = Duration(milliseconds: 170);
const int kNFSnackBarMaxQueueLength = 15;

class NFSnackbarSettings {
  NFSnackbarSettings({
    @required this.child,
    this.globalKey,
    this.duration = const Duration(seconds: 4),
    this.important = false,
  }) : assert(child != null) {
    if (globalKey == null) this.globalKey = GlobalKey<NFSnackBarWrapperState>();
  }

  /// Main widget to display as a snackbar
  final Widget child;
  GlobalKey<NFSnackBarWrapperState> globalKey;

  /// How long the snackbar will be shown
  final Duration duration;

  /// Whether the snack bar is important and must interrupt the current displaying one
  final bool important;

  OverlayEntry overlayEntry;

  /// True when snackbar is visible
  bool _onScreen = false;
  bool get onScreen => _onScreen;

  /// Create [OverlayEntry] for snackbar
  void createSnackbar() {
    _onScreen = true;
    overlayEntry = OverlayEntry(
      builder: (BuildContext context) => Container(
        child: Align(
          alignment: Alignment.bottomCenter,
          child: _NFSnackBarWrapper(settings: this, key: globalKey),
        ),
      ),
    );
  }

  /// Removes [OverlayEntry]
  void removeSnackbar() {
    _onScreen = false;
    overlayEntry.remove();
  }
}

abstract class SnackBarControl {
  /// A list to render the snackbars
  static List<NFSnackbarSettings> snackbarsList = [];

  static void showSnackBar(NFSnackbarSettings settings) async {
    assert(settings != null);

    if (settings.important && snackbarsList.length > 1) {
      snackbarsList.insert(1, settings);
    } else {
      snackbarsList.add(settings);
    }

    if (snackbarsList.length == 1) {
      _showSnackBar();
    } else if (settings.important) {
      for (int i = 0; i < snackbarsList.length; i++) {
        if (snackbarsList[i].onScreen) {
          _dismissSnackBar(index: i);
        }
      }
      _showSnackBar();
    }

    if (snackbarsList.length >= kNFSnackBarMaxQueueLength) {
      /// Reset when queue runs out of space
      snackbarsList = [
        snackbarsList[0],
        snackbarsList[kNFSnackBarMaxQueueLength - 2],
        snackbarsList[kNFSnackBarMaxQueueLength - 1]
      ];
    }
  }

  /// Method to be called after the current snack bar has went out of screen
  static void _handleSnackBarDismissed() {
    _dismissSnackBar(index: 0);
    if (snackbarsList.isNotEmpty) {
      _showSnackBar();
    }
  }

  /// Creates next snackbar and shows it to screen
  /// [index] can be used to justify what snackbar to show
  static void _showSnackBar({int index = 0}) {
    assert(!snackbarsList[index].onScreen);
    snackbarsList[index].createSnackbar();
    try {
      NFWidgets.navigatorKey.currentState.overlay
          .insert(snackbarsList[index].overlayEntry);
    } catch (ex) {
      // Suppress exceptions (they usually caused by that some other widget in tree produces an exception).
    }
  }

  /// Removes next snackbar from screen without animation
  /// [index] can be used to justify what snackbar to hide
  static void _dismissSnackBar({int index = 0}) {
    snackbarsList[index].removeSnackbar();
    snackbarsList.removeAt(index);
  }

  // static void
}

/// Custom snackbar to display it in the [Overlay]
class _NFSnackBarWrapper extends StatefulWidget {
  _NFSnackBarWrapper({
    Key key,
    @required this.settings,
  })  : assert(settings != null),
        super(key: key);

  final NFSnackbarSettings settings;

  @override
  NFSnackBarWrapperState createState() => NFSnackBarWrapperState();
}

class NFSnackBarWrapperState extends State<_NFSnackBarWrapper>
    with TickerProviderStateMixin {
  Completer<bool> completer;
  AnimationController opacityController;
  AnimationController slideController;
  AnimationController timeoutController;
  final Key dismissibleKey = UniqueKey();

  @override
  void initState() {
    super.initState();
    completer = Completer();

    opacityController = AnimationController(
      vsync: this,
      duration: kNFSnackBarAnimationDuration,
    );
    slideController = AnimationController(
      vsync: this,
      duration: kNFSnackBarAnimationDuration,
    );
    timeoutController = AnimationController(
      vsync: this,
      duration: widget.settings.duration,
    );

    opacityController.forward();
    slideController.forward();
    timeoutController.value = 1;
    timeoutController.reverse();
    timeoutController.addStatusListener((status) {
      if (status == AnimationStatus.dismissed) completer.complete(true);
    });

    _handleEnd();
  }

  @override
  void dispose() {
    if (!completer.isCompleted) {
      completer.complete(false);
    }
    opacityController.dispose();
    slideController.dispose();
    timeoutController.dispose();
    super.dispose();
  }

  void _handleEnd() async {
    var res = await completer.future;
    if (res) {
      close();
    }
  }

  /// Will close snackbar with Animation
  ///
  /// If [notifyControl] is true, the [SnackBarControl._handleSnackBarDismissed] will be called internally after the closure
  Future<void> close() async {
    completer = Completer();
    slideController.addStatusListener((status) {
      if (status == AnimationStatus.dismissed) {
        completer.complete(true);
      }
    });
    slideController.reverse();
    opacityController.reverse();
    var res = await completer.future;
    if (res) {
      SnackBarControl._handleSnackBarDismissed();
    }
  }

  /// Will stop snackbar timeout close timer
  void stopTimer() {
    timeoutController.stop();
  }

  /// Will resume snackbar timeout close timer
  void resumeTimer() {
    timeoutController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final opacityAnimation = Tween(begin: 0.1, end: 1.0).animate(
      CurvedAnimation(curve: Curves.easeOutCubic, parent: opacityController),
    );
    final slideAnimation =
        Tween(begin: const Offset(0.0, 0.5), end: Offset.zero).animate(
      CurvedAnimation(curve: Curves.easeOutCubic, parent: slideController),
    );

    return GestureDetector(
      onPanDown: (_) {
        stopTimer();
      },
      onPanEnd: (_) {
        resumeTimer();
      },
      onPanCancel: () {
        resumeTimer();
      },
      child: FadeTransition(
        opacity: opacityAnimation,
        child: SlideTransition(
          position: slideAnimation,
          child: IgnorePointer(
            ignoring: slideController.status == AnimationStatus.reverse,
            child: StatefulBuilder(
              builder: (BuildContext context, setState) => NFDismissible(
                key: dismissibleKey,
                movementDuration: kNFSnackBarDismissMovementDuration,
                onDismissProgress: (_, value) => setState(() {
                  if (value > 0.2) {
                    opacityController.value = (1.0 - value) / 0.8;
                  }
                }),
                direction: DismissDirection.down,
                onDismissed: (_) => SnackBarControl._handleSnackBarDismissed(),
                child: Padding(
                  padding:
                      const EdgeInsets.only(bottom: 4.0, left: 8.0, right: 8.0),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.all(
                      Radius.circular(10.0),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        widget.settings.child,
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class NFSnackBar extends StatelessWidget {
  const NFSnackBar({
    Key key,
    this.message,
    this.leading,
    this.action,
    this.color,
    this.messagePadding = EdgeInsets.zero,
  }) : super(key: key);
  final Widget leading;
  final String message;
  final Widget action;
  final Color color;
  final EdgeInsets messagePadding;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color ?? Theme.of(context).colorScheme.primary,
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
              child: Padding(
                padding: messagePadding,
                child: Text(
                  message,
                  style: TextStyle(
                    fontSize: 15.0,
                    color: Theme.of(context).colorScheme.onError,
                  ),
                ),
              ),
            ),
            if (action != null)
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: action,
              )
          ],
        ),
      ),
    );
  }
}
