Da steckt eigentlich ein Architektur-Missverständnis drin: Du vermischst gerade **„Modell, das Vokabeln erzeugt“**, **„Card-Entity“** und **FSRS-Logik**, obwohl das in sauberen Designs drei getrennte Ebenen sind.

Ich trenne das einmal sauber für dich auf und verbinde dann genau die Punkte, die dir fehlen.

---

# 🧠 1. Du hast zwei völlig unterschiedliche „Modelle“

## (A) Vocabulary Model (Generierung / Inhalte)

Das ist das, was dir offenbar fehlt:

👉 Ein Modell, das sagt:

```text
Apple → Apfel
Beispielsatz
Audio
Tags
```

Das kommt z. B. von:

* API
* Wörterbuch
* LLM
* eigener Generator

Beispiel:

```dart
class VocabItem {
  final String term;      // "Apple"
  final String translation; // "Apfel"
  final String example;
}
```

---

## (B) FSRS Card Model (Lernzustand)

Das ist **nicht Inhalt**, sondern **Gedächtnis-Zustand**:

```dart
class FsrsCard {
  final String vocabId;

  double stability;
  double difficulty;
  DateTime due;
}
```

👉 Wichtig: hier steht KEIN „Apple → Apfel“, sondern nur:

> „Wie gut kenne ich dieses Item?“

---

# 🔗 2. Die Verbindung zwischen beiden

Das ist der Teil, der dir fehlt:

👉 **Mapping über eine ID**

```text
VocabItem (Apple)
        ↓
FsrsCard (Learning State)
```

Beispiel:

```dart
class Card {
  final String vocabId;   // "apple_001"
  final double stability;
  final double difficulty;
}
```

---

# 🔁 3. Der komplette Flow

## Schritt 1: Vokabel wird erzeugt

```dart
final vocab = VocabItem(
  id: "apple_001",
  term: "Apple",
  translation: "Apfel",
);
```

---

## Schritt 2: FSRS-Karte wird erstellt

```dart
final card = FsrsCard(
  vocabId: vocab.id,
  stability: 0,
  difficulty: 0,
  due: DateTime.now(),
);
```

---

## Schritt 3: Lernen (Review)

```dart
scheduler.review(card, rating);
```

---

## Schritt 4: UI verbindet beide

```dart
final vocab = repo.getVocab(card.vocabId);

return CardView(
  front: vocab.term,
  back: vocab.translation,
  due: card.due,
);
```

---

# 🧩 4. Wichtiger Architekturpunkt

👉 FSRS „kennt“ niemals Wörter
👉 FSRS kennt nur IDs + Lernzustand

---

# 🧠 5. Warum das so getrennt ist

Wenn du es falsch koppeln würdest:

```dart
class Card {
  String word;
  String translation;
  Fsrs fsrs;
}
```

Problem:

* Inhalte und Lernlogik vermischt
* schlechte Skalierbarkeit
* kein Multi-Deck / Multi-Language Support
* kein Reuse von Vokabeln

---

# 🧠 6. Richtige mentale Modellierung

## Du hast 3 Ebenen:

### 1. Content Layer

```text
Apple → Apfel
```

### 2. Memory Layer (FSRS)

```text
Stability = 2.1
Difficulty = 6.3
```

### 3. Scheduler Engine

```text
berechnet nächste Wiederholung
```

---

# 💡 7. Einfaches Gesamtbild

```text
[Vocab Model]        → Inhalt
     ↓
[Card Model (FSRS)]  → Gedächtniszustand
     ↓
[Scheduler]          → Berechnung
     ↓
[UI]                 → Darstellung
```

---

# 🧾 Kurzantwort auf deine fehlende Verbindung

> „Wie kommt das zusammen?“

👉 Über eine gemeinsame ID (`vocabId`)
👉 Die Card speichert nur den Lernzustand
👉 Das Vocab Model liefert die Inhalte
👉 FSRS verbindet sich nie direkt mit Wörtern

---

Wenn du willst, kann ich dir als nächsten Schritt eine **komplette Flutter/Dart Architektur (inkl. Repositories + UseCases + FSRS Service)** skizzieren – das macht diese Trennung meistens komplett „klickbar“.
