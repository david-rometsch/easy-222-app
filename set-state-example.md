```dart
class ScrambleWidget extends StatefulWidget {
  @override
  State<ScrambleWidget> createState() => _ScrambleWidgetState();
}

class _ScrambleWidgetState extends State<ScrambleWidget> {
  int _index = 0;
  final List<String> _scrambles = ["R U R'", "F2 L D", "..."];

  void _nextScramble() {
    setState(() {
      _index = (_index + 1) % _scrambles.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _nextScramble, // später durch Shake ersetzen
      child: Text(_scrambles[_index]),
    );
  }
}
```

`StatefulWidget` erbt alles von Flutter, du überschreibst nur `createState()` um Flutter zu sagen welche State-Klasse den Zustand verwaltet. Die Methode selbst macht nichts ausser dieses Objekt zurückgeben.³