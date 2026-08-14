import 'package:env/env.dart';

/// Flavor enum representing the app environment.
enum Flavor {
  /// Development environment
  development,

  /// Staging environment
  staging,

  /// Production environment
  production,
}

/// Abstract class for application environment configuration.
sealed class AppEnv {
  /// Creates an [AppEnv] instance.
  const AppEnv();

  /// Gets the environment variable value for [env].
  String getEnv(Env env);
}

/// [AppFlavor] provides environment values based on the current [Flavor].
class AppFlavor extends AppEnv {
  const AppFlavor._({required this.flavor});

  /// Development flavor instance.
  factory AppFlavor.development() =>
      const AppFlavor._(flavor: Flavor.development);

  /// Staging flavor instance.
  factory AppFlavor.staging() => const AppFlavor._(flavor: Flavor.staging);

  /// Production flavor instance.
  factory AppFlavor.production() =>
      const AppFlavor._(flavor: Flavor.production);

  /// The active flavor.
  final Flavor flavor;

  @override
  String getEnv(Env env) => switch (env) {
    Env.supabaseUrl => switch (flavor) {
      Flavor.development => EnvDev.supabaseUrl,
      Flavor.production => EnvProd.supabaseUrl,
      Flavor.staging => EnvProd.supabaseUrl,
    },
    Env.supabaseAnonKey => switch (flavor) {
      Flavor.development => EnvDev.supabaseAnonKey,
      Flavor.production => EnvProd.supabaseAnonKey,
      Flavor.staging => EnvProd.supabaseAnonKey,
    },
  };
}
