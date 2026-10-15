import 'dart:async';

import 'package:authentication_client/authentication_client.dart';
import 'package:evently_vendor/auth/otp/cubit/otp_cubit.dart';
import 'package:evently_vendor/auth/otp/widgets/otp_input_field.dart';
import 'package:evently_vendor/auth/shared/auth_failure_message.dart';
import 'package:evently_vendor/auth/shared/phone_number.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class OtpPage extends StatelessWidget {
  const OtpPage({required this.phoneNumber, super.key});

  /// E.164 number the code was sent to.
  final String phoneNumber;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => OtpCubit(
        phoneNumber: phoneNumber,
        authenticationClient: context.read<AuthenticationClient>(),
      ),
      child: const OtpView(),
    );
  }
}

class OtpView extends StatefulWidget {
  const OtpView({super.key});

  /// Seconds before the user may request another code.
  static const resendCooldown = 30;

  @override
  State<OtpView> createState() => _OtpViewState();
}

class _OtpViewState extends State<OtpView> {
  final _codeController = TextEditingController();
  int _secondsRemaining = OtpView.resendCooldown;
  Timer? _timer;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _secondsRemaining = OtpView.resendCooldown);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 1) {
        setState(() => _secondsRemaining--);
      } else {
        setState(() => _secondsRemaining = 0);
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _codeController.dispose();
    super.dispose();
  }

  void _onStateChanged(BuildContext context, OtpState state) {
    final messenger = ScaffoldMessenger.of(context)..hideCurrentSnackBar();
    final failureMessage =
        (state.failureReason ?? AuthFailureReason.unknown).message;
    switch (state.status) {
      case OtpStatus.verificationFailed:
        _codeController.clear();
        setState(() => _errorText = failureMessage);
      case OtpStatus.resent:
        _codeController.clear();
        setState(() => _errorText = null);
        _startTimer();
        messenger.showSnackBar(
          const SnackBar(
            content: Text('A new code has been sent.'),
            backgroundColor: Color(0xFF10B981),
          ),
        );
      case OtpStatus.resendFailed:
        messenger.showSnackBar(
          SnackBar(
            content: Text(failureMessage),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
      case OtpStatus.initial:
      case OtpStatus.verifying:
      case OtpStatus.verified:
      case OtpStatus.resending:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<OtpCubit, OtpState>(
      listenWhen: (previous, current) =>
          previous.status != current.status ||
          previous.attempt != current.attempt,
      listener: _onStateChanged,
      builder: (context, state) {
        return Scaffold(
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
                      onPressed: state.isBusy ? null : () => context.pop(),
                      icon: const Icon(
                        Icons.arrow_back,
                        size: 20,
                        color: Color(0xFF111827),
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(top: 24),
                    child: Text(
                      'Verify your number',
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
                    padding: EdgeInsets.only(top: 8),
                    child: Text(
                      'Enter the 6-digit verification code sent to '
                      'your mobile number.',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        height: 1.6,
                        color: Color(0xFF6B7280),
                        fontFamily: 'Inter',
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 24),
                    child: _SentTo(
                      phoneNumber: state.phoneNumber,
                      enabled: !state.isBusy,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 36),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        OtpInputField(
                          length: OtpCubit.codeLength,
                          controller: _codeController,
                          enabled: !state.isBusy,
                          hasError: _errorText != null,
                          onChanged: (_) {
                            if (_errorText != null) {
                              setState(() => _errorText = null);
                            }
                          },
                          onCompleted: (code) =>
                              unawaited(context.read<OtpCubit>().verify(code)),
                        ),
                        if (state.status == OtpStatus.verifying ||
                            state.status == OtpStatus.verified)
                          const Positioned.fill(
                            child: ColoredBox(
                              color: Colors.white70,
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: Color(0xFFFF4040),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (_errorText != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Text(
                        _errorText!,
                        key: const Key('otp_error_text'),
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFFEF4444),
                          height: 1.4,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.only(top: 40, bottom: 24),
                    child: Center(
                      child: _ResendSection(
                        secondsRemaining: _secondsRemaining,
                        isResending: state.status == OtpStatus.resending,
                        enabled: !state.isBusy,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SentTo extends StatelessWidget {
  const _SentTo({required this.phoneNumber, required this.enabled});

  final String phoneNumber;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'SENT TO',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF9CA3AF),
            letterSpacing: 0.6,
            fontFamily: 'Inter',
          ),
        ),
        const SizedBox(height: 8),
        Text(
          PhoneNumber.display(phoneNumber),
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: Color(0xFF111827),
            fontFamily: 'Inter',
          ),
        ),
        TextButton(
          onPressed: enabled ? () => context.pop() : null,
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            foregroundColor: const Color(0xFFFF4040),
          ),
          child: const Text(
            'Change Number',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              decoration: TextDecoration.underline,
              decorationColor: Color(0xFFFF4040),
              fontFamily: 'Inter',
            ),
          ),
        ),
      ],
    );
  }
}

class _ResendSection extends StatelessWidget {
  const _ResendSection({
    required this.secondsRemaining,
    required this.isResending,
    required this.enabled,
  });

  final int secondsRemaining;
  final bool isResending;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final minutes = (secondsRemaining ~/ 60).toString().padLeft(2, '0');
    final seconds = (secondsRemaining % 60).toString().padLeft(2, '0');
    return Column(
      children: [
        if (secondsRemaining > 0) ...[
          const Text(
            'RESEND AVAILABLE IN',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF9CA3AF),
              letterSpacing: 0.6,
              fontFamily: 'Inter',
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$minutes:$seconds',
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w700,
              color: Color(0xFF111827),
              letterSpacing: 0.64,
              height: 1,
              fontFamily: 'Inter',
            ),
          ),
        ] else if (isResending)
          const SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
              color: Color(0xFFFF4040),
              strokeWidth: 2,
            ),
          )
        else
          TextButton(
            onPressed: enabled
                ? () => unawaited(context.read<OtpCubit>().resend())
                : null,
            child: const Text(
              'Resend OTP',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Color(0xFFFF4040),
                fontFamily: 'Inter',
              ),
            ),
          ),
        const SizedBox(height: 12),
        const SizedBox(
          width: 280,
          child: Text(
            'Verification starts automatically after entering all 6 digits.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: Color(0xFF6B7280),
              height: 1.5,
              fontFamily: 'Inter',
            ),
          ),
        ),
      ],
    );
  }
}
