/*---------------------------------------------------------------------------------------------
*  Copyright (c) nt4f04und. All rights reserved.
*  Licensed under the BSD-style license. See LICENSE in the project root for license information.
*--------------------------------------------------------------------------------------------*/

class NFConstants {
  /// Default route transition duration used across the package.
  @Deprecated('I reconsidered there should not exist any library-wide duration constants.')
  static const Duration routeTransitionDuration = const Duration(milliseconds: 300);

  /// Default preferable color animation duration.
  @Deprecated('I reconsidered there should not exist any library-wide duration constants.')
  static const Duration colorAnimationDuration = Duration(milliseconds: 500);

  /// Default icon size i prefer to use.
  static const double iconSize = 25.0;

  /// Default icon button size i prefer to use.
  static const double iconButtonSize = 36.0;

  static const List<String> supportedLocales = ['en', 'ru'];
}
