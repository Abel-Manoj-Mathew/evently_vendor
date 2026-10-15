import 'package:bloc_test/bloc_test.dart';
import 'package:customer_repository/customer_repository.dart';
import 'package:evently_vendor/customers/customers.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/helpers.dart';

const _existing = Customer(
  id: 'c1',
  businessId: 'b1',
  name: 'Anu Thomas',
  phone: '+919876543210',
);
const _created = Customer(
  id: 'c2',
  businessId: 'b1',
  name: 'Biju Thomas',
  phone: '+919876543210',
);

void main() {
  late CustomerRepository repository;

  setUp(() {
    repository = MockCustomerRepository();
    when(
      () => repository.getBusinessIdForUser(testUser.id),
    ).thenAnswer((_) async => 'b1');
    when(
      () => repository.findPotentialDuplicates(
        businessId: any(named: 'businessId'),
        phone: any(named: 'phone'),
      ),
    ).thenAnswer((_) async => []);
    when(
      () => repository.createCustomer(
        businessId: any(named: 'businessId'),
        name: any(named: 'name'),
        phone: any(named: 'phone'),
        email: any(named: 'email'),
        notes: any(named: 'notes'),
      ),
    ).thenAnswer((_) async => _created);
  });

  CreateCustomerCubit build() =>
      CreateCustomerCubit(customerRepository: repository, ownerId: testUser.id);

  group('validation', () {
    test('requires a name', () {
      expect(const CreateCustomerState().nameError, isNotNull);
      expect(const CreateCustomerState(name: 'A').nameError, isNull);
    });

    test('phone and email are optional but must be valid if given', () {
      const state = CreateCustomerState(name: 'A');
      expect(state.isValid, isTrue);
      expect(state.copyWith(phone: 'abc').phoneError, isNotNull);
      expect(state.copyWith(phone: '+44 20 7946 0958').phoneError, isNull);
      expect(state.copyWith(email: 'nope').emailError, isNotNull);
      expect(state.copyWith(email: 'a@b.in').emailError, isNull);
    });
  });

  blocTest<CreateCustomerCubit, CreateCustomerState>(
    'shows validation instead of saving an invalid form',
    build: build,
    act: (cubit) => cubit.submit(),
    expect: () => const [CreateCustomerState(showValidation: true)],
    verify: (_) => verifyNever(
      () => repository.createCustomer(
        businessId: any(named: 'businessId'),
        name: any(named: 'name'),
      ),
    ),
  );

  blocTest<CreateCustomerCubit, CreateCustomerState>(
    'saves a customer without a phone number without a duplicate check',
    build: build,
    seed: () => const CreateCustomerState(name: 'Walk-in'),
    act: (cubit) => cubit.submit(),
    expect: () => const [
      CreateCustomerState(
        name: 'Walk-in',
        status: CreateCustomerStatus.saving,
        showValidation: true,
      ),
      CreateCustomerState(
        name: 'Walk-in',
        status: CreateCustomerStatus.success,
        showValidation: true,
        createdCustomer: _created,
      ),
    ],
    verify: (_) => verifyNever(
      () => repository.findPotentialDuplicates(
        businessId: any(named: 'businessId'),
        phone: any(named: 'phone'),
      ),
    ),
  );

  blocTest<CreateCustomerCubit, CreateCustomerState>(
    'warns about a possible duplicate instead of saving',
    setUp: () => when(
      () => repository.findPotentialDuplicates(
        businessId: 'b1',
        phone: '9876543210',
      ),
    ).thenAnswer((_) async => [_existing]),
    build: build,
    seed: () => const CreateCustomerState(name: 'Biju', phone: '9876543210'),
    act: (cubit) => cubit.submit(),
    skip: 1,
    expect: () => const [
      CreateCustomerState(
        name: 'Biju',
        phone: '9876543210',
        status: CreateCustomerStatus.duplicateWarning,
        showValidation: true,
        duplicates: [_existing],
      ),
    ],
    verify: (_) => verifyNever(
      () => repository.createCustomer(
        businessId: any(named: 'businessId'),
        name: any(named: 'name'),
        phone: any(named: 'phone'),
      ),
    ),
  );

  blocTest<CreateCustomerCubit, CreateCustomerState>(
    'allows a shared phone number once the user confirms',
    build: build,
    seed: () => const CreateCustomerState(
      name: 'Biju',
      phone: '9876543210',
      status: CreateCustomerStatus.duplicateWarning,
      showValidation: true,
      duplicates: [_existing],
    ),
    act: (cubit) => cubit.createAnyway(),
    verify: (cubit) {
      expect(cubit.state.status, CreateCustomerStatus.success);
      expect(cubit.state.createdCustomer, _created);
      verify(
        () => repository.createCustomer(
          businessId: 'b1',
          name: 'Biju',
          phone: '9876543210',
          email: '',
          notes: '',
        ),
      ).called(1);
    },
  );

  blocTest<CreateCustomerCubit, CreateCustomerState>(
    'returns to editing when the warning is dismissed',
    build: build,
    seed: () => const CreateCustomerState(
      name: 'Biju',
      status: CreateCustomerStatus.duplicateWarning,
    ),
    act: (cubit) => cubit.dismissDuplicateWarning(),
    expect: () => const [CreateCustomerState(name: 'Biju')],
  );

  blocTest<CreateCustomerCubit, CreateCustomerState>(
    'changing the phone requires a new duplicate check',
    build: build,
    seed: () => const CreateCustomerState(
      name: 'Biju',
      phone: '1',
      duplicatesAcknowledged: true,
    ),
    act: (cubit) => cubit.phoneChanged('2'),
    expect: () => const [CreateCustomerState(name: 'Biju', phone: '2')],
  );

  blocTest<CreateCustomerCubit, CreateCustomerState>(
    'reports a missing business instead of using a placeholder ID',
    setUp: () => when(
      () => repository.getBusinessIdForUser(testUser.id),
    ).thenAnswer((_) async => null),
    build: build,
    seed: () => const CreateCustomerState(name: 'A'),
    act: (cubit) => cubit.submit(),
    skip: 1,
    expect: () => const [
      CreateCustomerState(
        name: 'A',
        status: CreateCustomerStatus.failure,
        showValidation: true,
        failure: CreateCustomerFailure.noBusiness,
      ),
    ],
  );

  blocTest<CreateCustomerCubit, CreateCustomerState>(
    'maps the legacy unique-phone constraint',
    setUp: () => when(
      () => repository.createCustomer(
        businessId: any(named: 'businessId'),
        name: any(named: 'name'),
        phone: any(named: 'phone'),
        email: any(named: 'email'),
        notes: any(named: 'notes'),
      ),
    ).thenThrow(const CustomerPhoneAlreadyExistsException()),
    build: build,
    seed: () => const CreateCustomerState(name: 'A', phone: '9876543210'),
    act: (cubit) => cubit.submit(),
    verify: (cubit) => expect(
      cubit.state.failure,
      CreateCustomerFailure.phoneAlreadyUsed,
    ),
  );

  blocTest<CreateCustomerCubit, CreateCustomerState>(
    'reports unexpected failures',
    setUp: () => when(
      () => repository.getBusinessIdForUser(any()),
    ).thenThrow(Exception('offline')),
    build: build,
    seed: () => const CreateCustomerState(name: 'A'),
    act: (cubit) => cubit.submit(),
    verify: (cubit) =>
        expect(cubit.state.failure, CreateCustomerFailure.unknown),
  );

  blocTest<CreateCustomerCubit, CreateCustomerState>(
    'ignores edits and submits while saving',
    build: build,
    seed: () => const CreateCustomerState(
      name: 'A',
      status: CreateCustomerStatus.saving,
    ),
    act: (cubit) async {
      cubit.nameChanged('B');
      await cubit.submit();
    },
    expect: () => const <CreateCustomerState>[],
  );
}
