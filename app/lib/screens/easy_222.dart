import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:app/get_scramble.dart';
import 'package:app/app_settings.dart';
import 'package:shake/shake.dart';
import 'package:app/app_locale.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';

enum TimerPhase { idle, inspection, holdStart, solve }

class SolveRecord {
  final int nr;
  final int inspectionMs;
  final int holdMs;
  final int solveMs;

  const SolveRecord({
    required this.nr,
    required this.inspectionMs,
    required this.holdMs,
    required this.solveMs,
  });

  String toCsvRow() => '$nr,$inspectionMs,$holdMs,$solveMs\n';
}

class EasyTwo extends StatefulWidget {
  const EasyTwo({super.key});

  @override
  State<StatefulWidget> createState() => _EasyTwoState();
}

class _EasyTwoState extends State<EasyTwo> {
  final _scrambler = GetScramble();
  String _scramble = '';
  late ShakeDetector _shakeDetector;

  TimerPhase _phase = TimerPhase.idle;

  // inspection and hold run simultaneously during holdStart; both stop at _startSolve
  final _inspectionWatch = Stopwatch();
  final _holdWatch = Stopwatch();
  StreamSubscription<void>? _inspectionTick;

  // solve timing via package stream
  final StopWatchTimer _stopWatchTimer = StopWatchTimer();
  late StreamSubscription<int> _solveSub;
  int _solveMs = 0;

  // captured at the moment finger lifts (holdStart → solve)
  int _pendingInspMs = 0;
  int _pendingHoldMs = 0;

  // persisted via Hive; nr counter never resets so CSV rows stay unique across exports
  late Box _solvesBox;
  final List<SolveRecord> _records = [];
  int _nextNr = 1;

