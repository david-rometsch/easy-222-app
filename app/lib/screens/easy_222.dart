import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
    return Focus(    // return to widget tree
      autofocus: true,
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent &&
            event.logicalKey == LogicalKeyboardKey.arrowRight) {
          onNextScramble();
          return KeyEventResult.handled;  // return to event-system
        }
        return KeyEventResult.ignored;
      },
      child: GestureDetector(
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
      )
    );
  }
}

