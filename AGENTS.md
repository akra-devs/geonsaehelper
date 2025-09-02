# Repository Guidelines

## Project Structure & Module Organization
- App code: `lib/`
  - `ui/theme/`: design system and Theme extensions
  - `ui/components/`: reusable widgets (ResultCard, IntakeQuestion, ChatBubble)
  - `ui/demo/`: `DemoGallery` to preview components
  - Recommended next: `features/<feature>/{ui,bloc,data}` per docs
- Tests: `test/`
- Docs: `docs/docs/` (PRD, rules, UI blueprints, copy templates)

## Build, Test, and Development Commands
- Install deps: `flutter pub get`
- Run (web example): `flutter run -d chrome`
- Analyze: `flutter analyze` (lints configured via `analysis_options.yaml`)
- Format: `dart format .`
- Test: `flutter test`
- Codegen (if Freezed/JSON models are added):
  `dart run build_runner build --delete-conflicting-outputs`

## Coding Style & Naming Conventions
- Language: Dart, 2-space indentation, trailing commas where helpful.
- Files: `snake_case.dart`; classes `PascalCase`; methods/fields `lowerCamelCase`.
- Widgets: keep small and composable; extract into `ui/components/` when reused.
- Features: `lib/features/<feature>/{ui,bloc,data}`; BLoC files `*_bloc.dart`, events `*_event.dart`, states `*_state.dart`.

## Testing Guidelines
- Framework: `flutter_test` (unit and widget tests).
- Naming: mirror source path, e.g., `test/ui/components/result_card_test.dart`.
- Prefer widget tests for UI components; mock repositories for BLoC tests.
- Run locally with `flutter test`; keep tests deterministic and fast.

## Commit & Pull Request Guidelines
- Commits: use Conventional Commits when possible
  - Examples: `feat(ui): add ResultCard`, `fix(theme): correct color contrast`, `docs: update PRD links`.
- PRs: include concise description, motivation, screenshots/GIFs for UI, and linked issue (e.g., `Closes #123`). Ensure `flutter analyze` and tests pass.

## Architecture Notes
- Follow one-way deps: UI → BLoC → Repository → Data sources.
- Centralize theme and design tokens; avoid inline styling where a token exists.
- Prefer dependency injection via providers at app bootstrap.
