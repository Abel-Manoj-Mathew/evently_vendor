import 'package:customer_repository/customer_repository.dart';
import 'package:database_client/database_client.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class MockDatabaseClient extends Mock implements DatabaseClient {}

Map<String, dynamic> _row({
  String id = 'c1',
  String name = 'Anu Thomas',
  String? phone = '+919876543210',
}) => {
  'id': id,
  'business_id': 'b1',
  'name': name,
  'phone': phone,
  'email': null,
  'notes': null,
  'created_at': '2026-10-01T10:00:00Z',
  'updated_at': '2026-10-01T10:00:00Z',
};

void main() {
  late DatabaseClient databaseClient;
  late CustomerRepository repository;

  setUp(() {
    databaseClient = MockDatabaseClient();
    repository = CustomerRepository(databaseClient: databaseClient);
  });

  group('createCustomer', () {
    test('normalizes the phone and trims optional fields', () async {
      when(
        () => databaseClient.insertCustomer(
          businessId: any(named: 'businessId'),
          name: any(named: 'name'),
          phone: any(named: 'phone'),
          email: any(named: 'email'),
          notes: any(named: 'notes'),
        ),
      ).thenAnswer((_) async => _row());

      final customer = await repository.createCustomer(
        businessId: 'b1',
        name: '  Anu Thomas ',
        phone: '98765 43210',
        email: '  ',
        notes: ' Prefers calls ',
      );

      expect(customer.id, 'c1');
      verify(
        () => databaseClient.insertCustomer(
          businessId: 'b1',
          name: 'Anu Thomas',
          phone: '+919876543210',
          notes: 'Prefers calls',
        ),
      ).called(1);
    });

    test('allows customers without a phone number', () async {
      when(
        () => databaseClient.insertCustomer(
          businessId: any(named: 'businessId'),
          name: any(named: 'name'),
        ),
      ).thenAnswer((_) async => _row(phone: null));

      final customer = await repository.createCustomer(
        businessId: 'b1',
        name: 'Walk-in',
        phone: '',
      );

      expect(customer.phone, isNull);
      verify(
        () => databaseClient.insertCustomer(businessId: 'b1', name: 'Walk-in'),
      ).called(1);
    });

    test('never looks up or returns an existing customer', () async {
      when(
        () => databaseClient.insertCustomer(
          businessId: any(named: 'businessId'),
          name: any(named: 'name'),
          phone: any(named: 'phone'),
        ),
      ).thenAnswer((_) async => _row(id: 'new'));

      final customer = await repository.createCustomer(
        businessId: 'b1',
        name: 'Second person',
        phone: '+919876543210',
      );

      expect(customer.id, 'new');
      verifyNever(
        () => databaseClient.getCustomers(businessId: any(named: 'businessId')),
      );
    });

    test('maps legacy unique-phone rejections', () {
      when(
        () => databaseClient.insertCustomer(
          businessId: any(named: 'businessId'),
          name: any(named: 'name'),
          phone: any(named: 'phone'),
        ),
      ).thenThrow(const DuplicateRecordException('23505'));

      expect(
        () => repository.createCustomer(
          businessId: 'b1',
          name: 'X',
          phone: '9876543210',
        ),
        throwsA(isA<CustomerPhoneAlreadyExistsException>()),
      );
    });

    test('wraps other failures', () {
      when(
        () => databaseClient.insertCustomer(
          businessId: any(named: 'businessId'),
          name: any(named: 'name'),
        ),
      ).thenThrow(Exception('db down'));

      expect(
        () => repository.createCustomer(businessId: 'b1', name: 'X'),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('findPotentialDuplicates', () {
    setUp(() {
      when(() => databaseClient.getCustomers(businessId: 'b1')).thenAnswer(
        (_) async => [
          _row(),
          _row(id: 'c2', name: 'Legacy format', phone: '9876543210'),
          _row(id: 'c3', name: 'No phone', phone: null),
          _row(id: 'c4', name: 'Other', phone: '+919999999999'),
        ],
      );
    });

    test('matches numbers regardless of formatting', () async {
      final matches = await repository.findPotentialDuplicates(
        businessId: 'b1',
        phone: '+91 98765-43210',
      );
      expect(matches.map((c) => c.id), ['c1', 'c2']);
    });

    test('returns nothing for an empty phone without querying', () async {
      final matches = await repository.findPotentialDuplicates(
        businessId: 'b1',
        phone: ' ',
      );
      expect(matches, isEmpty);
      verifyNever(() => databaseClient.getCustomers(businessId: 'b1'));
    });
  });

  group('getCustomer', () {
    test('returns the customer when found', () async {
      when(
        () => databaseClient.getCustomerById('c1'),
      ).thenAnswer((_) async => _row());
      expect((await repository.getCustomer('c1'))?.name, 'Anu Thomas');
    });

    test('returns null when missing or inaccessible', () async {
      when(
        () => databaseClient.getCustomerById('gone'),
      ).thenAnswer((_) async => null);
      expect(await repository.getCustomer('gone'), isNull);
    });
  });

  group('getCustomers', () {
    test('maps rows', () async {
      when(
        () => databaseClient.getCustomers(businessId: 'b1'),
      ).thenAnswer((_) async => [_row()]);
      final customers = await repository.getCustomers(businessId: 'b1');
      expect(customers.single.initials, 'AT');
    });

    test('wraps failures', () {
      when(
        () => databaseClient.getCustomers(businessId: 'b1'),
      ).thenThrow(Exception('x'));
      expect(
        () => repository.getCustomers(businessId: 'b1'),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('CustomerPhone', () {
    test('accepts empty and plausible numbers', () {
      expect(CustomerPhone.isValid(''), isTrue);
      expect(CustomerPhone.isValid('98765 43210'), isTrue);
      expect(CustomerPhone.isValid('+44 20 7946 0958'), isTrue);
      expect(CustomerPhone.isValid('0471-2345678'), isTrue);
    });

    test('rejects letters and implausible lengths', () {
      expect(CustomerPhone.isValid('call me'), isFalse);
      expect(CustomerPhone.isValid('12345'), isFalse);
      expect(CustomerPhone.isValid('+1234567890123456'), isFalse);
    });

    test('normalizes Indian and international numbers', () {
      expect(CustomerPhone.normalize(''), isNull);
      expect(CustomerPhone.normalize('98765 43210'), '+919876543210');
      expect(CustomerPhone.normalize('098765 43210'), '+919876543210');
      expect(CustomerPhone.normalize('+44 20 7946 0958'), '+442079460958');
      expect(CustomerPhone.normalize('0471-2345678'), '04712345678');
    });

    test('compares likely-same numbers', () {
      expect(
        CustomerPhone.isLikelySame('+919876543210', '98765 43210'),
        isTrue,
      );
      expect(CustomerPhone.isLikelySame('12345678', '12345678'), isTrue);
      expect(CustomerPhone.isLikelySame('12345678', '22345678'), isFalse);
      expect(CustomerPhone.isLikelySame('', ''), isFalse);
    });
  });
}
