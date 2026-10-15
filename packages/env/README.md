# Env

Validated build configuration for the Evently Vendor app.

Values are supplied at build time with
`--dart-define-from-file=config/<environment>.json` (see the repository
`config/*.example.json` files). `AppConfig.fromEnvironment` reads them and
fails with an `AppConfigException` listing every problem when:

- a value is missing or still a placeholder;
- `EVENTLY_ENV` does not match the entry point's environment;
- the URL is invalid, or uses `http` outside development;
- the key is a secret / service-role key.

There are no defaults, so a build can never silently fall back to another
environment's backend.

```dart
final config = AppConfig.fromEnvironment(expected: AppEnvironment.production);
```

Run tests with `dart test`.
