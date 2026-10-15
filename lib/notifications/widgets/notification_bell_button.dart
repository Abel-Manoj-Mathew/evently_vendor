import 'package:app_ui/app_ui.dart';
import 'package:evently_vendor/app/routing/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// App-bar bell that opens the notification center.
///
/// The badge is shown only when [unreadCount] is positive. Notifications do
/// not exist yet (planned with reminders), so callers currently pass 0.
class NotificationBellButton extends StatelessWidget {
  const NotificationBellButton({this.unreadCount = 0, super.key});

  final int unreadCount;

  @override
  Widget build(BuildContext context) {
    final label = unreadCount > 0
        ? 'Notifications, $unreadCount unread'
        : 'Notifications';
    return IconButton(
      tooltip: label,
      onPressed: () => context.push(AppRoutes.notifications),
      icon: Badge(
        isLabelVisible: unreadCount > 0,
        backgroundColor: AppColors.primary,
        label: Text(unreadCount > 99 ? '99+' : '$unreadCount'),
        child: const Icon(Icons.notifications_none_outlined),
      ),
    );
  }
}
