import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppLocale {
  AppLocale(this.locale);

  Locale? locale;
  Map<String, String>? _loadedLocalizedValues;

  static AppLocale of(BuildContext context) {
    return Localizations.of<AppLocale>(context, AppLocale)!;
  }

  /// ✅ تحميل اللغة في كل مرة يتم فيها hot reload
  Future<void> loadLang() async {
    try {
      final String langFile = await rootBundle.loadString(
        'assets/lang/${locale!.languageCode}.json',
      );

      final Map<String, dynamic> loadedValues = jsonDecode(langFile);
      _loadedLocalizedValues = loadedValues.map(
            (key, value) => MapEntry(key, value.toString()),
      );
    } catch (e) {
      debugPrint('Error loading language file: $e');
      _loadedLocalizedValues = {};
    }
  }

  String? getTranslated(String key) {
    return _loadedLocalizedValues?[key] ?? key;
  }

  static const LocalizationsDelegate<AppLocale> delegate = _AppLocalDelegate();
}

class _AppLocalDelegate extends LocalizationsDelegate<AppLocale> {
  const _AppLocalDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'ar', 'tr', 'de'].contains(locale.languageCode);
  }

  @override
  Future<AppLocale> load(Locale locale) async {
    final AppLocale appLocale = AppLocale(locale);
    await appLocale.loadLang();
    return appLocale;
  }

  /// ✅ إعادة التحميل عند Hot Reload
  @override
  bool shouldReload(_AppLocalDelegate old) => true; // 👈 هنا السر
}

/// Getter for translation
String getLang(BuildContext context, String key) {
  return AppLocale.of(context).getTranslated(key) ?? '';
}

/// Check if current locale is Arabic
bool isArabic(BuildContext context) {
  final Locale myLocale = Localizations.localeOf(context);
  return myLocale.languageCode == 'ar';
}
