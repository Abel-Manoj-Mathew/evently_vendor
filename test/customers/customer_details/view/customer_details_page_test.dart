import 'package:evently_vendor/booking/create_booking/view/create_booking_page.dart';
import 'package:evently_vendor/customer/customer_details/customer_details.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CustomerDetailsPage', () {
    testWidgets('renders customer profile information correctly',
        (tester) async {
      tester.view.physicalSize = const Size(375, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      const customer = CustomerItem(
        name: 'Sarah Johnson',
        phone: '+1 (555) 201-4892',
        initials: 'SJ',
        email: 'sarah.johnson@email.com',
        customerSince: 'Mar 2023',
        bookingsCount: 3,
        lastEvent: 'Wedding',
        upcomingEvent: 'None',
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: CustomerDetailsPage(customer: customer),
        ),
      );

      expect(find.text('Sarah Johnson'), findsNWidgets(2));
      expect(find.text('Customer since Mar 2023'), findsOneWidget);
      expect(find.text('+1 (555) 201-4892'), findsOneWidget);
      expect(find.text('sarah.johnson@email.com'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
      expect(find.text('Bookings'), findsOneWidget);
      expect(find.text('Last Event'), findsOneWidget);
      expect(find.text('Wedding'), findsNWidgets(2));
      expect(find.text('Upcoming'), findsOneWidget);
      expect(find.text('None'), findsOneWidget);
      expect(find.text('+ New Booking'), findsOneWidget);
      expect(find.text('Edit Customer'), findsOneWidget);
      expect(find.text('Call'), findsOneWidget);
      expect(find.text('Message'), findsOneWidget);
      expect(find.text('Event History'), findsOneWidget);
      expect(find.text('Amara & James Wedding'), findsOneWidget);
      expect(find.text('Rivera Birthday Party'), findsOneWidget);
      expect(find.text('Johnson Corporate Event'), findsOneWidget);
    });

    test('route returns MaterialPageRoute', () {
      final route = CustomerDetailsPage.route();
      expect(route, isA<MaterialPageRoute<void>>());
    });
  });
}
