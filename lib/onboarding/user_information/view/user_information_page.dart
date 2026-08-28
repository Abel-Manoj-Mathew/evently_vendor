import 'package:evently_vendor/onboarding/user_information/cubit/user_information_cubit.dart';
import 'package:evently_vendor/onboarding/user_information/view/user_information_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:user_repository/user_repository.dart';

class UserInformationPage extends StatelessWidget {
  const UserInformationPage({super.key});

  static Route<void> route() {
    return MaterialPageRoute<void>(
      builder: (_) => const UserInformationPage(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => UserInformationCubit(
        userRepository: context.read<UserRepository>(),
      ),
      child: const UserInformationView(),
    );
  }
}
