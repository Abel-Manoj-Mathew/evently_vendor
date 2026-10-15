import 'package:evently_vendor/onboarding/user_information/cubit/user_information_cubit.dart';
import 'package:evently_vendor/onboarding/user_information/view/user_information_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:user_repository/user_repository.dart';

class UserInformationPage extends StatelessWidget {
  const UserInformationPage({
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
      create: (context) => UserInformationCubit(
        userRepository: context.read<UserRepository>(),
      ),
      child: UserInformationView(
        onBack: onBack,
        onSaved: onSaved,
        backTooltip: backTooltip,
      ),
    );
  }
}
