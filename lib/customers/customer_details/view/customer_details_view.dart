import 'dart:async';

import 'package:app_ui/app_ui.dart';
import 'package:customer_repository/customer_repository.dart';
import 'package:evently_vendor/customers/customer_details/cubit/customer_details_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class CustomerDetailsView extends StatelessWidget {
  const CustomerDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<CustomerDetailsCubit>().state;
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: Text(state.customer?.name ?? 'Customer'),
        backgroundColor: AppColors.white,
      ),
      body: switch (state.status) {
        CustomerDetailsStatus.loading => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        CustomerDetailsStatus.notFound => const AppEmptyState(
          icon: Icons.person_off_outlined,
          title: 'Customer not found',
          message:
              'This customer may have been removed or is no longer available '
              'to your business.',
        ),
        CustomerDetailsStatus.failure => AppEmptyState(
          icon: Icons.cloud_off_outlined,
          title: "Couldn't load this customer",
          message: 'Check your internet connection and try again.',
          action: FilledButton(
            onPressed: () =>
                unawaited(context.read<CustomerDetailsCubit>().load()),
            child: const Text('Try again'),
          ),
        ),
        CustomerDetailsStatus.success => _CustomerDetails(
          customer: state.customer!,
        ),
      },
    );
  }
}

class _CustomerDetails extends StatelessWidget {
  const _CustomerDetails({required this.customer});

  final Customer customer;

  @override
  Widget build(BuildContext context) {
    final createdAt = customer.createdAt;
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: AppColors.primaryLight,
              child: Text(
                customer.initials,
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    customer.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (createdAt != null)
                    Text(
                      'Customer since '
                      '${DateFormat.yMMMd().format(createdAt.toLocal())}',
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        _DetailTile(
          icon: Icons.phone_outlined,
          label: 'Phone',
          value: customer.phone,
        ),
        _DetailTile(
          icon: Icons.mail_outline,
          label: 'Email',
          value: customer.email,
        ),
        _DetailTile(
          icon: Icons.notes_outlined,
          label: 'Notes',
          value: customer.notes,
        ),
        const SizedBox(height: 24),
        const Text(
          'Booking history',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.borderOutline),
          ),
          child: const Text(
            "This customer's bookings will appear here once booking "
            'management is available.',
            style: TextStyle(color: AppColors.textSecondary, height: 1.5),
          ),
        ),
      ],
    );
  }
}

class _DetailTile extends StatelessWidget {
  const _DetailTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String? value;

  @override
  Widget build(BuildContext context) {
    final hasValue = value != null && value!.trim().isNotEmpty;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: AppColors.textSecondary),
      title: Text(
        label,
        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
      ),
      subtitle: Text(
        hasValue ? value! : 'Not provided',
        style: TextStyle(
          fontSize: 15,
          color: hasValue ? AppColors.textPrimary : AppColors.textMuted,
        ),
      ),
    );
  }
}
