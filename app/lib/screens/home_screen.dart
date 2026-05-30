import 'package:flutter/material.dart';
// import 'easy_222.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.title});

  final String title;

  @override 
  Widget build(BuildContext context){
    return Container(
      color:Colors.cyan,
      child: Center(
        child: Text('Hello use the Hamburger to navigate!')
      )
    );
  }
}
