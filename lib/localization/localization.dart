/*---------------------------------------------------------------------------------------------
*  Copyright (c) nt4f04und. All rights reserved.
*  Licensed under the BSD-style license. See LICENSE in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import 'dart:async';

import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:nt4f04unds_widgets/constants.dart';
import 'package:nt4f04unds_widgets/nt4f04unds_widgets.dart';

import 'gen/messages_all.dart';

/// Gets [AppLocalizations].
AppLocalizations get l10n =>
    AppLocalizations.of(NFWidgets.navigatorKey.currentContext);

class AppLocalizations {
  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static Future<AppLocalizations> load(Locale locale) {
    final String name =
        locale.countryCode.isEmpty ? locale.languageCode : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);

    return initializeMessages(localeName).then((bool _) {
      Intl.defaultLocale = localeName;
      return AppLocalizations();
    });
  }

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
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

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return Constants.supportedLocales.contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) {
    return AppLocalizations.load(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) {
    return false;
  }
}
