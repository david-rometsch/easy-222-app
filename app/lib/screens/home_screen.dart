import 'package:flutter/material.dart';
import 'easy_222.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.title});

  final String title;

  @override 
  Widget build(BuildContext context){
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title:Text('Home')),
        drawer: Drawer(
          child: ListView(
            children: [
              DrawerHeader(
                child: Text('Menu'),
              ),
              Center(
                child: Text('Home'),
              ),
              ListTile(
                title: Text('Easy 222'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EasyTwo(title:'Easy Two'),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      )
    );
  }
}
