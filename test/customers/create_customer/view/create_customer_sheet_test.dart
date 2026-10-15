import 'package:customer_repository/customer_repository.dart';
import 'package:evently_vendor/customers/customers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/helpers.dart';

const _existing = Customer(
  id: 'c1',
  businessId: 'b1',
  name: 'Anu Thomas',
  phone: '+919876543210',
);
const _created = Customer(id: 'c2', businessId: 'b1', name: 'Biju Thomas');

void main() {
  late CustomerRepository repository;
  Customer? result;

  setUp(() {
    result = null;
    repository = MockCustomerRepository();
    when(
      () => repository.getBusinessIdForUser(any()),
    ).thenAnswer((_) async => 'b1');
    when(
      () => repository.findPotentialDuplicates(
        businessId: any(named: 'businessId'),
        phone: any(named: 'phone'),
      ),
    ).thenAnswer((_) async => [_existing]);
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

  Future<void> openSheet(WidgetTester tester) async {
    await tester.pumpApp(
      Builder(
        builder: (context) => Scaffold(
          body: TextButton(
            onPressed: () async =>
                result = await CreateCustomerSheet.show(context),
            child: const Text('open'),
          ),
        ),
      ),
      customerRepository: repository,
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  Future<void> fillAndSave(WidgetTester tester) async {
    await tester.enterText(
      find.widgetWithText(TextField, 'e.g. Anu Thomas'),
      'Biju Thomas',
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'e.g. 98765 43210'),
      '98765 43210',
    );
    await tester.tap(find.text('Save Customer'));
    await tester.pumpAndSettle();
  }

  testWidgets('renders fields with phone marked optional', (tester) async {
    await openSheet(tester);
    expect(find.text('Add New Customer'), findsOneWidget);
    expect(find.text('Full Name *'), findsOneWidget);
    expect(find.text('Phone Number (Optional)'), findsOneWidget);
    expect(find.text('Email Address (Optional)'), findsOneWidget);
    expect(find.text('Notes (Optional)'), findsOneWidget);
    expect(find.text('Save Customer'), findsOneWidget);
  });

  testWidgets('requires a name', (tester) async {
    await openSheet(tester);
    await tester.tap(find.text('Save Customer'));
    await tester.pump();
    expect(find.text('Customer name is required'), findsOneWidget);
  });

  testWidgets('can reuse an existing customer from the duplicate warning', (
    tester,
  ) async {
    await openSheet(tester);
    await fillAndSave(tester);

    expect(find.text('Possible duplicate'), findsOneWidget);
    await tester.tap(find.text('Use'));
    await tester.pumpAndSettle();

    expect(result, _existing);
    verifyNever(
      () => repository.createCustomer(
        businessId: any(named: 'businessId'),
        name: any(named: 'name'),
        phone: any(named: 'phone'),
        email: any(named: 'email'),
        notes: any(named: 'notes'),
      ),
    );
  });

  testWidgets('can create a new customer that shares the phone', (
    tester,
  ) async {
    await openSheet(tester);
    await fillAndSave(tester);

    await tester.tap(find.text('Create new customer'));
    await tester.pumpAndSettle();

    expect(result, _created);
    expect(find.text('Add New Customer'), findsNothing);
  });
}
