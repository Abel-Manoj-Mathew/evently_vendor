import 'dart:convert';

/// The deployment environment an application build targets.
enum AppEnvironment {
  /// Local development against the development Supabase project.
  development,

  /// Pre-release testing builds.
  staging,

  /// Builds distributed to real vendors.
  production;

  /// Parses the `EVENTLY_ENV` value, returning `null` when unknown.
  static AppEnvironment? tryParse(String value) {
    for (final environment in values) {
      if (environment.name == value) return environment;
    }
    return null;
  }
}

/// Keys read from the `--dart-define-from-file` configuration file.
enum Env {
  /// The environment the configuration file was written for.
  environment('EVENTLY_ENV'),

  /// Supabase project URL.
  supabaseUrl('SUPABASE_URL'),

  /// Supabase publishable (client) key. Never a secret/service-role key.
  supabasePublishableKey('SUPABASE_PUBLISHABLE_KEY');

  const Env(this.key);

  /// The name of the compile-time define.
  final String key;
}

/// {@template app_config_exception}
/// Thrown when the build configuration is missing or unsafe.
/// {@endtemplate}
class AppConfigException implements Exception {
  /// {@macro app_config_exception}
  const AppConfigException(this.problems);

  /// Human-readable descriptions of every problem found.
  final List<String> problems;

  @override
  String toString() =>
      'Invalid app configuration:\n- ${problems.join('\n- ')}\n'
      'See docs/phase-1-report.md (Environment configuration).';
}

/// {@template app_config}
/// Validated runtime configuration for one [AppEnvironment].
///
/// Values come from `--dart-define-from-file=config/<environment>.json`.
/// There are deliberately no defaults: a build without a matching
/// configuration file fails at startup instead of silently talking to
/// another environment's backend.
/// {@endtemplate}
class AppConfig {
  /// {@macro app_config}
  const AppConfig({
    required this.environment,
    required this.supabaseUrl,
    required this.supabasePublishableKey,
  });

  /// Reads and validates the compile-time defines for [expected].
  factory AppConfig.fromEnvironment({required AppEnvironment expected}) {
    return AppConfig.parse(
      expected: expected,
      values: const {
        'EVENTLY_ENV': String.fromEnvironment('EVENTLY_ENV'),
        'SUPABASE_URL': String.fromEnvironment('SUPABASE_URL'),
        'SUPABASE_PUBLISHABLE_KEY': String.fromEnvironment(
          'SUPABASE_PUBLISHABLE_KEY',
        ),
      },
    );
  }

  /// Validates raw [values] for the [expected] environment.
  ///
  /// Throws an [AppConfigException] listing every problem found.
  factory AppConfig.parse({
    required AppEnvironment expected,
    required Map<String, String> values,
  }) {
    final problems = <String>[];
    String read(Env env) => (values[env.key] ?? '').trim();

    final rawEnvironment = read(Env.environment);
    final environment = AppEnvironment.tryParse(rawEnvironment);
    if (rawEnvironment.isEmpty) {
      problems.add(
        '${Env.environment.key} is missing. Run with '
        '--dart-define-from-file=config/${expected.name}.json',
      );
    } else if (environment == null) {
      problems.add('${Env.environment.key} "$rawEnvironment" is not valid.');
    } else if (environment != expected) {
      problems.add(
        'This is a ${expected.name} build but the configuration file is for '
        '${environment.name}.',
      );
    }

    final rawUrl = read(Env.supabaseUrl);
    final url = Uri.tryParse(rawUrl);
    if (rawUrl.isEmpty) {
      problems.add('${Env.supabaseUrl.key} is missing.');
    } else if (_looksLikePlaceholder(rawUrl)) {
      problems.add('${Env.supabaseUrl.key} still contains a placeholder.');
    } else if (url == null || !url.hasScheme || url.host.isEmpty) {
      problems.add('${Env.supabaseUrl.key} is not a valid URL.');
    } else if (url.scheme != 'https' &&
        !(expected == AppEnvironment.development && url.scheme == 'http')) {
      problems.add(
        '${Env.supabaseUrl.key} must use https outside development.',
      );
    }

    final key = read(Env.supabasePublishableKey);
    if (key.isEmpty) {
      problems.add('${Env.supabasePublishableKey.key} is missing.');
    } else if (_looksLikePlaceholder(key)) {
      problems.add(
        '${Env.supabasePublishableKey.key} still contains a placeholder.',
      );
    } else if (_isPrivilegedKey(key)) {
      problems.add(
        '${Env.supabasePublishableKey.key} is a secret/service-role key. '
        'Only the publishable key may ship in the app.',
      );
    }

    if (problems.isNotEmpty) throw AppConfigException(problems);

    return AppConfig(
      environment: environment!,
      supabaseUrl: rawUrl,
      supabasePublishableKey: key,
    );
  }

  /// The environment this configuration belongs to.
  final AppEnvironment environment;

  /// Supabase project URL.
  final String supabaseUrl;

  /// Supabase publishable key.
  final String supabasePublishableKey;

  static bool _looksLikePlaceholder(String value) =>
      value.contains('<') || value.contains('>') || value.contains('YOUR_');

  /// Detects keys that bypass Row Level Security: new-style `sb_secret_`
  /// keys and legacy JWT keys whose `role` claim is `service_role`.
  static bool _isPrivilegedKey(String key) {
    if (key.startsWith('sb_secret_')) return true;
    final segments = key.split('.');
    if (segments.length != 3) return false;
    try {
      final payload = utf8.decode(
        base64Url.decode(base64Url.normalize(segments[1])),
      );
      final claims = jsonDecode(payload);
      return claims is Map && claims['role'] == 'service_role';
    } on FormatException {
      return false;
    }
  }
}
