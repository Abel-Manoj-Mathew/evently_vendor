import 'dart:async';

import 'package:app_ui/app_ui.dart';
import 'package:customer_repository/customer_repository.dart';
import 'package:evently_vendor/app/bloc/app_bloc.dart';
import 'package:evently_vendor/app/routing/app_routes.dart';
import 'package:evently_vendor/booking/create_booking/cubit/select_customer_cubit.dart';
import 'package:evently_vendor/customers/customers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

/// First step of the booking flow: choose or add a customer.
///
/// Booking creation is unfinished; only this step exists. The screen says
/// so instead of pretending the flow is complete.
class CreateBookingPage extends StatelessWidget {
  const CreateBookingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final cubit = SelectCustomerCubit(
          customerRepository: context.read<CustomerRepository>(),
          ownerId: context.read<AppBloc>().state.user!.id,
        );
        unawaited(cubit.load());
        return cubit;
      },
      child: const CreateBookingView(),
    );
  }
}

class CreateBookingView extends StatelessWidget {
  const CreateBookingView({super.key});

  Future<void> _addCustomer(BuildContext context) async {
    final cubit = context.read<SelectCustomerCubit>();
    final messenger = ScaffoldMessenger.of(context);
    final customer = await CreateCustomerSheet.show(context);
    if (customer == null) return;
    cubit.customerAdded(customer);
    messenger.showSnackBar(
      SnackBar(
        content: Text('${customer.name} is ready to use.'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        title: const Text('Create Booking'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _UnfinishedBanner(),
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Select a customer',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Search an existing customer or create a new one.',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: TextField(
              onChanged: context.read<SelectCustomerCubit>().queryChanged,
              decoration: const InputDecoration(
                hintText: 'Search by customer name or mobile number',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          const Expanded(child: _CustomerList()),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton.icon(
                  onPressed: () => unawaited(_addCustomer(context)),
                  icon: const Icon(Icons.person_add_alt_1_outlined),
                  label: const Text('New Customer'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _UnfinishedBanner extends StatelessWidget {
  const _UnfinishedBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: const Color(0xFFFFF7ED),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: const Row(
        children: [
          Icon(Icons.construction_outlined, color: Color(0xFFC2410C), size: 20),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Booking creation is still being built. You can choose or add '
              'customers now; saving bookings is coming soon.',
              style: TextStyle(fontSize: 13, color: Color(0xFF9A3412)),
            ),
          ),
        ],
      ),
    );
  }
}

class _CustomerList extends StatelessWidget {
  const _CustomerList();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<SelectCustomerCubit>().state;
    switch (state.status) {
      case SelectCustomerStatus.loading:
        return const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        );
      case SelectCustomerStatus.noBusiness:
        return const AppEmptyState(
          icon: Icons.storefront_outlined,
          title: 'No business found',
          message: 'Finish setting up your business to add customers.',
        );
      case SelectCustomerStatus.failure:
        return AppEmptyState(
          icon: Icons.cloud_off_outlined,
          title: "Couldn't load customers",
          message: 'Check your internet connection and try again.',
          action: FilledButton(
            onPressed: () =>
                unawaited(context.read<SelectCustomerCubit>().load()),
            child: const Text('Try again'),
          ),
        );
      case SelectCustomerStatus.success:
        final customers = state.visibleCustomers;
        if (state.customers.isEmpty) {
          return const AppEmptyState(
            icon: Icons.people_outline,
            title: 'No customers yet',
            message: 'Add your first customer to start a booking.',
          );
        }
        if (customers.isEmpty) {
          return const AppEmptyState(
            icon: Icons.search_off,
            title: 'No matching customers',
            message: 'Try another name or number, or add a new customer.',
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          itemCount: customers.length,
          separatorBuilder: (_, _) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final customer = customers[index];
            return ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                backgroundColor: AppColors.primaryLight,
                child: Text(
                  customer.initials,
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              title: Text(customer.name),
              subtitle: Text(customer.phone ?? 'No phone number'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => unawaited(
                context.push(AppRoutes.customerDetails(customer.id)),
              ),
            );
          },
        );
    }
  }
}
