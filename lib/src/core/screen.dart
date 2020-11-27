/*---------------------------------------------------------------------------------------------
*  Copyright (c) nt4f04und. All rights reserved.
*  Licensed under the BSD-style license. See LICENSE in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import 'package:flutter/material.dart';

/// Screen sizes.
enum Screen { standart, small, tablet }

/// Stores screen width.
///
/// Initialized in the [NFWidgets].
double screenWidth;

/// Stores screen height.
///
/// Initialized in the [NFWidgets].
double screenHeight;

/// Store the screen size the applicaiton is running on.
///
/// Initialized in the [NFWidgets].
Screen screen = Screen.standart;

/// Designates whether the the app has standart, medium sized screen - not too small, and not a tabet.
bool get standartScreen => screen == Screen.standart;

/// Designates whether the app is running on very small screen.
bool get smallScreen => screen == Screen.small;

/// Designates whether the app is running on tablet.
bool get tablet => screen == Screen.tablet;

/// Checks the current [screen] size and returns a value dependent on that.
T pickSize<T>(T standart, {T small, T tablet}) {
  assert(small != null || tablet != null,
      'Must specify at least one additional size for size picker except standart');
  if (small == null) {
    small = standart;
  }
  if (tablet == null) {
    tablet = standart;
  }
  switch (screen) {
    case Screen.standart:
      return standart;
    case Screen.small:
      return small;
    case Screen.tablet:
      return tablet;
    default:
      assert(false);
      return null;
  }
}

/// Updates [screenWidth], [screenHeight] and [screen].
void updateScreenSize() {
  final size = MediaQueryData.fromWindow(WidgetsBinding.instance.window).size;
  screenWidth = size.width;
  screenHeight = size.height;
  final shortestSide = size.shortestSide;
  if (shortestSide >= 600) {
    screen = Screen.tablet;
  } else if (shortestSide <= 345) {
    screen = Screen.small;
  } else {
    screen = Screen.standart;
  }
}
