import 'package:evently_vendor/booking/create_booking/view/create_booking_page.dart';
import 'package:evently_vendor/customer/customer_details/view/customer_details_view.dart';
import 'package:flutter/material.dart';

class CustomerDetailsPage extends StatelessWidget {
  const CustomerDetailsPage({
    super.key,
    this.customer,
  });

  final CustomerItem? customer;

  static Route<void> route({CustomerItem? customer}) {
    return MaterialPageRoute<void>(
      builder: (_) => CustomerDetailsPage(customer: customer),
    );
  }

  @override
  Widget build(BuildContext context) {
    final effectiveCustomer = customer ??
        const CustomerItem(
          name: 'Sarah Johnson',
          phone: '+1 (555) 201-4892',
          initials: 'SJ',
          email: 'sarah.johnson@email.com',
          customerSince: 'Mar 2023',
          bookingsCount: 3,
          lastEvent: 'Wedding',
          upcomingEvent: 'None',
        );

    return CustomerDetailsView(customer: effectiveCustomer);
  }
}
