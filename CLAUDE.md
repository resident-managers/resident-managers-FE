# CLAUDE.md

@engineering-mobile-app-builder.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**quan_ly_dan_cu** is a Vietnamese resident management system (Quản Lý Dân Cư) built with Flutter. It connects to a GraphQL backend to manage residents, households, insurance records, and temporary residence/absence statuses.

## Common Commands

```bash
# Install dependencies
flutter pub get

# Generate Riverpod provider code (required after modifying @riverpod annotated classes)
dart run build_runner build --delete-conflicting-outputs

# Run app
flutter run

# Build Android APK
flutter build apk

# Regenerate app launcher icons
dart run flutter_launcher_icons
```

## Architecture

### Data Flow
```
GraphQL API
    ↓
lib/graphql/ (queries.dart + mutations.dart)
    ↓
lib/providers/ (Riverpod FutureProviders)
    ↓
lib/screens/ (ConsumerWidget / ConsumerStatefulWidget)
```

### State Management — Riverpod
- **Data providers**: `FutureProvider.autoDispose.family` for fetching, parameterized via data classes (e.g., `ResidentsQueryParams`)
- **Auth provider**: Class-based `AsyncNotifier`, code-generated (`auth_provider.g.dart`)
- Screens use `ref.watch()` for reactive data and `ref.invalidate()` to trigger refetches after mutations
- `AsyncValue.when()` pattern used everywhere for loading/error/data states

### Routing — GoRouter
All routes are defined in `main.dart`. Route parameters (e.g., `/resident-detail/:id`) are extracted via `state.pathParameters`.

| Path | Screen |
|------|--------|
| `/login` | LoginScreen |
| `/dashboard` | DashboardScreen |
| `/directory` | ResidentDirectoryScreen |
| `/add-resident` | AddResidentScreen |
| `/resident-detail/:id` | ResidentDetailScreen |
| `/resident-detail/:id/edit` | EditResidentScreen |
| `/households` | HouseholdListScreen |
| `/household/:id` | HouseholdDetailScreen |
| `/setup-household` | SetupHouseholdScreen (create) |
| `/household/:id/edit` | SetupHouseholdScreen (edit, `isEditMode: true`) |

### GraphQL Client — `lib/core/graphql_client.dart`
- `AuthLink` injects `Bearer <token>` from `SecureStorage` on every request
- Hive-backed cache with `InMemoryStore` fallback
- Fetch policy: `networkOnly`, cache reread: `ignoreAll` (always fresh data)
- After login/logout, `GraphQLConfig` rebuilds the client with the updated token

### Authentication
- JWT token stored via `flutter_secure_storage`
- `authProvider` in `lib/providers/auth_provider.dart` handles login/logout lifecycle
- Logout clears token, rebuilds GraphQL client, then navigates to `/login`

## Key Conventions

### Adding a new feature
1. Add GraphQL query/mutation to `lib/graphql/queries.dart` or `mutations.dart`
2. Create/update model in `lib/models/` with `fromJson()` factory
3. Add Riverpod provider in `lib/providers/`
4. Build screen in `lib/screens/<feature>/` using `ConsumerWidget` or `ConsumerStatefulWidget`
5. Register route in `main.dart`

### Mutation pattern in screens
```dart
final result = await client.mutate(MutationOptions(
  document: gql(someMutation),
  variables: {...},
));
if (result.hasException) { /* show error */ }
else { ref.invalidate(someProvider); /* navigate */ }
```

### Code generation
`auth_provider.g.dart` is auto-generated — never edit it manually. Run `build_runner` after changing any `@riverpod` annotated class.

## Configuration

- **GraphQL endpoint**: set `GRAPHQL_ENDPOINT` in `.env` file at project root (loaded via `flutter_dotenv`)
- **App icon**: source at `assets/icon/app_icon.png`; regenerate with `dart run flutter_launcher_icons`
- **Adaptive icon background**: `#3AB9C8` (teal), configured in `pubspec.yaml` under `flutter_launcher_icons`

## Localization

All UI text is in Vietnamese. Enums like `Gender` and relationship types are mapped to Vietnamese display strings in `lib/core/enum_mapper.dart`. Residence status badges: `THƯỜNG TRÚ`, `TẠM TRÚ`, `TẠM VẮNG`, `ĐÃ CHUYỂN ĐI`.
