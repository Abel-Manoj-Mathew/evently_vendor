import 'package:business_repository/business_repository.dart';
import 'package:evently_vendor/onboarding/business_details/cubit/business_details_cubit.dart';
import 'package:evently_vendor/onboarding/business_details/view/business_details_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BusinessDetailsPage extends StatelessWidget {
  const BusinessDetailsPage({
    required this.onBack,
    required this.onSaved,
    this.backTooltip = 'Back',
    super.key,
  });

  final VoidCallback onBack;
  final VoidCallback onSaved;
  final String backTooltip;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => BusinessDetailsCubit(
        businessRepository: context.read<BusinessRepository>(),
      ),
      child: BusinessDetailsView(
        onBack: onBack,
        onSaved: onSaved,
        backTooltip: backTooltip,
      ),
    );
  }
}