  @override
  void initState() {
    super.initState();
    _solveSub = _stopWatchTimer.rawTime.listen((ms) {
      if (_phase == TimerPhase.solve) {
        setState(() => _solveMs = ms);
      }
    });
    _init();
    _shakeDetector = ShakeDetector.autoStart(
      onPhoneShake: (ShakeEvent event) {
        if (AppSettings.toggleShake) _nextScramble();
      },
      shakeThresholdGravity: 1.1,
      shakeSlopTimeMS: 300,
      minimumShakeCount: 1,
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
        if (AppSettings.toggleShake) _nextScramble();
      },
      shakeThresholdGravity: 1.1,
      shakeSlopTimeMS: 300,
      minimumShakeCount: 1,
    );
  }

  @override
  void dispose() {
    _shakeDetector.stopListening();
    _inspectionTick?.cancel();
    _solveSub.cancel();
    _stopWatchTimer.dispose();
    super.dispose();
  }

  Future<void> _init() async {
    _solvesBox = await Hive.openBox('solves');
    _loadRecordsFromHive();
    await _scrambler.loadData();
    _nextScramble();
  }

  void _loadRecordsFromHive() {
    _nextNr = (_solvesBox.get('next_nr', defaultValue: 1) as num).toInt();
    final raw = _solvesBox.get('records', defaultValue: <dynamic>[]);
    if (raw is! List || raw.isEmpty) return;
    setState(() {
      _records.clear();
      for (final e in raw) {
        if (e is List && e.length >= 4) {
          _records.add(SolveRecord(
            nr: (e[0] as num).toInt(),
            inspectionMs: (e[1] as num).toInt(),
            holdMs: (e[2] as num).toInt(),
            solveMs: (e[3] as num).toInt(),
          ));
        }
      }
    });
  }

  Future<void> _nextScramble() async {
    final s = await _scrambler.pickRandomScramble();
    setState(() => _scramble = s);
  }

  void _saveRecordsToHive() {
    _solvesBox.put(
      'records',
      _records.map((r) => [r.nr, r.inspectionMs, r.holdMs, r.solveMs]).toList(),
    );
    _solvesBox.put('next_nr', _nextNr);
  }

  // ── state transitions ──────────────────────────────────────────────────────

  void _startInspection() {
    _inspectionWatch.reset();
    _inspectionWatch.start();
    _inspectionTick?.cancel();
    // periodic rebuild so inspection display stays live
    _inspectionTick = Stream<void>.periodic(const Duration(milliseconds: 16))
        .listen((_) {
      if (mounted) setState(() {});
    });
    setState(() => _phase = TimerPhase.inspection);
  }

  void _startHold() {
    _holdWatch.reset();
    _holdWatch.start();
    setState(() => _phase = TimerPhase.holdStart);
  }

  void _startSolve() {
    // capture both at the exact same moment before stopping either
    _pendingInspMs = _inspectionWatch.elapsedMilliseconds;
    _pendingHoldMs = _holdWatch.elapsedMilliseconds;
    _inspectionWatch.stop();
    _holdWatch.stop();
    _inspectionTick?.cancel();
    _inspectionTick = null;

    _stopWatchTimer.onStopTimer();
    _stopWatchTimer.onResetTimer();
    _stopWatchTimer.onStartTimer();
    setState(() {
      _solveMs = 0;
      _phase = TimerPhase.solve;
    });
  }

  void _cancelHold() {
    _holdWatch.stop();
    setState(() => _phase = TimerPhase.inspection);
  }

  void _finishSolve() {
    _stopWatchTimer.onStopTimer();
    final record = SolveRecord(
      nr: _nextNr++,
      inspectionMs: _pendingInspMs,
      holdMs: _pendingHoldMs,
      solveMs: _solveMs,
    );
    setState(() {
      _records.add(record);
      _phase = TimerPhase.idle;
    });
    _nextScramble();
    _saveRecordsToHive();
  }

  // ── export / download / reset ──────────────────────────────────────────────

  bool _isExporting = false;

  // moves current table to CSV (append) — second call while first is in
  // flight is a no-op; table clears immediately so UI reflects the move
  Future<void> _exportToCsv() async {
    if (_records.isEmpty || _isExporting) return;
    _isExporting = true;
    final toWrite = List<SolveRecord>.from(_records);
    setState(() => _records.clear());
    _saveRecordsToHive();
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/easy2_solves.csv');
      if (!await file.exists()) {
        await file.writeAsString('nr,inspection_ms,hold_ms,solve_ms\n');
      }
      await file.writeAsString(
        toWrite.map((r) => r.toCsvRow()).join(),
        mode: FileMode.append,
      );
    } catch (_) {
    } finally {
      _isExporting = false;
    }
  }

  // shares the CSV file without touching it
  Future<void> _downloadCsv() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/easy2_solves.csv');
      if (!await file.exists()) return;
      await Share.shareXFiles([XFile(file.path)]);
    } catch (_) {}
  }

  // deletes the CSV file — does not touch the Hive records
  Future<void> _resetCsv() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/easy2_solves.csv');
      if (await file.exists()) await file.delete();
    } catch (_) {}
  }

  // ── display ────────────────────────────────────────────────────────────────

  String get _displayTime {
    switch (_phase) {
      case TimerPhase.idle:
        return _formatSolve(_solveMs);
      case TimerPhase.inspection:
      case TimerPhase.holdStart:
        return (_inspectionWatch.elapsedMilliseconds ~/ 1000).toString();
      case TimerPhase.solve:
        return _formatSolve(_solveMs);
    }
  }

  // minimal digits: 3.42 or 1:03.42
  String _formatSolve(int ms) {
    final cs = (ms ~/ 10) % 100;
    final totalS = ms ~/ 1000;
    final s = totalS % 60;
    final m = totalS ~/ 60;
    final csStr = cs.toString().padLeft(2, '0');
    return m > 0 ? '$m:${s.toString().padLeft(2, '0')}.$csStr' : '$s.$csStr';
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      autofocus: true,
      onKeyEvent: (node, event) {
        if (event.logicalKey == LogicalKeyboardKey.arrowRight &&
            event is KeyDownEvent) {
          _nextScramble();
          return KeyEventResult.handled;
        }
        if (event.logicalKey == LogicalKeyboardKey.space) {
          if (event is KeyDownEvent) {
            switch (_phase) {
              case TimerPhase.idle:
                _startInspection();
              case TimerPhase.inspection:
                _startHold();
              case TimerPhase.solve:
                _finishSolve();
              case TimerPhase.holdStart:
                break;
            }
            return KeyEventResult.handled;
          }
          if (event is KeyUpEvent && _phase == TimerPhase.holdStart) {
            _startSolve();
            return KeyEventResult.handled;
          }
        }
        return KeyEventResult.ignored;
      },
      child: Column(
        children: [
          Expanded(
            flex: 2,
            child: Listener(
              onPointerDown: (_) {
                switch (_phase) {
                  case TimerPhase.idle:
                    _startInspection();
                  case TimerPhase.inspection:
                    _startHold();
                  case TimerPhase.solve:
                    _finishSolve();
                  case TimerPhase.holdStart:
                    break;
                }
              },
              onPointerUp: (_) {
                if (_phase == TimerPhase.holdStart) _startSolve();
              },
              onPointerCancel: (_) {
                if (_phase == TimerPhase.holdStart) _cancelHold();
              },
              child: ColoredBox(
                color: Colors.blue,
                child: SizedBox.expand(
                  child: Column(
                    children: [
                      // top 1/4: scramble
                      Expanded(
                        flex: 1,
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: _phase != TimerPhase.solve
                                ? (_scramble.isEmpty
                                    ? const CircularProgressIndicator()
                                    : Text(
                                        _scramble,
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 48,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ))
                                : const SizedBox.shrink(),
                          ),
                        ),
                      ),
                      // remaining 3/4: timer
                      Expanded(
                        flex: 3,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _displayTime,
                                style: const TextStyle(
                                  fontFamily: 'monospace',
                                  fontWeight: FontWeight.bold,
                                  fontSize: 72,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                _phase.name.toUpperCase(),
                                style: const TextStyle(
                                    fontSize: 20, color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: ColoredBox(
              color: const Color(0xFF1A237E),
              child: _buildSolvesTable(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSolvesTable() {
    return Column(
      children: [
        ColoredBox(
          color: const Color(0xFF37474F),
          child: Row(
            children: [
              Expanded(
                child: _tableRow('Nr', 'Insp', 'Hold', 'Solve', isHeader: true),
              ),
              IconButton(
                onPressed: _exportToCsv,
                icon: const Icon(Icons.archive, color: Colors.white),
                tooltip: 'Export to CSV',
                padding: const EdgeInsets.symmetric(horizontal: 8),
              ),
              IconButton(
                onPressed: _downloadCsv,
                icon: const Icon(Icons.download, color: Colors.white),
                tooltip: 'Download CSV',
                padding: const EdgeInsets.symmetric(horizontal: 8),
              ),
              IconButton(
                onPressed: _resetCsv,
                icon: const Icon(Icons.delete_sweep, color: Colors.white),
                tooltip: 'Reset CSV',
                padding: const EdgeInsets.symmetric(horizontal: 8),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _records.length,
            itemBuilder: (context, index) {
              final r = _records[_records.length - 1 - index];
              return _tableRow(
                r.nr.toString(),
                _formatSolve(r.inspectionMs),
                _formatSolve(r.holdMs),
                _formatSolve(r.solveMs),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _tableRow(
    String nr,
    String insp,
    String hold,
    String solve, {
    bool isHeader = false,
  }) {
    final style = TextStyle(
      color: Colors.white,
      fontFamily: 'monospace',
      fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          SizedBox(width: 40, child: Text(nr, style: style)),
          Expanded(child: Text(insp, style: style)),
          Expanded(child: Text(hold, style: style)),
          Expanded(child: Text(solve, style: style)),
        ],
      ),
    );
  }
}
