// Not required for test files
import 'package:database_client/database_client.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase/supabase.dart';
import 'package:test/test.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}

void main() {
  group('DatabaseClient', () {
    test('can be instantiated', () {
      final supabaseClient = MockSupabaseClient();
      expect(DatabaseClient(supabaseClient: supabaseClient), isNotNull);
    });
  });
}
