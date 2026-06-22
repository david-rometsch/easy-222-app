import 'package:flutter/material.dart';
import 'main_shell.dart';
import 'package:app/app_theme.dart';
import 'package:app/app_locale.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  // debugPaintSizeEnabled = true;
  WidgetsFlutterBinding.ensureInitialized(); // makes sure fltter is loaded at this point
  await Hive.initFlutter(); // init hive incl path

  final hive = await Hive.openBox('settings');

  if (!hive.containsKey('first_start')) {
    hive.put('wca_id', null);
    hive.put('first_start', true);
  }

  runApp(
    AppLocale(
      notifier: localeNotfifier,
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: ThemeMode.system,
        home: const MainShell(),
      ),
    ),
  );
}
