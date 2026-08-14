# Env

A package that manages Evently application environment variables securely using `envied`.

## Purpose

The `env` package serves as the single source of truth for configuration variables. It prevents feature layers from directly reading `.env` files and ensures all secrets are obfuscated in the compiled application.

## Environments

The package supports the following environments, corresponding to the application's entry points:

- **Development** (`.env.dev`): Used with `main_development.dart`
- **Production** (`.env.prod`): Used with `main_production.dart`

## Setup

1. Copy the template to create your local `.env.dev` and `.env.prod` files:
   ```sh
   cp .env.example .env.dev
   cp .env.example .env.prod
   ```

2. Fill in the required Supabase URL and Anon Key.

3. Generate the obfuscated Dart files:
   ```sh
   dart run build_runner build --delete-conflicting-outputs
   ```

## Usage

Access the environment variables statically:

```dart
import 'package:env/env.dart';

// Development
final url = EnvDev.supabaseUrl;
final key = EnvDev.supabaseAnonKey;

// Production
final url = EnvProd.supabaseUrl;
final key = EnvProd.supabaseAnonKey;
```

## Security Notes

**IMPORTANT**: Never commit `.env.dev` or `.env.prod` to version control. They are strictly local.
**IMPORTANT**: Do not place server secrets (e.g., Supabase service-role keys, database passwords) into this package. It is intended only for client-side keys (like the public anon key).
