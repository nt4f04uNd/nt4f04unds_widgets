/*---------------------------------------------------------------------------------------------
*  Copyright (c) nt4f04und. All rights reserved.
*  Licensed under the BSD-style license. See LICENSE in the project root for license information.
*--------------------------------------------------------------------------------------------*/

/// Compares two types.
///
/// This is needed because for some not all types can be easily directly compared.
///
/// For example if object instance `Class<String>()` of class `Class<T>` with `method()` within it exist,
/// checking like `T == String` within the method will give false.
///
/// Or, again with generic classes, calling this function will be the only way to compare generic class parameter
/// with already parametrized type like `List<String>`.
///
/// Behaviour listed as per `Dart 2.10.0 (build 2.10.0-107.0.dev)`.
bool isType<T1, T2>() => T1 == T2;
