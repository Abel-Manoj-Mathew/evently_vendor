import 'package:customer_repository/customer_repository.dart';
import 'package:evently_vendor/customers/customers.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/helpers.dart';

void main() {
  late CustomerRepository customerRepository;

  setUp(() => customerRepository = MockCustomerRepository());

  Future<void> pumpPage(WidgetTester tester) async {
    await tester.pumpApp(
      const CustomerDetailsPage(customerId: 'c1'),
      customerRepository: customerRepository,
    );
    await tester.pumpAndSettle();
  }

  testWidgets('renders the stored customer', (tester) async {
    when(() => customerRepository.getCustomer('c1')).thenAnswer(
      (_) async => Customer(
        id: 'c1',
        businessId: 'b1',
        name: 'Anu Thomas',
        phone: '+919876543210',
        notes: 'Prefers WhatsApp',
        createdAt: DateTime.utc(2026, 3, 5),
      ),
    );
    await pumpPage(tester);

    expect(find.text('Anu Thomas'), findsNWidgets(2));
    expect(find.text('AT'), findsOneWidget);
    expect(find.text('Customer since Mar 5, 2026'), findsOneWidget);
    expect(find.text('+919876543210'), findsOneWidget);
    expect(find.text('Not provided'), findsOneWidget);
    expect(find.text('Prefers WhatsApp'), findsOneWidget);
    expect(find.textContaining('once booking management'), findsOneWidget);
    // No fabricated statistics or event history.
    expect(find.text('Amara & James Wedding'), findsNothing);
    expect(find.text('Last Event'), findsNothing);
  });

  testWidgets('handles a missing or inaccessible customer', (tester) async {
    when(
      () => customerRepository.getCustomer('c1'),
    ).thenAnswer((_) async => null);
    await pumpPage(tester);
    expect(find.text('Customer not found'), findsOneWidget);
  });

  testWidgets('offers retry when loading fails', (tester) async {
    when(
      () => customerRepository.getCustomer('c1'),
    ).thenThrow(Exception('offline'));
    await pumpPage(tester);
    expect(find.text("Couldn't load this customer"), findsOneWidget);
    expect(find.text('Try again'), findsOneWidget);
  });
}
