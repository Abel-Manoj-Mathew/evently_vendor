import 'package:customer_repository/customer_repository.dart';
import 'package:database_client/database_client.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class MockDatabaseClient extends Mock implements DatabaseClient {}

void main() {
  group('CustomerRepository', () {
    late DatabaseClient databaseClient;
    late CustomerRepository customerRepository;

    setUp(() {
      databaseClient = MockDatabaseClient();
      customerRepository = CustomerRepository(databaseClient: databaseClient);
    });

    test('can be instantiated', () {
      expect(
        CustomerRepository(databaseClient: databaseClient),
        isNotNull,
      );
    });

    group('createCustomer', () {
      test('returns created customer on success', () async {
        const businessId = 'b123';
        const name = 'Alice Smith';
        const phone = '+15551234567';
        const email = 'alice@example.com';
        const notes = 'VIP client';

        final rawJson = {
          'id': 'c123',
          'business_id': businessId,
          'name': name,
          'phone': phone,
          'email': email,
          'notes': notes,
          'created_at': '2026-08-28T00:00:00.000Z',
          'updated_at': '2026-08-28T00:00:00.000Z',
        };

        when(
          () => databaseClient.getCustomerByPhone(
            businessId: any(named: 'businessId'),
            phone: any(named: 'phone'),
          ),
        ).thenAnswer((_) async => null);

        when(
          () => databaseClient.insertCustomer(
            businessId: businessId,
            name: name,
            phone: phone,
            email: email,
            notes: notes,
          ),
        ).thenAnswer((_) async => rawJson);

        final result = await customerRepository.createCustomer(
          businessId: businessId,
          name: name,
          phone: phone,
          email: email,
          notes: notes,
        );

        expect(result.id, equals('c123'));
        expect(result.name, equals(name));
        expect(result.initials, equals('AS'));
      });

      test('returns existing customer when mobile number already registered', () async {
        const businessId = 'b123';
        const phone = '+15551234567';
        final rawJson = {
          'id': 'cExisting',
          'business_id': businessId,
          'name': 'Existing Customer',
          'phone': phone,
        };

        when(
          () => databaseClient.getCustomerByPhone(
            businessId: businessId,
            phone: phone,
          ),
        ).thenAnswer((_) async => rawJson);

        final result = await customerRepository.createCustomer(
          businessId: businessId,
          name: 'New Name',
          phone: phone,
        );

        expect(result.id, equals('cExisting'));
        expect(result.name, equals('Existing Customer'));
        verifyNever(
          () => databaseClient.insertCustomer(
            businessId: any(named: 'businessId'),
            name: any(named: 'name'),
            phone: any(named: 'phone'),
          ),
        );
      });

      test('throws Exception when database operation fails', () async {
        when(
          () => databaseClient.getCustomerByPhone(
            businessId: any(named: 'businessId'),
            phone: any(named: 'phone'),
          ),
        ).thenAnswer((_) async => null);

        when(
          () => databaseClient.insertCustomer(
            businessId: any(named: 'businessId'),
            name: any(named: 'name'),
            phone: any(named: 'phone'),
          ),
        ).thenThrow(Exception('DB Error'));

        expect(
          () => customerRepository.createCustomer(
            businessId: 'b1',
            name: 'Bob',
            phone: '123',
          ),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('getCustomers', () {
      test('returns list of customers on success', () async {
        const businessId = 'b123';
        final listJson = [
          {
            'id': 'c1',
            'business_id': businessId,
            'name': 'John Doe',
            'phone': '111',
          },
        ];

        when(
          () => databaseClient.getCustomers(businessId: businessId),
        ).thenAnswer((_) async => listJson);

        final result =
            await customerRepository.getCustomers(businessId: businessId);

        expect(result.length, equals(1));
        expect(result.first.name, equals('John Doe'));
      });
    });
  });
}
