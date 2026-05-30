Hier ist ein **komplettes minimales FSRS + Vokabel + Next-Card System**, so klein wie möglich, aber trotzdem „echtes Architekturmodell“.

# 🧱 1. Datenmodelle

## 📘 Vokabel (Inhalt)

```dart
class Vocab {
  final String id;
  final String front;
  final String back;

  Vocab(this.id, this.front, this.back);
}
```

## 🧠 FSRS Card (Lernzustand)

```dart
class Card {
  final String vocabId;

  double stability;
  double difficulty;
  DateTime due;

  Card({
    required this.vocabId,
    this.stability = 0,
    this.difficulty = 5,
    required this.due,
  });
}
```

---

# ⚙️ 2. Mini-FSRS (stark vereinfacht)

Echte FSRS ist komplex – hier nur das Prinzip:

```dart
class Fsrs {
  Card review(Card card, int rating, DateTime now) {
    // rating: 1=Again, 2=Hard, 3=Good, 4=Easy

    double factor;

    switch (rating) {
      case 1:
        factor = 0.5;
        card.stability = 1;
        break;
      case 2:
        factor = 1.0;
        card.stability *= 1.2;
        break;
      case 3:
        factor = 1.5;
        card.stability *= 1.5;
        break;
      case 4:
        factor = 2.0;
        card.stability *= 2.0;
        break;
      default:
        factor = 1.0;
    }

    // new difficulty (simple drift)
    card.difficulty = (card.difficulty + (5 - rating)).clamp(1, 10);

    // next interval
    final days = (card.stability * factor).round();
    card.due = now.add(Duration(days: days));

    return card;
  }
}
```

---

# 📚 3. Repository (In-Memory)

```dart
class Repo {
  final List<Vocab> vocabs;
  final List<Card> cards;

  Repo(this.vocabs, this.cards);

  Card getCard(String vocabId) =>
      cards.firstWhere((c) => c.vocabId == vocabId);

  Vocab getVocab(String id) =>
      vocabs.firstWhere((v) => v.id == id);
}
```

---

# 🔁 4. Scheduler (Next Card Decision)

```dart
class Scheduler {
  final Repo repo;

  Scheduler(this.repo);

  Card? next(DateTime now) {
    final due = repo.cards
        .where((c) => c.due.isBefore(now))
        .toList();

    if (due.isEmpty) return null;

    due.sort((a, b) => a.due.compareTo(b.due));

    return due.first;
  }
}
```

---

# 🎮 5. App Flow (Game Loop)

```dart
void main() {
  final now = DateTime.now();

  final repo = Repo(
    [
      Vocab("1", "Apple", "Apfel"),
      Vocab("2", "Dog", "Hund"),
    ],
    [
      Card(vocabId: "1", due: now),
      Card(vocabId: "2", due: now),
    ],
  );

  final fsrs = Fsrs();
  final scheduler = Scheduler(repo);

  // 👉 get next card
  final card = scheduler.next(now);

  if (card == null) return;

  final vocab = repo.getVocab(card.vocabId);

  print("Q: ${vocab.front}");

  // user answers → rating
  final rating = 3; // Good

  :card = fsrs.review(card, rating, now);

  print("Next review: ${card.due}");
}
```

---

# 🧠 6. Was dieses System zeigt

## ✔ Trennung:

* Vocab = Inhalt
* Card = Gedächtnis
* FSRS = Update-Logik
* Scheduler = Auswahl

---

## ✔ Flow:

```text
Vocab → Card → Scheduler → FSRS → Card Update
```

---

# 🔥 7. Wichtigster Punkt (der oft fehlt)

👉 **„Next Card“ ist NICHT FSRS**

FSRS macht nur:

```text
„Wann ist diese Karte wieder dran?“
```

Scheduler macht:

```text
„Welche zeige ich jetzt?“
```

---

# 💡 Wenn du das erweitern willst

Die nächsten echten Schritte wären:

* new cards queue
* review limit per day
* leech handling
* FSRS v4 echte Formel
* persistence (SQLite)

---

Wenn du willst, kann ich dir daraus als nächsten Schritt eine **saubere Flutter Architektur (Riverpod/BLoC + SQLite + FSRS real implementation)** bauen – das ist dann schon „production-ready Spaced Repetition System“.
