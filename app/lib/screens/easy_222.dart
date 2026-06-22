import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:app/get_scramble.dart';
import 'package:shake/shake.dart';

class EasyTwo extends StatefulWidget {
  const EasyTwo({super.key});

  @override
  State<StatefulWidget> createState() => _EasyTwoState();
}

class _EasyTwoState extends State<EasyTwo> {
  final _scrambler = GetScramble();
  String _scramble = '';
  late ShakeDetector _shakeDetector;

  Future<void> _nextScramble() async {
    final s = await _scrambler.pickRandomScramble();
    setState(() => _scramble = s);
  }

  @override
  void initState() {
    super.initState();

    _init();
    _shakeDetector = ShakeDetector.autoStart(
      onPhoneShake: (ShakeEvent event) {
        _nextScramble();
      },
      shakeThresholdGravity:
          1.1, // sensitivity - lower value makes it more sensitive
      shakeSlopTimeMS: 300, // Minimum time between shake detections (ms)
      minimumShakeCount: 1, //  Reset shake count after this time (ms)
    );
  }

  Future<void> _init() async {
    await _scrambler.loadData();
    _nextScramble();
  }

  @override
  void dispose() {
    _shakeDetector.stopListening();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      // return to widget tree
      autofocus: true,
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent &&
            event.logicalKey == LogicalKeyboardKey.arrowRight) {
          _nextScramble();
          return KeyEventResult.handled; // return to event-system
        }
        return KeyEventResult.ignored;
      },
      child: GestureDetector(
        onTap: _nextScramble,
        child: Container(
          color: Colors.blue,
          child: Center(
            child: _scramble.isEmpty
              ? CircularProgressIndicator()
              : Text( 
                _scramble,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
