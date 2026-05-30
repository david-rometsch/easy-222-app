Schematisch passiert in deinem Beispiel ungefähr Folgendes:

---

# 1. Ein Scheduler wird erstellt

```dart
var scheduler = Scheduler(...)
```

Hier wird das FSRS-System konfiguriert.

Der Scheduler weiß danach:

```text
- Wie Wiederholungen berechnet werden
- Welche Lernparameter gelten
- Welche Schritte es gibt
- Welche Retention gewünscht ist
```

Man kann ihn sich vorstellen wie:

```text
„Der Mathematik-/Planungs-Teil“
```

Er enthält noch keine konkreten Lernkarten.

---

# 2. Eine neue Karte wird erzeugt

```dart
final cardInitial = await Card.create();
```

Jetzt entsteht eine neue FSRS-Karte.

Aber wichtig:

```text
Die Karte enthält noch KEIN Wort.
```

Sie enthält nur Lernzustand:

```text
Card
 ├── due
 ├── stability
 ├── difficulty
 ├── reps
 └── state
```

Sinngemäß:

```text
„Diese Sache wurde noch nie gelernt.“
```

---

# 3. Der Nutzer bewertet die Erinnerung

```dart
final rating = Rating.again;
```

Das bedeutet:

```text
„Ich habe es vergessen.“
```

Andere Möglichkeiten wären:

```text
again = vergessen
hard  = sehr schwer erinnert
good  = erinnert
easy  = leicht erinnert
```

---

# 4. FSRS berechnet den neuen Lernzustand

```dart
scheduler.reviewCard(cardInitial, rating);
```

Das ist der zentrale Schritt.

FSRS bekommt:

```text
Alter Kartenzustand
+
Bewertung des Nutzers
```

und berechnet daraus:

```text
- neue Schwierigkeit
- neue Stabilität
- nächsten Zeitpunkt
- neuen Lernstatus
```

---

# 5. Zwei Dinge werden zurückgegeben

```dart
final (:card, :reviewLog) = ...
```

Das Ergebnis enthält:

---

## A) Die aktualisierte Karte

```text
card
```

Das ist die neue Version der Karte:

```text
„Wann soll wiederholt werden?“
„Wie stabil ist die Erinnerung?“
```

Die alte Karte bleibt unverändert.

---

## B) Ein Log-Eintrag

```text
reviewLog
```

Das ist ein Protokoll des Reviews:

```text
- welches Rating?
- wann?
- welcher Zustand vorher/nachher?
```

Wie ein Verlaufseintrag.

---

# 6. Nächster Wiederholungszeitpunkt wird gelesen

```dart
final due = card.due;
```

Jetzt fragt der Code:

```text
„Wann soll die Karte wieder gezeigt werden?“
```

---

# 7. Zeit bis zur Wiederholung wird berechnet

```dart
final timeDelta = due.difference(DateTime.now());
```

Sinngemäß:

```text
due - jetzt
```

Also:

```text
„In wie vielen Sekunden/Minuten/Tagen kommt die Karte wieder?“
```

---

# 8. Wahrscheinlichkeit des Erinnerns wird berechnet

```dart
scheduler.getCardRetrievability(card);
```

FSRS schätzt:

```text
„Wie wahrscheinlich ist es,
dass der Nutzer die Karte jetzt erinnert?“
```

Zum Beispiel:

```text
0.92 = 92% Wahrscheinlichkeit
```

---

# 9. Daten werden serialisiert

```dart
toMap()
```

Das bedeutet:

```text
Objekt → speicherbares Format
```

Zum Beispiel für:

- Datenbank
    
- JSON
    
- Datei
    

---

# 10. Daten werden wiederhergestellt

```dart
fromMap()
```

Jetzt passiert:

```text
gespeicherte Daten → echtes Objekt
```

---

# Gesamtbild

```text
Nutzer bewertet Karte
        ↓
FSRS analysiert Bewertung
        ↓
FSRS berechnet neuen Lernzustand
        ↓
Neue Wiederholungszeit wird festgelegt
        ↓
Karte wird gespeichert
```

FSRS ist also im Kern:

```text
Ein mathematisches Planungssystem
für Wiederholungen.
```

Nicht:

- die eigentliche Lern-App
    
- nicht der Inhalt
    
- nicht die UI
    

Nur die Logik für:

> „Wann sollte etwas wiederholt werden?“