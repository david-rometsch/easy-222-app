import 'package:flutter/material.dart';
import 'main_shell.dart';
import 'package:app/app_theme.dart';
import 'package:app/app_locale.dart';


void main() {
  // debugPaintSizeEnabled = true;
  runApp(
    AppLocale(
      notifier: localeNotfifier,
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: ThemeMode.system,
        home: const MainShell()
      )
    )
  );
}


