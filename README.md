# Gym Equipment Manager — Phase 4: Full UI

This folder is a **complete, runnable Flutter project** at the end of Phase 4 —
the finished application. It contains everything from Phases 1–3 **plus** the UI.

## What this phase delivers

| Screen / Widget | File |
|---|---|
| Home — searchable, refreshable list + FAB + settings | `lib/screens/home_screen.dart` |
| Detail — full info; Edit/Delete only for custom items | `lib/screens/detail_screen.dart` |
| Add — validated form to create a custom exercise | `lib/screens/add_screen.dart` |
| Edit — pre-filled form to update a custom exercise | `lib/screens/edit_screen.dart` |
| Settings — dark mode toggle | `lib/screens/settings_screen.dart` |
| Exercise card (thumbnail, custom badge) | `lib/widgets/exercise_card.dart` |
| Shared add/edit form | `lib/widgets/exercise_form.dart` |
| Loading shimmer placeholder | `lib/widgets/loading_shimmer.dart` |
| Error state with retry | `lib/widgets/error_retry.dart` |

## Features (full FR coverage)

- View exercise list (remote via Dio) + custom exercises (local)
- Exercise details
- Live search across name / body part / equipment / target
- Create / Update / Delete custom exercises (SharedPreferences)
- Pull-to-refresh
- Loading (shimmer), empty, and error (retry) states
- Dark mode (persisted)
- Dio networking + 4 interceptors

## How to run

```bash
flutter pub get
flutter run
```

No API key is needed — the wger API is free and public for reads.

## How to verify

```bash
flutter analyze   # expect: No issues found
flutter test      # expect: All tests passed
```

## How to contribute (for the assigned member)

1. Copy this folder's contents into your local repo root (replacing files).
2. `flutter pub get`
3. Confirm the full app works, then commit and push.

> Built on top of Phase 3. This is the complete app. The `final/` folder is an
> identical combined copy used for end-to-end testing before pushing.
