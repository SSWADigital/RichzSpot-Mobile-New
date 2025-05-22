import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LocalizationHelper {
  static Locale? _currentLocale;
  static Map<String, String> _localizedStrings = {};

  static Locale? get currentLocale => _currentLocale;

  static Future<void> load(Locale locale) async {
    _currentLocale = locale;
    String jsonString = await rootBundle.loadString('assets/i18n/${locale.languageCode}.json');
    Map<String, dynamic> jsonMap = jsonDecode(jsonString);
    _localizedStrings = jsonMap.map((key, value) {
      return MapEntry(key, value.toString());
    });
  }

  static String translate(String key) {
    return _localizedStrings[key] ?? key; // Return key if translation not found
  }

  // Mendapatkan locale yang didukung
  static List<Locale> get supportedLocales => [
    const Locale('en', ''), // English
    const Locale('id', ''), // Indonesian
  ];

  // Callback untuk LocalizationsDelegate
  static Future<LocalizationHelper> delegateLoad(Locale locale) async {
    LocalizationHelper appLocalizations = LocalizationHelper();
    await LocalizationHelper.load(locale);
    return appLocalizations;
  }
}

// Extension untuk memudahkan penggunaan di Widget
extension LocalizationExtension on String {
  String get tr => LocalizationHelper.translate(this);
}