import 'dart:async';

import 'package:customer_repository/customer_repository.dart';
import 'package:evently_vendor/customers/customer_details/cubit/customer_details_cubit.dart';
import 'package:evently_vendor/customers/customer_details/view/customer_details_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CustomerDetailsPage extends StatelessWidget {
  const CustomerDetailsPage({required this.customerId, super.key});

  final String customerId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final cubit = CustomerDetailsCubit(
          customerRepository: context.read<CustomerRepository>(),
          customerId: customerId,
        );
        unawaited(cubit.load());
        return cubit;
      },
      child: const CustomerDetailsView(),
    );
  }
}
