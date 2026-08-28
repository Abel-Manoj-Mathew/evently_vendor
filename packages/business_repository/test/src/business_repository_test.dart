// Not required for test files
import 'package:business_repository/business_repository.dart';
import 'package:database_client/database_client.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class MockDatabaseClient extends Mock implements DatabaseClient {}

void main() {
  group('BusinessRepository', () {
    test('can be instantiated', () {
      final databaseClient = MockDatabaseClient();
      expect(BusinessRepository(databaseClient: databaseClient), isNotNull);
    });
  });
}
