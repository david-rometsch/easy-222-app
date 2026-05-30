import 'package:flutter/material.dart';
import 'screens/easy_222.dart';
import 'screens/home_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key, required this.title});

  final String title;

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  Widget currentScreen = HomeScreen(title: 'Home');

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
                  currentScreen = EasyTwo(title: 'Easy Two');
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
