import 'package:flutter/material.dart';
import 'main_shell.dart';
import 'package:app/app_theme.dart';
import 'package:app/app_locale.dart';
import 'package:app/app_settings.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // makes sure Flutter is loaded at this point
  await AppSettings.init();

  runApp(
    AppLocale(
      notifier: localeNotifier,
      child: MaterialApp(
        title: 'Easy2',
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: ThemeMode.system,
        home: const MainShell(),
      ),
    ),
  );
}
