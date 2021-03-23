/*---------------------------------------------------------------------------------------------
*  Copyright (c) nt4f04und. All rights reserved.
*  Licensed under the BSD-style license. See LICENSE in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import 'package:shared_preferences/shared_preferences.dart';
import 'package:nt4f04unds_widgets/nt4f04unds_widgets.dart';
      
/// Class that represents a single shared pref.
///
/// Usage example:
/// ```dart
/// static final Pref<bool> devModeBool =
///     Pref<bool>(key: 'dev_mode', defaultValue: false);
/// ```
class Pref<T> {
  Pref({ required this.key, this.defaultValue }) {
    // Call this to check current pref value and set it to default.
    get();
  }

  final String key;
  final T? defaultValue;

  /// Deletes the value persistent from storage.
  Future<bool> delete() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.remove(key);
  }

  /// Sets pref [value].
  Future<bool> set(T value) async {
    assert(value != null);
    final prefs = await SharedPreferences.getInstance();

    final type = typeOf<T>();
    if (type == bool) {
      return prefs.setBool(key, value as bool);
    } else if (type == int) {
      return prefs.setInt(key, value as int);
    } else if (type == double) {
      return prefs.setDouble(key, value as double);
    } else if (type == String) {
      return prefs.setString(key, value as String);
    } else if (type == typeOf<List<String>>()) {
      return prefs.setStringList(key, value as List<String>);
    }
    throw Exception("Pref.get: Wrong type of pref generic: T = $type");
  }

  /// Gets pref value.
  /// 
  /// If the current value is `null`, will return [defaultValue] and call [setPref] to reset the pref to the [defaultValue].
  Future<T> get() async {
    final prefs = await SharedPreferences.getInstance();

    final type = typeOf<T>();
    T res;
    if (type == bool) {
      res = prefs.getBool(key) as T;
    } else if (type == int) {
      res = prefs.getInt(key) as T;
    } else if (type == double) {
      res = prefs.getDouble(key) as T;
    } else if (type == String) {
      res = prefs.getString(key) as T;
    } else if (type == typeOf<List<String>>()) {
      res = prefs.getStringList(key) as T;
    } else {
      throw Exception("Pref.get: Wrong type of pref generic: T = $type");
    }

    // Reset pref value to default value if defaultValue is not null
    if (res == null && defaultValue != null) {
      res = defaultValue!;
      set(res);
    }

    return res;
  }
}
