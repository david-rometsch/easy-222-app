import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:app/get_scramble.dart';
import 'package:app/app_settings.dart';
import 'package:shake/shake.dart';
import 'package:app/app_locale.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';

class EasyTwo extends StatefulWidget {
  const EasyTwo({super.key});

  @override
  State<StatefulWidget> createState() => _EasyTwoState();
}

enum TimerPhase { idle, solving }

class _EasyTwoState extends State<EasyTwo> {
  final _scrambler = GetScramble();
  String _scramble = '';
  late ShakeDetector _shakeDetector;
  final StopWatchTimer _stopWatchTimer = StopWatchTimer();
  TimerPhase _timerPhase = TimerPhase.idle;

  Future<void> _nextScramble() async {
    final s = await _scrambler.pickRandomScramble();
    setState(() => _scramble = s);
  }

  String formatTime(double sec) {
    final hr = sec /~ 3600;
    final min = (sec % 3600) /~ 60;
    final s= sec % 60;  

    if (hr > 0) return '$hr:$min:$s';
    if (min > 0) return '$min:$s';
    return '$s';
  } 

  @override
  void initState() {
    super.initState();

    _init();
    _shakeDetector = ShakeDetector.autoStart(
      onPhoneShake: (ShakeEvent event) {
        if (AppSettings.toggleShake) {
          _nextScramble();
        }
      },
      shakeThresholdGravity:
          1.1, // sensitivity - lower value makes it more sensitive
      shakeSlopTimeMS: 300, // Minimum time between shake detections (ms)
      minimumShakeCount: 1, //  Reset shake count after this time (ms)
    );
    if (!AppSettings.toggleShake &&
        AppSettings.firstStart &&
        !AppSettings.shakeShown) {
      AppSettings.shakeShown = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocale.t(context, 'scr_off_msg'))),
        );
      });
    }
  }

  @override
  void didUpdateWidget(covariant EasyTwo oldWidget) {
    super.didUpdateWidget(oldWidget);

    _restartShakeDetector();
  }

  void _restartShakeDetector() {
    _shakeDetector.stopListening();

    _shakeDetector = ShakeDetector.autoStart(
      onPhoneShake: (event) {
        if (AppSettings.toggleShake) {
          _nextScramble();
        }
      },
      shakeThresholdGravity: 1.1,
      shakeSlopTimeMS: 300,
      minimumShakeCount: 1,
    );
  }

  @override
  void dispose() {
    super.dispose();
    _shakeDetector.stopListening();
    _stopWatchTimer.dispose();
  }

  Future<void> _init() async {
    await _scrambler.loadData();
    _nextScramble();
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
        onTap: () {
          switch (_timerPhase) {
            case TimerPhase.idle:
              _stopWatchTimer.onStartTimer();
              _timerPhase = TimerPhase.solving;
            case TimerPhase.solving:
              _stopWatchTimer.onStopTimer();
              _timerPhase = TimerPhase.idle;
              _nextScramble();
          }
        },
        child: Container(
          color: Colors.blue,
          child: Column(
            children: [
              Center(
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
              StreamBuilder<int>(
                stream: _stopWatchTimer.rawTime,
                initialData: 0,
                builder: (context, snap) {
                  final rawTime = snap.data ?? 0;
                  // final displayTime = StopWatchTimer.getDisplayTime(value);
                  return Column(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Text(
                          formatTime(rawTime / 1000),
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
