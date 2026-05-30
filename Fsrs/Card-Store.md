
```dart
Map<String, Card> cardStore = {};
```

Card Store muss als map tipsier sein

```dart
final dueCards = cardStore.values.where((card) {
  return card.due.isBefore(DateTime.now());
}).toList();
```

## Korrekte Definition

So muss es aussehen:
```dart
final Map<String, Card> cardStore = {};
```

Dann funktioniert:
```dart 
cardStore.entries.where((entry) {
  return entry.value.due.isBefore(DateTime.now());
});
```