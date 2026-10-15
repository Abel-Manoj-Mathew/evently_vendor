import 'package:customer_repository/customer_repository.dart';
import 'package:evently_vendor/booking/create_booking/create_booking.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/helpers.dart';

final _customers = [
  Customer(
    id: 'c1',
    businessId: 'b1',
    name: 'Anu Thomas',
    phone: '+919876543210',
    createdAt: DateTime(2026, 1, 15),
  ),
  const Customer(id: 'c2', businessId: 'b1', name: 'Rahul Nair'),
];

void main() {
  late CustomerRepository customerRepository;

  setUp(() {
    customerRepository = MockCustomerRepository();
    when(
      () => customerRepository.getBusinessIdForUser(testUser.id),
    ).thenAnswer((_) async => 'b1');
    when(
      () => customerRepository.getCustomers(businessId: 'b1'),
    ).thenAnswer((_) async => _customers);
  });

  Future<void> pumpPage(WidgetTester tester) async {
    await tester.pumpApp(
      const CreateBookingPage(),
      customerRepository: customerRepository,
    );
    await tester.pumpAndSettle();
  }

  testWidgets('marks the booking flow as unfinished', (tester) async {
    await pumpPage(tester);
    expect(find.text('Create Booking'), findsOneWidget);
    expect(
      find.textContaining('Booking creation is still being built'),
      findsOneWidget,
    );
  });

  testWidgets('lists real customers and no sample data', (tester) async {
    await pumpPage(tester);
    expect(find.text('Select a customer'), findsOneWidget);
    expect(find.text('Anu Thomas'), findsOneWidget);
    expect(find.text('Rahul Nair'), findsOneWidget);
    expect(find.text('No phone number'), findsOneWidget);
    for (final sample in [
      'Sarah Johnson',
      'Marcus Rivera',
      'Priya Nair',
      'Tom Okafor',
    ]) {
      expect(find.text(sample), findsNothing);
    }
  });

  testWidgets('filters by name and phone digits', (tester) async {
    await pumpPage(tester);
    await tester.enterText(find.byType(TextField), '98765');
    await tester.pump();
    expect(find.text('Anu Thomas'), findsOneWidget);
    expect(find.text('Rahul Nair'), findsNothing);

    await tester.enterText(find.byType(TextField), 'zzz');
    await tester.pump();
    expect(find.text('No matching customers'), findsOneWidget);
  });

  testWidgets('shows an honest empty state', (tester) async {
    when(
      () => customerRepository.getCustomers(businessId: 'b1'),
    ).thenAnswer((_) async => []);
    await pumpPage(tester);
    expect(find.text('No customers yet'), findsOneWidget);
  });

  testWidgets('shows an error with retry when loading fails', (tester) async {
    when(
      () => customerRepository.getCustomers(businessId: 'b1'),
    ).thenThrow(Exception('offline'));
    await pumpPage(tester);
    expect(find.text("Couldn't load customers"), findsOneWidget);

    when(
      () => customerRepository.getCustomers(businessId: 'b1'),
    ).thenAnswer((_) async => _customers);
    await tester.tap(find.text('Try again'));
    await tester.pumpAndSettle();
    expect(find.text('Anu Thomas'), findsOneWidget);
  });
}
