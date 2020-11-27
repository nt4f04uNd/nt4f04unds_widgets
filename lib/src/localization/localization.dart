/*---------------------------------------------------------------------------------------------
*  Copyright (c) nt4f04und. All rights reserved.
*  Licensed under the BSD-style license. See LICENSE in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import 'dart:async';

import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:nt4f04unds_widgets/src/constants.dart';

import 'gen/messages_all.dart';

class NFLocalizations {
  static const LocalizationsDelegate<NFLocalizations> delegate =
      _NFLocalizationsDelegate();

  static Future<NFLocalizations> load(Locale locale) {
    final String name =
        locale.countryCode.isEmpty ? locale.languageCode : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);

    return initializeMessages(localeName).then((bool _) {
      Intl.defaultLocale = localeName;
      return NFLocalizations();
    });
  }

  static NFLocalizations of(BuildContext context) {
    return Localizations.of<NFLocalizations>(context, NFLocalizations);
  }

  String get warning {
    return Intl.message(
      'Warning',
      name: 'warning',
    );
  }

  String get close {
    return Intl.message(
      'Close',
      name: 'close',
    );
  }

  String get accept {
    return Intl.message(
      'Accept',
      name: 'accept',
    );
  }

  String get cancel {
    return Intl.message(
      'Cancel',
      name: 'cancel',
    );
  }

  String get copied {
    return Intl.message(
      'Copied',
      name: 'copied',
    );
  }

  String get whatDoesItMean {
    return Intl.message(
      'What does it mean?',
      name: 'whatDoesItMean',
    );
  }
}

class _NFLocalizationsDelegate extends LocalizationsDelegate<NFLocalizations> {
  const _NFLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return NFConstants.supportedLocales.contains(locale.languageCode);
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
