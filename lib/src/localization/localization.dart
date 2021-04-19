/*---------------------------------------------------------------------------------------------
*  Copyright (c) nt4f04und. All rights reserved.
*  Licensed under the BSD-style license. See LICENSE in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import 'dart:async';

import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:multiple_localization/multiple_localization.dart';
import 'package:nt4f04unds_widgets/src/constants.dart';

import 'gen/messages_all.dart';

class NFLocalizations {
  NFLocalizations._(this.localeName);
  static const LocalizationsDelegate<NFLocalizations> delegate = _NFLocalizationsDelegate();
  final String localeName;

  static Future<NFLocalizations> load(Locale locale) async {
    return MultipleLocalizations.load(
      initializeMessages,
      locale,
      (locale) => NFLocalizations._(locale),
    );
  }

  static NFLocalizations of(BuildContext context) {
    return Localizations.of<NFLocalizations>(context, NFLocalizations)!;
  }

  String get warning {
    return Intl.message(
      'Warning',
      name: 'warning',
      locale: localeName,
    );
  }

  String get close {
    return Intl.message(
      'Close',
      name: 'close',
      locale: localeName,
    );
  }

  String get accept {
    return Intl.message(
      'Accept',
      name: 'accept',
      locale: localeName,
    );
  }

  String get cancel {
    return Intl.message(
      'Cancel',
      name: 'cancel',
      locale: localeName,
    );
  }

  String get copied {
    return Intl.message(
      'Copied',
      name: 'copied',
      locale: localeName,
    );
  }
}

class _NFLocalizationsDelegate extends LocalizationsDelegate<NFLocalizations> {
  const _NFLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return NFConstants.supportedLocales.contains(locale);
  }

  @override
  Future<NFLocalizations> load(Locale locale) {
    return NFLocalizations.load(locale);
  }

  @override
  bool shouldReload(_NFLocalizationsDelegate old) {
    return false;
  }
}
