import 'package:flutter/material.dart';

class EasyTwo extends StatelessWidget {
  const EasyTwo({super.key, required this.title, required this.scramble});

  final String title;
  final String scramble;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.blue,
      child: Center(
        child: Text(
          scramble,
          style: TextStyle(
            color: Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
