import 'package:flutter/material.dart';
import 'screens/easy_222.dart';
import 'screens/home_screen.dart';
import 'get_scramble.dart';

class MainShell extends StatefulWidget {
  final String title;

  const MainShell({super.key, required this.title});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  late Widget currentScreen;

  dynamic currentScramble;
  final getScramble = GetScramble();

  void _nextScramble() {
    getScramble.pickRandomScramble().then(
      (s) => setState(() {
        currentScramble = s;
        currentScreen = EasyTwo(
          title: 'Easy 222',
          scramble: s,
          onNextScramble: _nextScramble,
        );
      }),
    );
  }

  @override
  void initState() {
    super.initState(); // initiation of parentclass
    //then is exewcuted immediatley, s as result form pickRandomScramble
    getScramble.pickRandomScramble().then(  // because no await herer. 
      (s) => setState(() {
        currentScramble = s;
        currentScreen = EasyTwo(  // has to be herer, because async 'then'
          title: 'Easy 222',
          scramble: currentScramble,
          onNextScramble: _nextScramble,
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),

      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(child: Text('Menu')),

            ListTile(
              title: Text('Home'),
              onTap: () {
                setState(() {
                  currentScreen = HomeScreen(title: 'Home');
                });
                Navigator.pop(context);
              },
            ),

            ListTile(
              title: Text('Easy 222'),
              onTap: () {
                setState(() {
                  currentScreen = EasyTwo(
                    title: 'Easy 222',
                    scramble: currentScramble,
                    onNextScramble: _nextScramble,
                  );
                });
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      body: currentScreen,
    );
  }
}
