# Gym Equipment Manager — Phase 1: Foundation

This folder is a **complete, runnable Flutter project** at the end of Phase 1.

## What this phase delivers

The project skeleton: dependencies, data model, themes, and an app that boots.

| Area | File |
|---|---|
| All dependencies declared | `pubspec.yaml` |
| `Exercise` data model (defensive `fromJson`/`toJson`/`copyWith`) | `lib/models/exercise.dart` |
| Material 3 light + dark themes | `lib/themes/app_theme.dart` |
| App entry, boots to a foundation placeholder | `lib/main.dart` |
| Model unit tests | `test/widget_test.dart` |

There is **no networking, state management, or real UI yet** — those arrive in
Phases 2–4.

## How to run

```bash
flutter pub get
flutter run
```

You should see a "Phase 1 — Foundation ready" screen.

## How to verify

```bash
flutter analyze   # expect: No issues found
flutter test      # expect: All tests passed
```

## How to contribute (for the assigned member)

1. Copy the contents of this folder into your local repo root (replacing files).
2. `flutter pub get`
3. Confirm it runs, then commit and push.

> Next: Phase 2 adds the Dio networking layer on top of this.
