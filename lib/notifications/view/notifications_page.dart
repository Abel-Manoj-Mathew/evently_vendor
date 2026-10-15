import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';

/// Notification center. Booking reminders are not built yet, so this is an
/// honest placeholder rather than an empty inbox.
class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(title: const Text('Notifications')),
      body: const AppEmptyState(
        icon: Icons.notifications_none_outlined,
        title: 'Notifications are coming soon',
        message:
            'Booking reminders and updates will appear here once reminders '
            'are available.',
      ),
    );
  }
}
