import 'package:envied/envied.dart';

part 'env.prod.g.dart';

/// Production environment variables.
@Envied(
  path: '.env.prod',
  obfuscate: true,
)
abstract class EnvProd {
  /// Supabase URL for production.
  @EnviedField(
    varName: 'SUPABASE_URL',
    obfuscate: true,
  )
  static final String supabaseUrl = _EnvProd.supabaseUrl;

  /// Supabase anon key for production.
  @EnviedField(
    varName: 'SUPABASE_ANON_KEY',
    obfuscate: true,
  )
  static final String supabaseAnonKey = _EnvProd.supabaseAnonKey;
}
