import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
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
  final int solvedAtEpochS;

  const SolveRecord({
    required this.nr,
    required this.inspectionMs,
    required this.holdMs,
    required this.solveMs,
    required this.solvedAtEpochS,
  });

  String toCsvRow() {
    final ts = DateTime.fromMillisecondsSinceEpoch(solvedAtEpochS * 1000)
        .toIso8601String()
        .split('.')
        .first;
    return '$nr,$inspectionMs,$holdMs,$solveMs,$ts\n';
  }
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

  // guards against a second finger (from a stop-tap using 2 fingers)
  // immediately re-triggering inspection right after a solve finishes
  DateTime? _idleLockedUntil;
  bool get _idleLocked =>
      _idleLockedUntil != null && DateTime.now().isBefore(_idleLockedUntil!);

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
    // Accelerometer on Android is a non-dangerous sensor — no runtime permission required.
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
            solvedAtEpochS: e.length >= 5 ? (e[4] as num).toInt() : 0,
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
      _records
          .map((r) =>
              [r.nr, r.inspectionMs, r.holdMs, r.solveMs, r.solvedAtEpochS])
          .toList(),
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
      solvedAtEpochS: DateTime.now().millisecondsSinceEpoch ~/ 1000,
    );
    setState(() {
      _records.add(record);
      _phase = TimerPhase.idle;
    });
    // a second finger landing a beat after the stop-tap must not be read as
    // "start inspection again" — block idle taps briefly after finishing.
    _idleLockedUntil = DateTime.now().add(const Duration(seconds: 1));
    _nextScramble();
    _saveRecordsToHive();
  }

  // ── export / download / reset ──────────────────────────────────────────────

  bool _isExporting = false;

  static const _csvHeader = 'nr,inspection_ms,hold_ms,solve_ms,solved_at\n';

  // moves current table to CSV (append) — second call while first is in
  // flight is a no-op; table clears immediately so UI reflects the move.
  // web has no filesystem, so the accumulated CSV text lives in Hive instead
  // of a real file there; every other platform keeps writing the real file.
  Future<void> _exportToCsv() async {
    if (_records.isEmpty || _isExporting) return;
    _isExporting = true;
    final toWrite = List<SolveRecord>.from(_records);
    setState(() => _records.clear());
    _saveRecordsToHive();
    try {
      if (kIsWeb) {
        final existing =
            _solvesBox.get('csv_export', defaultValue: '') as String;
        final buffer = StringBuffer(existing);
        if (existing.isEmpty) buffer.write(_csvHeader);
        for (final r in toWrite) {
          buffer.write(r.toCsvRow());
        }
        await _solvesBox.put('csv_export', buffer.toString());
        return;
      }
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/easy2_solves.csv');
      if (!await file.exists()) {
        await file.writeAsString(_csvHeader);
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

  // makes the exported CSV available to the user without touching it.
  // - Android/iOS: native share sheet (unchanged).
  // - web: share_plus has no filesystem to read from, so the CSV bytes are
  //   handed to it directly; it falls back to a browser download when the
  //   Web Share API isn't available (desktop browsers).
  // - other desktop (Linux/macOS/Windows): share_plus has no share
  //   implementation there (Linux throws UnimplementedError), so the file is
  //   copied into the platform Downloads folder instead.
  Future<void> _downloadCsv() async {
    try {
      if (kIsWeb) {
        final csv = _solvesBox.get('csv_export') as String?;
        if (csv == null || csv.isEmpty) return;
        Share.downloadFallbackEnabled = true;
        await Share.shareXFiles([
          XFile.fromData(
            Uint8List.fromList(utf8.encode(csv)),
            name: 'easy2_solves.csv',
            mimeType: 'text/csv',
          ),
        ]);
        return;
      }
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/easy2_solves.csv');
      if (!await file.exists()) return;
      if (Platform.isAndroid || Platform.isIOS) {
        await Share.shareXFiles([XFile(file.path)]);
        return;
      }
      final downloadsDir = await getDownloadsDirectory();
      if (downloadsDir == null) return;
      final dest = await file.copy('${downloadsDir.path}/easy2_solves.csv');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gespeichert: ${dest.path}')),
        );
      }
    } catch (_) {}
  }

  // deletes the CSV file (or, on web, the Hive-backed CSV text) — does not
  // touch the Hive solve records.
  Future<void> _resetCsv() async {
    try {
      if (kIsWeb) {
        await _solvesBox.delete('csv_export');
        return;
      }
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/easy2_solves.csv');
      if (await file.exists()) await file.delete();
    } catch (_) {}
  }

  // ── display ────────────────────────────────────────────────────────────────

  Color get _timerColor {
    switch (_phase) {
      case TimerPhase.inspection:
        return Colors.red;
      case TimerPhase.holdStart:
        return Colors.amber;
      default:
        return Colors.white;
    }
  }

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
                if (_idleLocked) break;
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
                    if (_idleLocked) break;
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
                            child: _phase == TimerPhase.idle
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
                                style: TextStyle(
                                  fontFamily: 'monospace',
                                  fontWeight: FontWeight.bold,
                                  fontSize: 72,
                                  color: _timerColor,
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
              color: Colors.blue,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: ColoredBox(
                    color: Colors.white,
                    child: _buildSolvesTable(),
                  ),
                ),
              ),
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
          color: Colors.grey[100]!,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    onPressed: _exportToCsv,
                    icon: Icon(Icons.archive, color: Colors.grey[700]),
                    tooltip: 'Export to CSV',
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                  IconButton(
                    onPressed: _downloadCsv,
                    icon: Icon(Icons.download, color: Colors.grey[700]),
                    tooltip: 'Download CSV',
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                  IconButton(
                    onPressed: _resetCsv,
                    icon: Icon(Icons.delete_sweep, color: Colors.grey[700]),
                    tooltip: 'Reset CSV',
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                ],
              ),
              _tableRow('Nr', 'Insp', 'Hold', 'Solve', isHeader: true),
            ],
          ),
        ),
        const Divider(height: 1, color: Color(0xFFE0E0E0)),
        Expanded(
          child: ListView.separated(
            itemCount: _records.length,
            separatorBuilder: (_, _) =>
                const Divider(height: 1, color: Color(0xFFE0E0E0)),
            itemBuilder: (context, index) {
              final r = _records[_records.length - 1 - index];
              return Dismissible(
                key: ValueKey(r.nr),
                direction: DismissDirection.horizontal,
                background: _deleteSwipeBackground(Alignment.centerLeft),
                secondaryBackground:
                    _deleteSwipeBackground(Alignment.centerRight),
                confirmDismiss: (_) => _confirmDeleteRecord(r),
                onDismissed: (_) => _deleteRecord(r),
                child: _tableRow(
                  (_records.length - index).toString(),
                  _formatSolve(r.inspectionMs),
                  _formatSolve(r.holdMs),
                  _formatSolve(r.solveMs),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _deleteSwipeBackground(Alignment alignment) {
    return Container(
      color: Colors.red,
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: const Icon(Icons.delete, color: Colors.white),
    );
  }

  Future<bool> _confirmDeleteRecord(SolveRecord r) async {
    final body = AppLocale.t(context, 'delete_solve_body')
        .replaceAll('{nr}', r.nr.toString())
        .replaceAll('{time}', _formatSolve(r.solveMs));
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocale.t(context, 'delete_solve_title')),
        content: Text(body),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(AppLocale.t(context, 'cancel')),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(AppLocale.t(context, 'delete')),
          ),
        ],
      ),
    );
    return confirmed ?? false;
  }

  void _deleteRecord(SolveRecord r) {
    setState(() => _records.removeWhere((e) => e.nr == r.nr));
    _saveRecordsToHive();
  }

  Widget _tableRow(
    String nr,
    String insp,
    String hold,
    String solve, {
    bool isHeader = false,
  }) {
    final style = TextStyle(
      color: Colors.grey[800],
      fontFamily: 'monospace',
      fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            child: Text(nr, style: style, textAlign: TextAlign.right),
          ),
          Expanded(
            child: Text(insp, style: style, textAlign: TextAlign.right),
          ),
          Expanded(
            child: Text(hold, style: style, textAlign: TextAlign.right),
          ),
          Expanded(
            child: Text(solve, style: style, textAlign: TextAlign.right),
          ),
        ],
      ),
    );
  }
}
