/*---------------------------------------------------------------------------------------------
*  Copyright (c) nt4f04und. All rights reserved.
*  Licensed under the BSD-style license. See LICENSE in the project root for license information.
*--------------------------------------------------------------------------------------------*/

/// Gets the actual type in runtime to be able to compare it.
///
/// See why to have this function here https://github.com/dart-lang/language/issues/1326
Type typeOf<X>() => X;

/// Checks whether the generic is nullable.
bool isNullable<T>() => null is T;

/// Signature for function that returns a boolean.
typedef BoolCallback = bool Function();

/// A [BoolCallback] that returns true.
/// 
/// Can be used for contant values.
bool trueCallback() => true;

/// Class for creating enhanced enums.
abstract class Enum<T> {
  const Enum(this._value);
  final T _value;

  /// Returns enum value.
  T get value => _value;

  @override
  String toString() => '$runtimeType.$value';
}