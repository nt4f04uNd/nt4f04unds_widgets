/*---------------------------------------------------------------------------------------------
*  Copyright (c) nt4f04und. All rights reserved.
*  Licensed under the BSD-style license. See LICENSE in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nt4f04unds_widgets/nt4f04unds_widgets.dart';
      
/// Class that represents a single shared pref.
/// 
/// Usage example
/// ```dart
/// static final Pref<bool> devModeBool =
///     Pref<bool>(key: 'dev_mode', defaultValue: false);
/// ```
///
/// Even if default value is null, you should specify it explicitly and give a pref variable "Nullable" postfix.
/// 
/// In case with previous example, that would be
class Pref<T> {
  Pref({
    @required this.key,
    @required this.defaultValue,
  }) : assert(key != null) {
    /// Call this to check current pref value and set it to default, if it's null
    get();
  }

  final String key;
  final T defaultValue;

  /// Set pref value.
  /// Without [value] will set the pref to its [defaultValue].
  ///
  /// @param [value] new pref value to set.
  ///
  /// @param [prefs] optional [SharedPreferences] instance.
  Future<bool> set([T value]) async {
    value ??= defaultValue;
    final prefs = await SharedPreferences.getInstance();

    if (isType<T, bool>()) {
      return prefs.setBool(key, value as bool);
    } else if (isType<T, int>()) {
      return prefs.setInt(key, value as int);
    } else if (isType<T, double>()) {
      return prefs.setDouble(key, value as double);
    } else if (isType<T, String>()) {
      return prefs.setString(key, value as String);
    } else if (isType<T, List<String>>()) {
      return prefs.setStringList(key, value as List<String>);
    }
    throw Exception("Pref.get: Wrong type of pref generic: T = $T");
  }

  /// Get pref value.
  /// If the current value is `null`, will return [defaultValue] call [setPref] to reset the pref to the [defaultValue].
  ///
  /// @param prefs optional [SharedPreferences] instance
  Future<T> get() async {
    final prefs = await SharedPreferences.getInstance();

    T res;
    if (isType<T, bool>()) {
      res = prefs.getBool(key) as T;
    } else if (isType<T, int>()) {
      res = prefs.getInt(key) as T;
    } else if (isType<T, double>()) {
      res = prefs.getDouble(key) as T;
    } else if (isType<T, String>()) {
      res = prefs.getString(key) as T;
    } else if (isType<T, List<String>>()) {
      res = prefs.getStringList(key) as T;
    } else {
      throw Exception("Pref.get: Wrong type of pref generic: T = $T");
    }

    // Reset pref value to default value if defaultValue is not null
    if (res == null && defaultValue != null) {
      res = defaultValue;
      set();
    }

    return res;
  }
}
