import 'dart:math';

import 'package:flutter/material.dart';
import 'screens/easy_222.dart';
import 'screens/home_screen.dart';
import 'dart:convert';
import 'package:flutter/services.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key, required this.title});

  final String title;

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  Widget currentScreen = HomeScreen(title: 'Home');
  dynamic currentScramble = '';

  @override
  void initState() {
    super.initState();
    _pickRandomScramble().then((s) => setState(() {
      currentScramble = s;
    }));
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
                  currentScreen = EasyTwo(title: 'Easy 222', scramble: currentScramble);
                });
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),

      body: GestureDetector(
        onTap: () async {
          final scramble = await _pickRandomScramble();
          setState(() { currentScramble = scramble; });
        },
        child: currentScreen is EasyTwo
          ? EasyTwo(title: 'Easy 222', scramble: currentScramble)
          : HomeScreen(title: 'Home')
      ),
    );
  }

  Future<dynamic> loadData() async {
    final response = await rootBundle.loadString(
      'assets/scrambles/two_by_two/222scrambles.json',
    );
    // debugPrint(jsonDecode(response).toString());
    return jsonDecode(response);
  }

  _pickRandomScramble() async {
    List<dynamic> scrambleList = await loadData();
    return scrambleList[Random().nextInt(scrambleList.length)];
  }
}
