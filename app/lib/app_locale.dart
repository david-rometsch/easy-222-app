import 'package:flutter/material.dart';
import 'l10n.dart';


final localeNotfifier = ValueNotifier<String>('en');  // nust be global!

class AppLocale extends InheritedNotifier<ValueNotifier<String>>  {
  const AppLocale({
    super.key,
    super.notifier,
    required super.child
  });


  static String t(BuildContext context, String key) {
    final locale = context
        .dependOnInheritedWidgetOfExactType<AppLocale>()!
        .notifier!
        .value;

    return localization[locale]![key] ?? key;
  }
}

