/*---------------------------------------------------------------------------------------------
*  Copyright (c) nt4f04und. All rights reserved.
*  Licensed under the BSD-style license. See LICENSE in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import 'dart:convert';
import 'dart:core';
import 'dart:core' as core;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nt4f04unds_widgets/nt4f04unds_widgets.dart';

// TODO: more comments
// TODO: tests

// class Test {
//   Test(this.a);
//   final int a;
//   factory Test.fromMap(Map map) => Test(map['a']);
//   Map toMap() => {'a': a};
// }

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await NFPrefs.initialize();
//   final a = NullablePrefNotifier(NullableJsonPref<Test>(
//     'what',
//     toJson: (value) => value?.toMap(),
//     fromJson: (value) => value != null ? Test.fromMap(value as Map) : null,
//   ));
//   a.addListener(() {
//     print(a.value?.toMap());
//   });
//   a.set(Test(1));
//   a.set(Test(2));
//   a.delete();
//   a.set(Test(3));
// }

/// You should call [initialize] to activate prefs in your app.
abstract class NFPrefs {
  /// Prevent extending from this class.
  const NFPrefs._();

  /// Saved prefs instance.
  static SharedPreferences? prefs;

  /// Call this method to activate prefs in your app.
  /// This is needed to make operations over prefs synchronous.
  static Future<void> initialize() async {
    prefs ??= await SharedPreferences.getInstance(); 
  }

  /// Clears shared preferences.
  static Future<bool> clear() async {
    await initialize();
    return prefs!.clear();
  }
}

/// Class representing a single shared pref.
///
/// Usage example:
///
/// ```dart
/// static final devModeBool = Pref.bool(key: 'dev_mode', defaultValue: false);
/// ```
abstract class Pref<T> extends NullablePref<T> {
  const Pref(String key, this.defaultValue) : super(key);

  static BoolPref bool(String key, core.bool defaultValue) => BoolPref(key, defaultValue);
  static IntPref int(String key, core.int defaultValue) => IntPref(key, defaultValue);
  static DoublePref double(String key, core.double defaultValue) => DoublePref(key, defaultValue);
  static StringPref string(String key, String defaultValue) => StringPref(key, defaultValue);
  static StringListPref stringList(String key, List<String> defaultValue) => StringListPref(key, defaultValue);

  /// Fallback value, returned from get, when there's no
  /// actual value stored.
  final T defaultValue;

  @override
  T get();

  @override
  Future<core.bool> set(T value);

  /// Checks pref value and if it's `null`, and there's a [defaultValue],
  /// returns it. Otherwise just returns the value as-is.
  ///
  /// Should be called inside the [get] method.
  T? _checkForNull(T? value) {
    if (value == null && defaultValue != null)
      return defaultValue!;
    return value;
  }
}

/// Class representing a single shared pref.
///
/// Usage example:
///
/// ```dart
/// static final count = NullablePref.int(key: 'count');
/// ```
abstract class NullablePref<T> {
  const NullablePref(this.key);
  // TODO: enable this assert when const functions are in place
    // : assert(
    //     !isNullable<T>(),
    //     () {
    //       final type = T.toString();
    //       final nonNulalbleType = type.substring(0, type.length - 1);
    //       return 'Generics on Prefs always must be non-nullable.\n'
    //       'Instead of $type provide $nonNulalbleType';
    //     }(),
    //   );

  static NullableBoolPref bool(String key) => NullableBoolPref(key);
  static NullableIntPref int(String key) => NullableIntPref(key);
  static NullableDoublePref double(String key) => NullableDoublePref(key);
  static NullableStringPref string(String key) => NullableStringPref(key);
  static NullableStringListPref stringList(String key) => NullableStringListPref(key);

  /// A unique pref key.
  final String key;

  /// Gets pref value.
  T? get();

  /// Sets pref [value].
  Future<core.bool> set(T value);

  /// Deletes the value from persistent storage.
  Future<core.bool> delete() async {
    return _prefs.remove(key);
  }

  /// Shortcut for accessing prefs.
  SharedPreferences get _prefs {
    assert(NFPrefs.prefs != null, "To use prefs, call NFPrefs.initialize first");
    return NFPrefs.prefs!;
  }
}

//*************** Primitives ******************

class BoolPref extends Pref<bool> {
  BoolPref(String key, bool defaultValue) : super(key, defaultValue);

  @override
  bool get() {
    return _checkForNull(_prefs.getBool(key))!;
  }

  @override
  Future<bool> set(bool value) async {
    return _prefs.setBool(key, value);
  }
}

class NullableBoolPref extends NullablePref<bool> {
  NullableBoolPref(String key) : super(key);

  @override
  bool? get() {
    return _prefs.getBool(key);
  }

  @override
  Future<bool> set(bool value) async {
    return _prefs.setBool(key, value);
  }
}

class IntPref extends Pref<int> {
  IntPref(String key, int defaultValue) : super(key, defaultValue);

  @override
  int get()  {
    return _checkForNull(_prefs.getInt(key))!;
  }

  @override
  Future<bool> set(int value) async {
    return _prefs.setInt(key, value);
  }
}

class NullableIntPref extends NullablePref<int> {
  NullableIntPref(String key) : super(key);

  @override
  int? get() {
    return _prefs.getInt(key);
  }

  @override
  Future<bool> set(int value) async {
    return _prefs.setInt(key, value);
  }
}

class DoublePref extends Pref<double> {
  DoublePref(String key, double defaultValue) : super(key, defaultValue);

  @override
  double get() {
    return _checkForNull(_prefs.getDouble(key))!;
  }

  @override
  Future<bool> set(double value) async {
    return _prefs.setDouble(key, value);
  }
}

class NullableDoublePref extends NullablePref<double> {
  NullableDoublePref(String key) : super(key);

  @override
  double? get() {
    return _prefs.getDouble(key);
  }

  @override
  Future<bool> set(double value) async {
    return _prefs.setDouble(key, value);
  }
}

class StringPref extends Pref<String> {
  StringPref(String key, String defaultValue) : super(key, defaultValue);

  @override
  String get()  {
    return _checkForNull(_prefs.getString(key))!;
  }

  @override
  Future<bool> set(String value) async {
    return _prefs.setString(key, value);
  }
}

class NullableStringPref extends NullablePref<String> {
  NullableStringPref(String key) : super(key);

  @override
  String? get() {
    return _prefs.getString(key);
  }

  @override
  Future<bool> set(String value) async {
    return _prefs.setString(key, value);
  }
}

class StringListPref extends Pref<List<String>> {
  StringListPref(String key, List<String> defaultValue) : super(key, defaultValue);

  @override
  List<String> get() {
    return _checkForNull( _prefs.getStringList(key))!;
  }

  @override
  Future<bool> set(List<String> value) async {
    return _prefs.setStringList(key, value);
  }
}

class NullableStringListPref extends NullablePref<List<String>> {
  NullableStringListPref(String key) : super(key);

  @override
  List<String>? get() {
    return _prefs.getStringList(key);
  }

  @override
  Future<bool> set(List<String> value) async {
    return _prefs.setStringList(key, value);
  }
}

//*************** Json ******************

typedef ToJsonCallback<T> = Object Function(T); 
typedef FromJsonCallback<T> = T Function(Object);

typedef NullableToJsonCallback<T> = Object? Function(T?); 
typedef NullableFromJsonCallback<T> = T? Function(Object?); 

class JsonPref<T> extends Pref<T> {
  JsonPref(
    String key,
    T defaultValue, {
    this.fromJson,
    this.toJson,
  }) : _stringPref = StringPref(key, _encode<T>(defaultValue, toJson)),
       super(key, defaultValue);
  
  final FromJsonCallback<T>? fromJson;
  final ToJsonCallback<T>? toJson;
  final StringPref _stringPref;

  static String _encode<T>(T value, ToJsonCallback<T>? toJson) {
    return jsonEncode(toJson != null ? toJson(value) : value);
  }

  static T _decode<T>(String json, FromJsonCallback<T>? fromJson) {
    final res = jsonDecode(json);
    return fromJson != null ? fromJson(res) : res;
  }

  @override
  T get() {
    return _decode<T>(_stringPref.get(), fromJson);
  }

  @override
  Future<bool> set(T value) async {
    return _stringPref.set(_encode<T>(value, toJson));
  }
}

class NullableJsonPref<T> extends NullablePref<T> {
  NullableJsonPref(
    String key, {
    T? defaultValue,
    this.fromJson,
    this.toJson,
  }) : _stringPref = StringPref(key, _encode<T?>(defaultValue, toJson)),
       super(key);
  
  final NullableFromJsonCallback<T>? fromJson;
  final NullableToJsonCallback<T>? toJson;
  final StringPref _stringPref;

  static String _encode<T>(T value, NullableToJsonCallback<T>? toJson) {
    return jsonEncode(toJson != null ? toJson(value) : value);
  }

  static T _decode<T>(String json, NullableFromJsonCallback<T>? fromJson) {
    final res = jsonDecode(json);
    return fromJson != null ? fromJson(res) : res;
  }

  @override
  T? get() {
    return _decode<T?>(_stringPref.get(), fromJson);
  }

  @override
  Future<bool> set(T value) async {
    return _stringPref.set(_encode<T>(value, toJson));
  }
}

//*************** Decorators ******************

class PrefNotifier<T> extends NullablePrefNotifier<T> {
  PrefNotifier(Pref<T> pref) : super(pref);

  @override
  T get value => super.value!;
}

class NullablePrefNotifier<T> with ChangeNotifier implements NullablePref<T>, ValueListenable<T?> {
  NullablePrefNotifier(this._pref);
  final NullablePref<T> _pref;

  @override
  T? get value => get();
  T? _value;
  void _setValue(T? newValue) {
    if (_value == newValue)
      return;
    _value = newValue;
    notifyListeners();
  }

  @override
  String get key => _pref.key;

  @override
  T? get() => _pref.get();

  @override
  Future<bool> set(T newValue) {
    final res = _pref.set(newValue);
    _setValue(newValue);
    return res;
  }
    
  @override
  Future<bool> delete() {
    final res = _pref.delete();
    _setValue(null);
    return res;
  }

  @override
  SharedPreferences get _prefs => _pref._prefs;
}
