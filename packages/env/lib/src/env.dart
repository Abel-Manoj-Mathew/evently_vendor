/// Environment variable keys
enum Env {
  /// Supabase project URL
  supabaseUrl('SUPABASE_URL'),

  /// Supabase anon key
  supabaseAnonKey('SUPABASE_ANON_KEY');

  const Env(this.value);

  /// The string value of the environment variable key.
  final String value;
}
