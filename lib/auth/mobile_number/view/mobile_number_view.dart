import 'package:evently_vendor/auth/mobile_number/bloc/mobile_number_bloc.dart';
import 'package:evently_vendor/auth/mobile_number/bloc/mobile_number_event.dart';
import 'package:evently_vendor/auth/mobile_number/bloc/mobile_number_state.dart';
import 'package:evently_vendor/auth/mobile_number/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MobileNumberView extends StatelessWidget {
  const MobileNumberView({
    required this.onBackPressed,
    required this.onSendOtpPressed,
    super.key,
  });

  final VoidCallback onBackPressed;
  final VoidCallback onSendOtpPressed;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<MobileNumberBloc>().state;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Color(0xFF111827),
          ),
          onPressed: onBackPressed,
        ),
        centerTitle: true,
        title: const Text(
          'Mobile Login',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xFF111827),
            fontFamily: 'Inter',
          ),
        ),
        actions: [
          Center(
            child: Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFFF4040).withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Step 1 of 2',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFFF4040),
                  fontFamily: 'Inter',
                ),
              ),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: const Color(0xFFE7E7E7),
            height: 1,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF4040).withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.phone_iphone_rounded,
                        color: Color(0xFFFF4040),
                        size: 24,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Enter your mobile number',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                        color: Color(0xFF111827),
                        fontFamily: 'Inter',
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'We will send a 6-digit verification code to confirm your account identity.',
                      style: TextStyle(
                        fontSize: 13.5,
                        color: Color(0xFF6B7280),
                        height: 1.5,
                        fontFamily: 'Inter',
                      ),
                    ),
                    const SizedBox(height: 28),
                    MobileNumberInputField(
                      phoneNumber: state.phoneNumber,
                      countryCode: state.countryCode,
                      onPhoneNumberChanged: (val) {
                        context.read<MobileNumberBloc>().add(
                              MobileNumberPhoneNumberChanged(val),
                            );
                      },
                      onCountryCodeChanged: (code) {
                        context.read<MobileNumberBloc>().add(
                              MobileNumberCountryCodeChanged(code),
                            );
                      },
                    ),
                    const SizedBox(height: 20),
                    const SecurityNoteCard(),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.only(
                left: 20,
                right: 20,
                top: 12,
                bottom: 20,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(
                    color: Color(0xFFE7E7E7),
                  ),
                ),
              ),
              child: SendOtpButton(
                onPressed: () {
                  context.read<MobileNumberBloc>().add(
                        const MobileNumberSubmitted(),
                      );
                  onSendOtpPressed();
                },
                isEnabled: state.isValid,
                isLoading: state.status == MobileNumberStatus.submitting,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
