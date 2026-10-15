import 'package:customer_repository/customer_repository.dart';
import 'package:evently_vendor/customer/create_customer/create_customer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockCustomerRepository extends Mock implements CustomerRepository {}

void main() {
  group('CreateCustomerSheet', () {
    late CustomerRepository customerRepository;

    setUp(() {
      customerRepository = MockCustomerRepository();
    });

    testWidgets('renders all input fields and submit button', (tester) async {
      tester.view.physicalSize = const Size(375, 812);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        RepositoryProvider<CustomerRepository>.value(
          value: customerRepository,
          child: const MaterialApp(
            home: Scaffold(
              body: CreateCustomerSheet(),
            ),
          ),
        ),
      );

      expect(find.text('Add New Customer'), findsOneWidget);
      expect(find.text('Full Name *'), findsOneWidget);
      expect(find.text('Phone Number *'), findsOneWidget);
      expect(find.text('Email Address (Optional)'), findsOneWidget);
      expect(find.text('Notes (Optional)'), findsOneWidget);
      expect(find.text('Save Customer'), findsOneWidget);
    });

    testWidgets('shows validation errors when submitting empty form',
        (tester) async {
      tester.view.physicalSize = const Size(375, 812);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        RepositoryProvider<CustomerRepository>.value(
          value: customerRepository,
          child: const MaterialApp(
            home: Scaffold(
              body: CreateCustomerSheet(),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Save Customer'));
      await tester.pump();

      expect(find.text('Customer name is required'), findsOneWidget);
      expect(find.text('Phone number is required'), findsOneWidget);
    });
  });
}
