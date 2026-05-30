Ja — hier die kurze saubere ZF mit **Literal vs Konstruktor vs Typ-System**:

---

# 🧠 ZF: 2 Stile + Literal

## 🟦 Python / dynamisch

```text id="p1"
a = 5
a = MyClass()
```

* kein fester Typ nötig
* Variable zeigt direkt auf Objekt
* sehr flexibel

👉 **Literal möglich**

```text id="p2"
5, "hi", True
```

---

## 🟨 Statisch typisiert (Dart / Java / Rust)

```text id="p3"
MyClass a = MyClass();
int b = 5;
```

* Typ ist fest deklariert
* mehr Struktur + Sicherheit

👉 **Literal ebenfalls möglich**

```text id="p4"
int a = 5;
String s = "hi";
```

---

# ⚡ Unterschied „Literal vs Konstruktor“

| Begriff     | Bedeutung                    |
| ----------- | ---------------------------- |
| Literal     | direkter Wert (`5`, `"hi"`)  |
| Konstruktor | erzeugt Objekt (`MyClass()`) |

---

# 📌 Mini-Merksatz

```text id="m1"
Literal = fertiger Wert
Konstruktor = erzeugt Objekt
Python vs static = wie streng der Typ dazu kontrolliert wird
```
