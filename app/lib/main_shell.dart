import 'package:flutter/material.dart';
import 'screens/easy_222.dart';
import 'screens/222_record.dart';
import 'screens/settings.dart';
import 'app_locale.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  Widget _currentScreen = const Center(child: CircularProgressIndicator());

  void onGoToEasyTwo() {
    setState(() => _currentScreen = EasyTwo());
  }

  @override
  void initState() {
    super.initState(); // initiation of parentclass
    _currentScreen = EasyTwo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // three elements [leading] [title] [actions]
        title: Align(
          // alignment: Alignment.centerRight,
          child: CircleAvatar(
            backgroundImage: AssetImage('assets/images/cube.jpg'),
            radius: 18,
          ),
        ),
        actions: [
          ValueListenableBuilder<String>(
            valueListenable: localeNotfifier,
            // parameter: context, actual value of localeNotfifier(free naming, _ for child optimizwation paameter not widtet!
            builder: (context, _locale, _) => TextButton(
              onPressed: () =>
                  localeNotfifier.value = _locale == 'de' ? 'en' : 'de',
              child: Text(localeNotfifier.value == 'de' ? '🇬🇧' : '🇩🇪'),
            ),
          ),
        ],
      ),

      drawer: Drawer(
        child: ListView(
          children: [
            // Records
            ListTile(
              title: Text(AppLocale.t(context, '222_record')),
              onTap: () {
                setState(() {
                  _currentScreen = RecordPage(onGoToEasyTwo: onGoToEasyTwo);
                });
                Navigator.pop(context);
              },
            ),

            // Easy Two
            ListTile(
              title: Text(AppLocale.t(context, 'e2_screen')),
              onTap: () {
                setState(() {
                  _currentScreen = EasyTwo();
                });
                Navigator.pop(context);
              },
            ),

            // Settings
            ListTile(
              title: Text(AppLocale.t(context, 'settings')),
              onTap: () {
                setState(() {
                  _currentScreen = Settings();
                });
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      body: _currentScreen,
    );
  }
}
