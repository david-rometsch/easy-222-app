### **Ziel**
Ein **All-in-One** JavaScript-Bundle mit `cubing.js` + deiner eigenen Scramble-Logik erstellen, das zuverlässig in `flutter_js` läuft und nur einen String zurückgibt.

---

## **1. JS-Projekt aufsetzen**

```bash
mkdir cubing-scrambler
cd cubing-scrambler
npm init -y
npm install cubing esbuild
```

---

## **2. Ordnerstruktur**

```
cubing-scrambler/
├── src/
│   └── scrambler.js          ← Dein Hauptcode
├── build.js                  ← Build-Skript
├── dist/
│   └── scrambler.bundle.js   ← (wird automatisch erzeugt)
└── package.json
```

---

## **3. Dein Hauptcode (`src/scrambler.js`)**

```js
import { randomScrambleForEvent } from "cubing/scramble";
// Falls du mehr brauchst:
// import { puzzles } from "cubing/puzzles";
// import { KPattern } from "cubing/kpuzzle";

// Deine eigenen Helfer-Funktionen / Dictionaries hier...
// z.B. deine rotate-Translation, spezielle Scramble-Definitionen usw.

export async function generateScramble(event) {
  try {
    const scramble = await randomScrambleForEvent(event);
    return scramble.toString();
  } catch (err) {
    console.error(err);
    return "Fehler beim Scramblen";
  }
}

// Weitere Funktionen falls gewünscht
export async function generateCustomScramble(event, options = {}) {
  // Deine spezielle Logik hier
  return generateScramble(event);
}

// Für Testzwecke (Node.js)
if (typeof process !== 'undefined') {
  generateScramble("333").then(console.log);
}
```

---

## **4. Build-Skript (`build.js`)**

```js
import { build } from 'esbuild';

build({
  entryPoints: ['src/scrambler.js'],
  bundle: true,
  outfile: 'dist/scrambler.bundle.js',
  format: 'iife',           // Wichtig für flutter_js
  globalName: 'CubingScrambler',
  minify: false,            // Beim Testen false lassen, später true
  target: 'es2020',
  platform: 'neutral',
}).then(() => {
  console.log('✅ Bundle erfolgreich erstellt: dist/scrambler.bundle.js');
}).catch((err) => {
  console.error('❌ Build fehlgeschlagen:', err);
  process.exit(1);
});
```

---

## **5. Bauen**

```bash
node build.js
```

Teste das Bundle außerhalb von Flutter:

```bash
node -e "
  import('./dist/scrambler.bundle.js').then(() => {
    CubingScrambler.generateScramble('333').then(s => console.log(s));
  });
"
```

---

## **6. Integration in Flutter**

### Abhängigkeiten (`pubspec.yaml`)

```yaml
dependencies:
  flutter_js: ^0.8.0   # oder aktuellste Version
  flutter:
    sdk: flutter
```

### Assets hinzufügen (`pubspec.yaml`)

```yaml
flutter:
  assets:
    - assets/js/scrambler.bundle.js
```

Kopiere `dist/scrambler.bundle.js` nach `assets/js/scrambler.bundle.js`.

### Dart Klasse (`lib/services/cube_scrambler.dart`)

```dart
import 'package:flutter/services.dart';
import 'package:flutter_js/flutter_js.dart';
import 'dart:convert';

class CubeScrambler {
  JavascriptRuntime? _js;
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    _js = getJavascriptRuntime();

    final jsCode = await rootBundle.loadString('assets/js/scrambler.bundle.js');
    final result = await _js!.evaluate(jsCode);

    if (result.isError) {
      throw Exception('Scrambler Laden fehlgeschlagen: ${result.stringResult}');
    }

    _initialized = true;
  }

  Future<String> getScramble(String event) async {
    await initialize();

    final result = await _js!.evaluate('CubingScrambler.generateScramble("$event")');

    if (result.isError) {
      return "Error: ${result.stringResult}";
    }
    return result.stringResult.trim();
  }
}
```

---

### **Zusammenfassung – Beste Praxis**

- Immer mit **esbuild + `format: 'iife'`** bundeln
- Globale Funktion unter `CubingScrambler` verfügbar machen
- Zuerst außerhalb von Flutter testen
- Dann erst in `flutter_js` einbinden

---

Möchtest du, dass ich diese Anleitung noch etwas erweitere (z.B. mit Error-Handling, mehreren Funktionen, oder minify-Optimierungen)?