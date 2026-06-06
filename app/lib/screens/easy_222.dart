import 'package:flutter/material.dart';

class EasyTwo extends StatelessWidget {
  final String title;
  final String scramble;
  final VoidCallback onNextScramble;

  const EasyTwo({
    super.key, 
    required this.title, 
    required this.scramble,
    required this.onNextScramble, 
  });


  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onNextScramble,
      child: Container(
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
      ),
    );
  }
}

