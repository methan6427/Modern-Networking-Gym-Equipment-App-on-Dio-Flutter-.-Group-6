# Gym Equipment Manager — Phase 2: Dio Networking Layer

This folder is a **complete, runnable Flutter project** at the end of Phase 2.
It contains everything from Phase 1 **plus** the networking layer — the core of
the project.

## What this phase delivers

| Area | File |
|---|---|
| Dio client (BaseOptions, timeouts, attaches interceptors) | `lib/services/dio_client.dart` |
| Auth interceptor (injects API key header) | `lib/services/interceptors/auth_interceptor.dart` |
| Logging interceptor (logs every request/response) | `lib/services/interceptors/logging_interceptor.dart` |
| Error interceptor (maps `DioException` → typed `AppException`) | `lib/services/interceptors/error_interceptor.dart` |
| Retry interceptor (auto-retries transient failures) | `lib/services/interceptors/retry_interceptor.dart` |
| Remote API service (5 endpoints) | `lib/services/exercise_api_service.dart` |
| Local storage service (SharedPreferences CRUD) | `lib/services/local_storage_service.dart` |
| Repository (single source of truth) | `lib/repositories/exercise_repository.dart` |

The UI is a **networking smoke-test screen**: tap "Fetch" to call the API
through Dio and watch the interceptor logs in the debug console.

## API configuration

- Data comes from the free, public **wger** workout API
  (`https://wger.de/api/v2`) — no API key required.
- Base URL lives in `lib/services/dio_client.dart` (`ApiConfig.baseUrl`).
- The wger JSON is mapped into the app's `Exercise` model inside
  `lib/services/exercise_api_service.dart` (keeps the model API-agnostic).
- `AuthInterceptor` only attaches a header if you pass an optional token
  (`--dart-define=API_TOKEN=...`), which is not needed for reading exercises.

## How to run

```bash
flutter pub get
flutter run
```

Tap **Fetch** and check the console — you should see lines like
`--> GET .../exercises` and `<-- 200 ... (123ms)` from the LoggingInterceptor.

## How to verify

```bash
flutter analyze   # expect: No issues found
flutter test      # expect: All tests passed
```

## How to contribute (for the assigned member)

1. Copy this folder's contents into your local repo root (replacing files).
2. `flutter pub get`
3. Confirm the smoke test fetches data, then commit and push.

> Built on top of Phase 1. Next: Phase 3 adds state management (Provider).
