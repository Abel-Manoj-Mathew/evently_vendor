// Not required for test files
import 'package:database_client/database_client.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';
import 'package:user_repository/user_repository.dart';

class MockDatabaseClient extends Mock implements DatabaseClient {}

void main() {
  group('UserRepository', () {
    test('can be instantiated', () {
      final databaseClient = MockDatabaseClient();
      expect(UserRepository(databaseClient: databaseClient), isNotNull);
    });
  });
}
