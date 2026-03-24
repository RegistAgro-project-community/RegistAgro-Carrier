# Copilot instructions for registagrodriver

## Big picture
- Flutter app, single non-architected demo style, no state management packages (BLoC, Riverpod, etc.).
- Entrypoint: `lib/main.dart` (calls `TISApp` and sets `home: SignUp()`).
- Theme constants and global colors in `lib/theme/app_theme.dart` (`TISTheme`).
- Domain model + sample data are in `lib/models/models.dart` (Trip, User, Notification, status enums).
- Main navigation is `lib/screens/main_nav_screen.dart` with `IndexedStack` + `BottomNavigationBar` for 4 tabs: home, trips, profile, notifications.
- Each screen is implemented as stateful/stateless widgets under `lib/screens/`.

## Workflow commands
- Get dependencies: `flutter pub get`
- Run on connected device: `flutter run -d <deviceId>` (uses `flutter devices` to list IDs)
- Build APK: `flutter build apk --release`
- Build iOS: `flutter build ios --release` (macOS required)
- Static analysis: `flutter analyze`
- Tests: `flutter test`

## Project patterns
- Localized PT-PT strings are in widgets (e.g., `‘Criar conta’`, `‘Já tem conta?’`) with no localization package.
- Forms: each screen uses explicit `Form` and `GlobalKey<FormState>`, with inline `TextFormField` validators (e.g., email regex, password rules in `lib/screens/auth/signup/sign_up.dart`).
- Navigation: direct `Navigator.push`, `pushAndRemoveUntil`, not routing table; use `MaterialPageRoute` with widget constructor args.
- No remote service calls currently. "API" style behavior is mocked (e.g., `Future.delayed` in `submit()` in sign-up flow).
- Sample data filtering by status in `TripsScreen` (`sampleTrips.where...`) and producing list items with `_TripItem`.

## Key integration/cross-cutting points
- The app is purely in-memory; driver/trip/notification data comes from `lib/models/models.dart`.
- Trilayer separation: models + theme + screens. If adding real backend, add a new `lib/services/` folder and replace sample lists.
- Navigation and data flow: `SignUp` -> `MainNavScreen`; `TripsScreen` -> `TripDetailScreen` (passes `Trip`).

## Code conventions
- Use `const` where possible; the code already defines many `const` constructors and style constants.
- Colors are defined in `TISTheme` and reused instead of raw hex literals.
- Visual spacing uses `SizedBox` and consistent `EdgeInsets.all(16/24)`.
- It’s OK to keep Portuguese UI copy in place for this product.

## What the agent should avoid
- Do not introduce unneeded dependency packages unless problem requires (project is intentionally minimal).
- Do not rewrite navigation to non-Flutter types (e.g., using Navigator 2.0) unless requested.

## Review request
Please check if this file captures the critical patterns you want (especially in `lib/screens/auth/signup/sign_up.dart` and `lib/screens/main_nav_screen.dart`) and tell me any additional areas your team expects the AI to handle (e.g., where to add network adapters, quality gates, or unit test structure).
