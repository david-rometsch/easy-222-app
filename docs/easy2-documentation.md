# Usecase – why Easy2?
- personal interest in the process: 2x2 has many random solutions
- simple scrambles → train One-Looking (competition scrambles too long)
- timer measures Inspection & Hold simultaneously → data basis for DNF analysis
- CSV export: short holds (< 550 ms) = DNF → analyzable in Excel/Python

---

# Flutter as a Platform Mediator
- Embedder mediates between app and platform – all in one
- one codebase → Android, iOS, Desktop

## Dart as a Type-Safe Language
- helps maintain overview
- Null Safety: no unexpected null at runtime

## Widget Tree Hierarchy
```
widget(
  child: widget2(
    child: widget3(...)
  )
)
```
- often developed from inside out: `Center(..)` as wrapper → centers content

## StatefulWidget & State Machine
- TimerPhase enum: `idle → inspection → holdStart → solve`
- `Listener` instead of `GestureDetector`: pointer events immediately, no delay

![Timer States](diagrams/timer-states.svg)

## InheritedNotifier
- `AppLocale` at top level: all listener widgets below update automatically
- `localeNotifier.value = 'de'` → rebuild without setState

![InheritedNotifier](diagrams/inherited-notifier.svg)

## GlobalKey
- direct access to another widget's State
- example: changing WCA-ID in Settings → RecordPage reloads immediately

![GlobalKey](diagrams/global-key.svg)

---

# Implemented Features

## API & Error Handling (KT3)
- WCA REST API: load Single & Ao5
- check Content-Type header, handle 404 separately
- 3 UI states: loading / error / data

## Sensor Access (KT4)
- Shake-to-Scramble via accelerometer stream
- Accelerometer = no runtime permission needed (non-dangerous sensor)
- on/off toggle in Settings

## Internationalization
- DE/EN, switchable at runtime via InheritedNotifier

## Persistence
- Hive: session table + settings survive restart
- solve counter never resets → CSV rows stay unique

---

# Technology

## Theming
- `flex_color_scheme` package – including dev template as starting point
- Light & Dark Mode

## Packages (pub.dev)
- `hive_flutter`, `stop_watch_timer`, `shake`, `share_plus`, `http`, `flex_color_scheme`
- `flutter pub add <lib>` and `flutter doctor` – well thought out

---

# Learnings
- Listener > GestureDetector for precise touch measurement
- reading two stopwatches simultaneously = atomic snapshot
- InheritedNotifier more elegant than setState for global state

---

# Conclusion
- practical: all in one, one codebase
- more logical and compact than HTML/CSS/JS
- a lot to learn at first – but once you get it, you can build something good fast
- planning to use Flutter for future projects
