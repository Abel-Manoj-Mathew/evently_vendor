import 'dart:async';

import 'package:authentication_client/authentication_client.dart';
import 'package:evently_vendor/app/routing/app_routes.dart';
import 'package:evently_vendor/auth/mobile_number/cubit/mobile_number_cubit.dart';
import 'package:evently_vendor/auth/mobile_number/widgets/mobile_number_input_field.dart';
import 'package:evently_vendor/auth/shared/auth_failure_message.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class MobileNumberPage extends StatelessWidget {
  const MobileNumberPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MobileNumberCubit(
        authenticationClient: context.read<AuthenticationClient>(),
      ),
      child: const MobileNumberView(),
    );
  }
}

class MobileNumberView extends StatelessWidget {
  const MobileNumberView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<MobileNumberCubit, MobileNumberState>(
      listenWhen: (previous, current) => previous.status != current.status,
      listener: (context, state) {
        switch (state.status) {
          case MobileNumberStatus.sent:
            context.read<MobileNumberCubit>().acknowledgeSent();
            unawaited(context.push(AppRoutes.verifyOtp, extra: state.e164));
          case MobileNumberStatus.failure:
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: Text(
                    (state.failureReason ?? AuthFailureReason.unknown).message,
                  ),
                  backgroundColor: const Color(0xFFEF4444),
                ),
              );
          case MobileNumberStatus.initial:
          case MobileNumberStatus.sending:
            break;
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFFFFFFF),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: IconButton(
                    tooltip: 'Back',
                    padding: EdgeInsets.zero,
                    alignment: Alignment.centerLeft,
                    onPressed: () => context.pop(),
                    icon: const Icon(
                      Icons.arrow_back,
                      size: 20,
                      color: Color(0xFF111827),
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(top: 40),
                  child: Text(
                    'Enter your mobile number',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      height: 1.3,
                      color: Color(0xFF111827),
                      fontFamily: 'Inter',
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(top: 12),
                  child: Text(
                    "We'll send you a verification code to continue.",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      height: 1.6,
                      color: Color(0xFF6B7280),
                      fontFamily: 'Inter',
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(top: 32),
                  child: _NumberField(),
                ),
                const Padding(
                  padding: EdgeInsets.only(top: 24),
                  child: _ContinueButton(),
                ),
                const Padding(
                  padding: EdgeInsets.only(top: 16, bottom: 24),
                  child: Center(
                    child: Text(
                      "We'll only use this number for verification.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF9CA3AF),
                        fontFamily: 'Inter',
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NumberField extends StatelessWidget {
  const _NumberField();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<MobileNumberCubit>().state;
    return MobileNumberInputField(
      countryCode: state.countryCode,
      enabled: state.status != MobileNumberStatus.sending,
      errorText: state.showFormatError
          ? 'Enter a valid 10-digit Indian mobile number.'
          : null,
      onPhoneNumberChanged: context.read<MobileNumberCubit>().numberChanged,
    );
  }
}

class _ContinueButton extends StatelessWidget {
  const _ContinueButton();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<MobileNumberCubit>().state;
    final isSending = state.status == MobileNumberStatus.sending;
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: state.isValid && !isSending
            ? context.read<MobileNumberCubit>().submit
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFF4040),
          disabledBackgroundColor: const Color(
            0xFFFF4040,
          ).withValues(alpha: 0.5),
          foregroundColor: Colors.white,
          disabledForegroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: isSending
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : const Text(
                'Continue',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Inter',
                ),
              ),
      ),
    );
  }
}
