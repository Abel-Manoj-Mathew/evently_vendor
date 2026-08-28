import 'package:customer_repository/customer_repository.dart';
import 'package:evently_vendor/booking/create_booking/create_booking.dart';
import 'package:evently_vendor/customer/customer_details/view/customer_details_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockCustomerRepository extends Mock implements CustomerRepository {}

void main() {
  group('CreateBookingPage', () {
    late MockCustomerRepository customerRepository;

    setUp(() {
      customerRepository = MockCustomerRepository();
    });

    testWidgets('renders top bar, search input, recent customers and bottom button',
        (tester) async {
      tester.view.physicalSize = const Size(375, 812);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const MaterialApp(
          home: CreateBookingPage(),
        ),
      );

      expect(find.text('Create Booking'), findsOneWidget);
      expect(find.text('Select a customer'), findsOneWidget);
      expect(
        find.text('Search an existing customer or create a new one.'),
        findsOneWidget,
      );
      expect(
        find.text('Search by customer name or mobile number'),
        findsOneWidget,
      );
      expect(find.text('RECENT CUSTOMERS'), findsOneWidget);
      expect(find.text('Sarah Johnson'), findsOneWidget);
      expect(find.text('Marcus Rivera'), findsOneWidget);
      expect(find.text('Priya Nair'), findsOneWidget);
      expect(find.text('Tom Okafor'), findsOneWidget);
      expect(find.text('+ New Customer'), findsOneWidget);
    });

    testWidgets('loads and renders customer names from database when available',
        (tester) async {
      tester.view.physicalSize = const Size(375, 812);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      when(() => customerRepository.getBusinessIdForUser(any()))
          .thenAnswer((_) async => '00000000-0000-0000-0000-000000000000');
      when(
        () => customerRepository.getCustomers(
          businessId: any(named: 'businessId'),
        ),
      ).thenAnswer(
        (_) async => [
          Customer(
            id: 'c1',
            businessId: '00000000-0000-0000-0000-000000000000',
            name: 'Alice Database',
            phone: '+1 111 222 3333',
            email: 'alice@db.com',
            createdAt: DateTime(2026, 1, 15),
          ),
          Customer(
            id: 'c2',
            businessId: '00000000-0000-0000-0000-000000000000',
            name: 'Bob Database',
            phone: '+1 444 555 6666',
            email: 'bob@db.com',
            createdAt: DateTime(2026, 2, 20),
          ),
        ],
      );

      await tester.pumpWidget(
        RepositoryProvider<CustomerRepository>.value(
          value: customerRepository,
          child: const MaterialApp(
            home: CreateBookingPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('RECENT CUSTOMERS'), findsOneWidget);
      expect(find.text('Alice Database'), findsOneWidget);
      expect(find.text('Bob Database'), findsOneWidget);
    });

    testWidgets('filtering search updates customer list', (tester) async {
      tester.view.physicalSize = const Size(375, 812);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const MaterialApp(
          home: CreateBookingPage(),
        ),
      );

      final searchInput = find.byType(TextField);
      await tester.enterText(searchInput, 'Sarah');
      await tester.pump();

      expect(find.text('Sarah Johnson'), findsOneWidget);
      expect(find.text('Marcus Rivera'), findsNothing);
    });

    testWidgets('tapping customer row triggers selection', (tester) async {
      tester.view.physicalSize = const Size(375, 812);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const MaterialApp(
          home: CreateBookingPage(),
        ),
      );

      await tester.tap(find.text('Sarah Johnson'));
      await tester.pumpAndSettle();

      expect(find.byType(CustomerDetailsPage), findsOneWidget);
    });

    testWidgets('tapping + New Customer opens CreateCustomerSheet', (tester) async {
      tester.view.physicalSize = const Size(375, 812);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const MaterialApp(
          home: CreateBookingPage(),
        ),
      );

      await tester.tap(find.text('+ New Customer'));
      await tester.pumpAndSettle();

      expect(find.text('Add New Customer'), findsOneWidget);
      expect(find.text('Full Name *'), findsOneWidget);
      expect(find.text('Phone Number *'), findsOneWidget);
    });

    test('route returns MaterialPageRoute', () {
      final route = CreateBookingPage.route();
      expect(route, isA<MaterialPageRoute<void>>());
    });
  });
}

