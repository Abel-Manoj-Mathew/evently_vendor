import 'package:evently_vendor/auth/mobile_number/bloc/mobile_number_bloc.dart';
import 'package:evently_vendor/auth/mobile_number/view/mobile_number_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MobileNumberPage extends StatelessWidget {
  const MobileNumberPage({super.key});

  static Route<void> route() {
    return MaterialPageRoute<void>(
      builder: (_) => const MobileNumberPage(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => MobileNumberBloc(),
      child: MobileNumberView(
        onBackPressed: () => Navigator.of(context).pop(),
        onSendOtpPressed: () {
          // TODO(developer): Navigate to OTP verification screen
        },
      ),
    );
  }
}
