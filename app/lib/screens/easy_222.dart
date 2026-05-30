import 'package:flutter/material.dart';

class EasyTwo extends StatelessWidget {
  const EasyTwo({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.blue,
      child: Center(
        child: Text('EasyTwo')
      )
    );
  }  
}
