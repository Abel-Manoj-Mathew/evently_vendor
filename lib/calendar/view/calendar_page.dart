import 'package:app_ui/app_ui.dart';
import 'package:evently_vendor/notifications/notifications.dart';
import 'package:flutter/material.dart';

/// Calendar tab. Not built yet; shown as unavailable rather than empty.
class CalendarPage extends StatelessWidget {
  const CalendarPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: const Text('Calendar'),
        actions: const [NotificationBellButton()],
      ),
      body: const AppEmptyState(
        icon: Icons.calendar_month_outlined,
        title: 'Calendar is coming soon',
        message:
            'Your bookings will appear here by month, week and day once '
            'booking management is available.',
      ),
    );
  }
}
