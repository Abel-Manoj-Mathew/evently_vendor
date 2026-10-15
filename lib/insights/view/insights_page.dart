import 'package:app_ui/app_ui.dart';
import 'package:evently_vendor/notifications/notifications.dart';
import 'package:flutter/material.dart';

/// Insights tab. Not built yet; shown as unavailable rather than empty.
class InsightsPage extends StatelessWidget {
  const InsightsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: const Text('Insights'),
        actions: const [NotificationBellButton()],
      ),
      body: const AppEmptyState(
        icon: Icons.insights_outlined,
        title: 'Insights are coming soon',
        message:
            'Booking trends, collections and outstanding balances will '
            'appear here once bookings and payments are available.',
      ),
    );
  }
}
