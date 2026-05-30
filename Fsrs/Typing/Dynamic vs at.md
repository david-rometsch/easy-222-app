Doch — das gibt es.

```dart
dynamic a = 5;
```

ist in Dart **voll gültig**.

---

# 🧠 Was passiert hier?

```text
a hat den Typ dynamic
```

Das bedeutet:

👉 Typprüfung wird zur Laufzeit gemacht  
👉 du kannst den Typ später ändern

---

# 🟨 Beispiel

```dart
dynamic a = 5;
a = "hi";
a = true;
```

✔ alles erlaubt

---

# ⚠️ Unterschied zu `var`

```dart
var a = 5;        // int (fix)
a = "hi";         // ❌ Fehler
```

vs

```dart
dynamic a = 5;    // flexibel
a = "hi";         // ✔ ok
```

---

# 🧠 Wichtigster Punkt

|Keyword|Bedeutung|
|---|---|
|`var`|Typ wird automatisch festgelegt|
|`dynamic`|Typ ist komplett flexibel|

---

# 📌 Merksatz

```text
var = fester Typ (nur automatisch erkannt)
dynamic = wirklich variabler Typ
```