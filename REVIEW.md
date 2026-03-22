# Code Review Guidelines

## Always check

### GraphQL Operations
- New queries must be added to `lib/graphql/queries.dart`, mutations to `lib/graphql/mutations.dart`
- GraphQL operation names must match the corresponding BE schema field names exactly (case-sensitive)
- Variables passed to mutations must match the input type defined in BE schema

### State Management & Providers
- New screens that fetch data must use a Provider — no direct API calls inside widget `build()`
- Providers must handle loading, error, and success states explicitly
- Dispose controllers and listeners in `dispose()` when used in StatefulWidget

### Navigation & Screens
- New screens must be registered/navigated consistently with existing screen patterns
- Authentication guard: screens requiring login must check token presence before rendering

### Models
- New model classes go in `lib/models/`
- Models must implement `fromJson` factory for GraphQL response parsing
- Nullable fields from BE must be typed as nullable in Dart (`String?` not `String`)

## Style
- Follow existing file structure: `lib/screens/{domain}/`, `lib/widgets/`, `lib/providers/`
- Widget files: one widget per file, filename matches class name in snake_case
- Use `const` constructors wherever possible

## Skip
- `.dart_tool/`
- `build/`
- `pubspec.lock`
- Generated files (`*.g.dart`, `*.freezed.dart`)
