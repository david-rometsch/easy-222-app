### Empfohlene Phasen (Enum)

```dart
enum TimerPhase {
  idle,           // Scramble sichtbar, bereit zum Start
  inspecting,     // Inspection Countdown (15 → 0)
  holdStart,      // Finger wird gedrückt (Vorbereitung zum Start)
  solving,        // Stopwatch läuft
  holdEnd,        // Finger wird nach Solve gedrückt (zum Stoppen)
  finished,       // Solve beendet → Scramble neu laden
}
```

---

### Saubere `StatefulWidget` Struktur dafür:

```dart
class _SpeedCubeTimerState extends State<SpeedCubeTimer> {

  TimerPhase _phase = TimerPhase.idle;

  // Timer Werte
  int _inspectionTime = 15;
  int _solveTime = 0;

  Timer? _inspectionTimer;
  late StreamSubscription<int> _solveSubscription;

  Color _timerColor = Colors.white;

  @override
  void initState() {
    super.initState();
    _solveSubscription = _stopWatchTimer.rawTime.listen((value) {
      if (_phase == TimerPhase.solving) {
        setState(() {
          _solveTime = value;
          _updateTimerColor();
        });
      }
    });
  }

  @override
  void dispose() {
    _solveSubscription.cancel();
    _inspectionTimer?.cancel();
    super.dispose();
  }

  // ==================== Hauptmethoden ====================

  void startInspection() {
    setState(() {
      _phase = TimerPhase.inspecting;
      _inspectionTime = 15;
      _timerColor = Colors.yellow;
    });

    _inspectionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _inspectionTime--;
        if (_inspectionTime <= 0) {
          timer.cancel();
          startSolving();           // oder automatisch starten
        }
      });
    });
  }

  void startHoldStart() {
    setState(() => _phase = TimerPhase.holdStart);
    // Hier z.B. Timer grün werden lassen oder Animation
  }

  void startSolving() {
    setState(() {
      _phase = TimerPhase.solving;
      _solveTime = 0;
      _timerColor = Colors.green;
    });
    _stopWatchTimer.onStart();   // oder deine Start-Methode
  }

  void startHoldEnd() {
    setState(() => _phase = TimerPhase.holdEnd);
  }

  void finishSolve() {
    _stopWatchTimer.onStop();
    setState(() {
      _phase = TimerPhase.finished;
      _timerColor = Colors.white;
    });

    // Optional: kurze Verzögerung dann zurück zu idle mit neuem Scramble
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() {
          _phase = TimerPhase.idle;
          // Hier neuen Scramble laden
          _loadNewScramble();
        });
      }
    });
  }

  void _updateTimerColor() {
    final sec = _solveTime ~/ 1000;
    setState(() {
      if (sec < 8)      _timerColor = Colors.green;
      else if (sec < 12) _timerColor = Colors.orange;
      else               _timerColor = Colors.red;
    });
  }

  String get displayTime {
    switch (_phase) {
      case TimerPhase.inspecting:
        return _inspectionTime.toString();
      case TimerPhase.holdStart:
        return "READY";
      case TimerPhase.solving:
      case TimerPhase.holdEnd:
        return StopWatchTimer.getDisplayTime(_solveTime);
      default:
        return "00:00.00";
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(   // für Hold-Logik
      onLongPressStart: (_) {
        if (_phase == TimerPhase.idle) startHoldStart();
        if (_phase == TimerPhase.solving) startHoldEnd();
      },
      onLongPressEnd: (_) {
        if (_phase == TimerPhase.holdStart) {
          startSolving();
        }
        if (_phase == TimerPhase.holdEnd) {
          finishSolve();
        }
      },
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Scramble nur bei idle + finished
            if (_phase == TimerPhase.idle || _phase == TimerPhase.finished)
              ScrambleWidget(...),

            Text(
              displayTime,
              style: TextStyle(
                fontSize: 85,
                fontWeight: FontWeight.bold,
                color: _timerColor,
                fontFamily: 'Helvetica',
              ),
            ),

            const SizedBox(height: 30),
            Text(
              _phase.name.toUpperCase(),
              style: const TextStyle(fontSize: 20, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
```

---

### Ist das jetzt komplizierter?

Ja, etwas — aber **deutlich organisierter** als alles in `setState` oder `StreamBuilder` zu stopfen.

Möchtest du eine **noch einfachere Version** ohne Enum (nur mit mehreren bools), oder soll ich diese Version noch weiter anpassen (z.B. bessere Hold-Logik mit Farb-Feedback während Hold)?

Sag mir, wie du es lieber hättest.