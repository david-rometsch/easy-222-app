import 'package:flutter/material.dart';
import 'screens/easy_222.dart';
import 'screens/222_record.dart';
import 'get_scramble.dart';
import 'app_locale.dart';

class MainShell extends StatefulWidget {

  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  Widget _currentScreen = const CircularProgressIndicator();
  dynamic _currentScramble;
  final _getScramble = GetScramble();

  void _nextScramble() {
    _getScramble.pickRandomScramble().then(
      (s) => setState(() {
        _currentScramble = s;
        _currentScreen = EasyTwo(
          title: AppLocale.t(context, 'title'),
          scramble: s,
          onNextScramble: _nextScramble,
        );
      }),
    );
  }

  void _goToEasyTwo() {
    setState(() => _currentScreen = EasyTwo(title: 'Easy Two', scramble: _currentScramble, onNextScramble: _nextScramble));
  }

  @override
  void initState() {
    super.initState(); // initiation of parentclass
    //then is exewcuted immediatley, s as result form pickRandomScramble
    _getScramble.pickRandomScramble().then(  // because no await herer. 
      (s) => setState(() {
        _currentScramble = s;
        _currentScreen = EasyTwo(  // has to be herer, because async 'then'
          title: 'Easy 222',
          scramble: _currentScramble,
          onNextScramble: _nextScramble,
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(  // three elements [leading] [title] [actions]
        title: Align(
          // alignment: Alignment.centerRight,
          child: CircleAvatar(
            backgroundImage: AssetImage('assets/images/cube.jpg'),
            radius: 18,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => localeNotfifier.value = 'de', 
            child: Text('de')
          ) 
        ],
      ),

      drawer: Drawer(
        child: ListView(
          children: [
            // DrawerHeader(),
            ListTile(
              title: Text('My Records'),
              onTap: () {
                setState(() {
                  _currentScreen = RecordPage(
                    title: 'My Records',
                    goToEasyTwo: _goToEasyTwo
                  );
                });
                Navigator.pop(context);
              },
            ),

            ListTile(
              title: Text('Easy 222'),
              onTap: () {
                setState(() {
                  _currentScreen = EasyTwo(
                    title: 'Easy 222',
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
      body: _currentScreen 
    );
  }
}
