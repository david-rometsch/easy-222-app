# Easy2

A 2×2 speedcubing training timer built with Flutter.  
School project — TEKO Schweizerische Fachschule, Herbstsemester 2026.

## What it does

Easy2 is a non-WCA-conform training timer with two goals:

1. **Simplified scrambles** — short, easy 2×2 scrambles so you can train one-looking efficiently. Competition scrambles are too long to one-look; Easy2 scrambles are designed so the solution is immediately visible, letting you focus on execution speed.

2. **Data collection** — records **inspection time**, **hold time**, and **solve time** simultaneously, captured at the exact moment you lift your finger. Short holds (< 550 ms) typically cause DNFs. Export your session data as CSV to find your weak spots.

## Features

- **Timer** — state machine: idle → inspection → hold → solve
  - Inspection displayed in integer seconds (red)
  - Hold phase shown in amber
  - Solve time in minimal format (`3.42` or `1:03.42`, white)
- **Scrambles** — simplified 2×2 scrambles loaded from a local JSON asset
- **Shake to scramble** — optional, toggle in settings
- **Session table** — scrollable live table of all solves (nr / inspection / hold / solve)
- **CSV export** — moves table rows to `easy2_solves.csv` (append, idempotent)
- **CSV download** — shares the file via Android share sheet
- **WCA records page** — fetches your 2×2 single and Ao5 from the WCA API
- **Settings** — WCA-ID input, shake toggle
- **Persistence** — Hive (survives restarts; solve counter never resets across exports)
- **i18n** — German / English, switchable at runtime

## Screens

| Screen | Description |
|---|---|
| Easy2 | Timer + scramble + session table |
| Records | WCA personal records (API) |
| Settings | WCA-ID, shake toggle |

## Download

[easy2.apk](https://github.com/teko-TIA23/rometsch-mobile-app/releases/tag/v1.1.0) — Android release build (sideload, no Play Store)

## Run from source

```sh
cd app/
flutter pub get
flutter run
```

## CSV format

```
nr,inspection_ms,hold_ms,solve_ms
1,14000,423,3420
```

## Regenerate scramble list

```sh
cd app/
make assets/scrambles.json
```
