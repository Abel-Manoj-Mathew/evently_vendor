import 'package:envied/envied.dart';

part 'env.dev.g.dart';

/// Development environment variables.
@Envied(
  path: '.env.dev',
  obfuscate: true,
)
abstract class EnvDev {
  /// Supabase URL for development.
  @EnviedField(
    varName: 'SUPABASE_URL',
    obfuscate: true,
  )
  static final String supabaseUrl = _EnvDev.supabaseUrl;

  /// Supabase anon key for development.
  @EnviedField(
    varName: 'SUPABASE_ANON_KEY',
    obfuscate: true,
  )
  static final String supabaseAnonKey = _EnvDev.supabaseAnonKey;
}
