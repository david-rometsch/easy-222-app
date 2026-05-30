Ja. Mit [cubing.js](https://cubing.js.org/?utm_source=chatgpt.com) bzw. dem `KPuzzle`-System kannst du eigene Permutations-Gruppen erstellen und daraus zufällige Zustände generieren.

Wenn du z. B. „2 Permutations-Gruppen“ meinst (etwa zwei getrennte Mengen von Teilen, die unabhängig gemischt werden), kannst du das über die `permutation`-Arrays definieren und anschließend zufällig shuffeln.

Beispielidee:

```js
function randomPermutation(n) {
  const arr = [...Array(n).keys()];

  for (let i = n - 1; i > 0; i--) {
    const j = Math.floor(Math.random() * (i + 1));
    [arr[i], arr[j]] = [arr[j], arr[i]];
  }

  return arr;
}

// Gruppe 1
const permA = randomPermutation(4);

// Gruppe 2
const permB = randomPermutation(4);

console.log(permA);
console.log(permB);
```

Falls du direkt mit `KPuzzle` arbeitest:

```js
import { KPuzzle } from "cubing/kpuzzle";
```

Dann definierst du die Orbit-Struktur und setzt zufällige Permutationen:

```js
const state = {
  EDGES: {
    pieces: randomPermutation(12),
    orientation: Array(12).fill(0),
  },
  CORNERS: {
    pieces: randomPermutation(8),
    orientation: Array(8).fill(0),
  },
};
```

Damit werden Edges und Corners jeweils zufällig verteilt.

Wenn du willst, kann ich dir auch zeigen:

* wie man **nur bestimmte Teile** mischt,
* wie man **gültige Cube-Permutationen** erzeugt,
* wie man mit `KPattern` arbeitet,
* oder wie man einen kompletten zufälligen Zustand in `cubing.js` generiert.
* 