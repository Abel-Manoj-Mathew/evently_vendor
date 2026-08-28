import 'package:business_repository/business_repository.dart';
import 'package:evently_vendor/onboarding/business_details/cubit/business_details_cubit.dart';
import 'package:evently_vendor/onboarding/business_details/view/business_details_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BusinessDetailsPage extends StatelessWidget {
  const BusinessDetailsPage({super.key});

  static Route<void> route() {
    return MaterialPageRoute<void>(
      builder: (_) => const BusinessDetailsPage(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => BusinessDetailsCubit(
        businessRepository: context.read<BusinessRepository>(),
      ),
      child: const BusinessDetailsView(),
    );
  }
}
