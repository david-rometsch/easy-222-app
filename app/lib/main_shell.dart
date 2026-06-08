import 'package:flutter/material.dart';
import 'screens/easy_222.dart';
import 'screens/222_record.dart';
import 'get_scramble.dart';
import 'app_locale.dart';
import 'package:shake/shake.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  Widget _currentScreen = const CircularProgressIndicator();
  dynamic _currentScramble;
  final _getScramble = GetScramble();
  ShakeDetector? _shakeDetector;

  // callback for easy two
  void _nextScramble() {
    _getScramble.pickRandomScramble().then(
      (s) => setState(() {
        _currentScramble = s;
        _currentScreen = EasyTwo(scramble: s, onNextScramble: _nextScramble);
      }),
    );
  }

  void onGoToEasyTwo() {
  setState(
    () => _currentScreen = EasyTwo(
      scramble: _currentScramble,
      onNextScramble: _nextScramble,
    ),
  );
}


@override
void initState() {
  super.initState(); // initiation of parentclass
  // callback fuer shakedetection
  _shakeDetector = ShakeDetector.autoStart(
    onPhoneShake: (ShakeEvent event) {
      _nextScramble();
    },
    // Configure sensitivity - lower value makes it more sensitive
    shakeThresholdGravity: 1.1,
    // Minimum time between shake detections (ms)
    shakeSlopTimeMS: 300,
    // // Reset shake count after this time (ms)
    // shakeCountResetTime: 1000,
    // Number of shakes required before triggering
    minimumShakeCount: 1,
  );

  //then is exewcuted immediatley, s as result form pickRandomScramble
  _getScramble.pickRandomScramble().then(
    // because no await herer.
    (s) => setState(() {
      _currentScramble = s;
      _currentScreen = EasyTwo(
        // has to be herer, because async 'then'
        scramble: _currentScramble,
        onNextScramble: _nextScramble,
      );
    }),
  );
}

@override
void dispose() {
  _shakeDetector?.stopListening();
  super.dispose();
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
            // DrawerHeader(),
            ListTile(
              title: Text(AppLocale.t(context, '222_record')),
              onTap: () {
                setState(() {
                  _currentScreen = RecordPage(onGoToEasyTwo: onGoToEasyTwo);
                });
                Navigator.pop(context);
              },
            ),

            ListTile(
              title: Text(AppLocale.t(context, 'e2_screen')),
              onTap: () {
                setState(() {
                  _currentScreen = EasyTwo(
                    scramble: _currentScramble,
                    onNextScramble: _nextScramble,
                  );
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
