/*---------------------------------------------------------------------------------------------
*  Copyright (c) nt4f04und. All rights reserved.
*  Licensed under the BSD-style license. See LICENSE in the project root for license information.
*--------------------------------------------------------------------------------------------*/

// @dart = 2.12

/// Gets the actual type in runtime to be able to compare it.
///
/// See why to have this function here https://github.com/dart-lang/language/issues/1326
Type typeOf<X>() => X;

/// Signature for function that returns a boolean.
typedef BoolCallback = bool Function();