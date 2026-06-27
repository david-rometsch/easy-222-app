import 'package:flutter/material.dart';
import 'screens/easy_222.dart';
import 'screens/record_222.dart';
import 'screens/settings.dart';
import 'app_locale.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  Widget _currentScreen = const Center(child: CircularProgressIndicator());
  final _recordKey = GlobalKey<RecordPageState>();

  void onGoToEasyTwo() {
    setState(() => _currentScreen = EasyTwo());
  }

  void onGoToSettings() {
    setState(() => _currentScreen = Settings(recordKey: _recordKey));
  }

  @override
  void initState() {
    super.initState(); // initialize parent state
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
            valueListenable: localeNotifier,
            // builder params: context / locale value / child (unused, hence _)
            builder: (context, locale, _) => TextButton(
              onPressed: () =>
                  localeNotifier.value = locale == 'de' ? 'en' : 'de',
              child: Text(localeNotifier.value == 'de' ? '🇬🇧' : '🇩🇪'),
            ),
          ),
        ],
      ),
      drawerEdgeDragWidth: 10,
      drawer: Drawer(
        width: 120,
        child: ListView(
          children: [
            // Records
            ListTile(
              title: Text(AppLocale.t(context, '222_record')),
              onTap: () {
                if (_currentScreen is! RecordPage) {
                  setState(() {
                    _currentScreen = RecordPage(
                      key: _recordKey,
                      onGoToEasyTwo: onGoToEasyTwo,
                      onGoToSettings: onGoToSettings,
                    );
                  });
                } else {
                  _recordKey.currentState?.setState(() => {});
                }
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
              title: Text('⚙'),
              onTap: () {
                setState(() {
                  _currentScreen = Settings(recordKey: _recordKey);
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
