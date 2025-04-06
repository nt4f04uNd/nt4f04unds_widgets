/*---------------------------------------------------------------------------------------------
*  Copyright (c) nt4f04und. All rights reserved.
*  Licensed under the BSD-style license. See LICENSE in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import 'dart:convert';

import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

/// Shortcut for accessing prefs.
SharedPreferences get _prefs {
  assert(NFPrefs.prefs != null, "To use prefs, call NFPrefs.initialize first");
  return NFPrefs.prefs!;
}

abstract class PrefBase<G, S extends G> {
  const PrefBase(this.key);
  // TODO: same as below - asseret S is not nullable when const functions are in place

  /// A unique pref key.
  final String key;

  /// Gets pref value.
  G get();

  /// Sets pref [value].
  Future<bool> set(S value);

  /// Deletes the value from persistent storage.
  Future<bool> delete() async {
    return _prefs.remove(key);
  }
}

/// Class representing a single shared pref.
///
/// Usage example:
///
/// ```dart
/// static final devModeBool = Pref.bool(key: 'dev_mode', defaultValue: false);
/// ```
abstract class Pref<T> extends PrefBase<T, T> {
  const Pref(super.key, this.defaultValue);
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

  /// Fallback value, returned from get, when there's no
  /// actual value stored.
  final T defaultValue;

  @override
  T get();

  @override
  Future<bool> set(T value);

  /// Checks pref value and if it's `null`, and there's a [defaultValue],
  /// returns it. Otherwise just returns the value as-is.
  ///
  /// Should be called inside the [get] method.
  T _checkForNull(T? value) {
    if (value == null) return defaultValue!;
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
abstract class NullablePref<T> extends PrefBase<T?, T> {
  const NullablePref(super.key);
}

//*************** Primitives ******************

class BoolPref extends Pref<bool> {
  const BoolPref(super.key, super.defaultValue);

  @override
  bool get() {
    return _checkForNull(_prefs.getBool(key));
  }

  @override
  Future<bool> set(bool value) async {
    return _prefs.setBool(key, value);
  }
}

class NullableBoolPref extends NullablePref<bool> {
  const NullableBoolPref(super.key);

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
  const IntPref(super.key, super.defaultValue);

  @override
  int get() {
    return _checkForNull(_prefs.getInt(key));
  }

  @override
  Future<bool> set(int value) async {
    return _prefs.setInt(key, value);
  }
}

class NullableIntPref extends NullablePref<int> {
  const NullableIntPref(super.key);

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
  const DoublePref(super.key, super.defaultValue);

  @override
  double get() {
    return _checkForNull(_prefs.getDouble(key));
  }

  @override
  Future<bool> set(double value) async {
    return _prefs.setDouble(key, value);
  }
}

class NullableDoublePref extends NullablePref<double> {
  const NullableDoublePref(super.key);

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
  const StringPref(super.key, super.defaultValue);

  @override
  String get() {
    return _checkForNull(_prefs.getString(key));
  }

  @override
  Future<bool> set(String value) async {
    return _prefs.setString(key, value);
  }
}

class NullableStringPref extends NullablePref<String> {
  const NullableStringPref(super.key);

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
  const StringListPref(super.key, super.defaultValue);

  @override
  List<String> get() {
    return _checkForNull(_prefs.getStringList(key));
  }

  @override
  Future<bool> set(List<String> value) async {
    return _prefs.setStringList(key, value);
  }
}

class NullableStringListPref extends NullablePref<List<String>> {
  const NullableStringListPref(super.key);

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
  JsonPref(super.key, super.defaultValue, {this.fromJson, this.toJson})
    : _stringPref = StringPref(key, _encode<T>(defaultValue, toJson));

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
  NullableJsonPref(super.key, {this.fromJson, this.toJson}) : _stringPref = NullableStringPref(key);

  final NullableFromJsonCallback<T>? fromJson;
  final NullableToJsonCallback<T>? toJson;
  final NullableStringPref _stringPref;

  static String _encode<T>(T value, NullableToJsonCallback<T>? toJson) {
    return jsonEncode(toJson != null ? toJson(value) : value);
  }

  static T _decode<T>(String? json, NullableFromJsonCallback<T>? fromJson) {
    final res = json != null ? jsonDecode(json) : null;
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

//*************** Enum ******************

class EnumPref<T> extends Pref<T> {
  EnumPref(String key, this.values, T defaultValue)
    : _stringPref = StringPref(key, EnumToString.convertToString(defaultValue)),
      super(key, defaultValue);

  final List<T> values;
  final StringPref _stringPref;

  @override
  T get() {
    return _checkForNull(EnumToString.fromString(values, _stringPref.get()));
  }

  @override
  Future<bool> set(T value) async {
    return _stringPref.set(EnumToString.convertToString(value));
  }
}

class NullableEnumPref<T> extends NullablePref<T> {
  NullableEnumPref(super.key, this.values) : _stringPref = NullableStringPref(key);

  final List<T> values;
  final NullableStringPref _stringPref;

  @override
  T? get() {
    final value = _stringPref.get();
    return value != null ? EnumToString.fromString(values, value) : null;
  }

  @override
  Future<bool> set(T value) async {
    return _stringPref.set(EnumToString.convertToString(value));
  }
}

//*************** Decorators ******************

abstract class PrefNotifierBase<G, S extends G> with ChangeNotifier implements PrefBase<G, S>, ValueListenable<G> {
  PrefNotifierBase(this._pref);
  final PrefBase<G, S> _pref;

  @override
  G get value => _value ??= _pref.get();
  G? _value;
  void _setValue(G newValue) {
    if (_value == newValue) return;
    _value = newValue;
    notifyListeners();
  }

  @override
  String get key => _pref.key;

  @override
  G get() => value;

  @override
  Future<bool> set(S newValue) {
    final res = _pref.set(newValue);
    _setValue(newValue);
    return res;
  }

  @override
  Future<bool> delete() {
    final res = _pref.delete();
    _setValue(null as G);
    return res;
  }
}

class PrefNotifier<T> extends PrefNotifierBase<T, T> {
  PrefNotifier(Pref<T> super.pref);
}

class NullablePrefNotifier<T> extends PrefNotifierBase<T?, T> {
  NullablePrefNotifier(NullablePref<T> super.pref);
}
