import 'dart:async';

import 'package:app_ui/app_ui.dart';
import 'package:evently_vendor/app/routing/app_routes.dart';
import 'package:evently_vendor/notifications/notifications.dart';
import 'package:evently_vendor/profile/profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

/// Home tab.
///
/// Bookings do not exist yet, so the booking sections say so rather than
/// showing an empty schedule as if it were real data. Reads the business
/// name from the [ProfileCubit] provided by the app shell.
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        titleSpacing: 20,
        title: const _BusinessTitle(),
        actions: const [NotificationBellButton(), SizedBox(width: 8)],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: Color(0xFFE5E7EB)),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => unawaited(context.push(AppRoutes.newBooking)),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('New Booking'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 96),
        children: const [
          _SectionTitle("Today's Schedule"),
          _InfoCard(
            icon: Icons.calendar_today_rounded,
            title: 'Bookings are coming soon',
            message:
                "Today's events will appear here once booking management "
                'is available.',
          ),
          SizedBox(height: 20),
          _SectionTitle('Upcoming Bookings'),
          _InfoCard(
            icon: Icons.bookmark_border_rounded,
            title: 'Bookings are coming soon',
            message: 'Your upcoming events will appear here.',
          ),
          SizedBox(height: 20),
          _GettingStartedCard(),
        ],
      ),
    );
  }
}

class _BusinessTitle extends StatelessWidget {
  const _BusinessTitle();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<ProfileCubit>().state;
    final profile = state.profile;
    final (title, subtitle) = switch (state.status) {
      ProfileStatus.success when profile != null => (
        profile.businessName,
        profile.category,
      ),
      ProfileStatus.failure => ('Home', "Couldn't load business details"),
      _ => ('Home', null),
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Color(0xFF111827),
            fontFamily: 'Inter',
          ),
        ),
        if (subtitle != null)
          Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF6B7280),
              fontFamily: 'Inter',
            ),
          ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: Color(0xFF111827),
          fontFamily: 'Inter',
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: const Color(0x14FF4040),
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: Icon(icon, size: 16, color: const Color(0xFF9CA3AF)),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF111827),
              fontFamily: 'Inter',
            ),
          ),
          const SizedBox(height: 2),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF9CA3AF),
              fontFamily: 'Inter',
            ),
          ),
        ],
      ),
    );
  }
}

/// Setup checklist. Only "Business created" is known to be done (users
/// reach Home only after creating a business); the other items cannot be
/// completed in the app yet, so no progress percentage is shown.
class _GettingStartedCard extends StatelessWidget {
  const _GettingStartedCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Complete Your Workspace',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFF111827),
              fontFamily: 'Inter',
            ),
          ),
          SizedBox(height: 16),
          _ChecklistItem(title: 'Business Created', isCompleted: true),
          _ChecklistItem(title: 'Add Your First Service', comingSoon: true),
          _ChecklistItem(title: 'Upload Business Logo', comingSoon: true),
          _ChecklistItem(title: 'Add Business Location', comingSoon: true),
        ],
      ),
    );
  }
}

class _ChecklistItem extends StatelessWidget {
  const _ChecklistItem({
    required this.title,
    this.isCompleted = false,
    this.comingSoon = false,
  });

  final String title;
  final bool isCompleted;
  final bool comingSoon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(
            isCompleted
                ? Icons.check_box_rounded
                : Icons.check_box_outline_blank_rounded,
            size: 18,
            color: isCompleted
                ? const Color(0xFFFF4040)
                : const Color(0xFFD1D5DB),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isCompleted ? FontWeight.w400 : FontWeight.w600,
                color: isCompleted
                    ? const Color(0xFF9CA3AF)
                    : const Color(0xFF111827),
                decoration: isCompleted ? TextDecoration.lineThrough : null,
                fontFamily: 'Inter',
              ),
            ),
          ),
          if (comingSoon)
            const Text(
              'Coming soon',
              style: TextStyle(fontSize: 11, color: Color(0xFF9CA3AF)),
            ),
        ],
      ),
    );
  }
}
