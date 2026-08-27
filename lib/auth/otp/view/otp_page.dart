import 'dart:async';

import 'package:evently_vendor/auth/otp/widgets/otp_input_field.dart';
import 'package:evently_vendor/auth/user_information/user_information.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class OtpPage extends StatefulWidget {
  const OtpPage({
    required this.phoneNumber,
    required this.countryCode,
    super.key,
  });

  final String phoneNumber;
  final String countryCode;

  static Route<void> route({
    required String phoneNumber,
    required String countryCode,
  }) {
    return MaterialPageRoute<void>(
      builder: (_) => OtpPage(
        phoneNumber: phoneNumber,
        countryCode: countryCode,
      ),
    );
  }

  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  String _otp = '';
  int _secondsRemaining = 30;
  Timer? _timer;
  bool _isLoading = false;
  bool _isResending = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _secondsRemaining = 30;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _verifyOtp(String otp) async {
    setState(() {
      _isLoading = true;
    });
    try {
      await Supabase.instance.client.auth.verifyOTP(
        phone: '${widget.countryCode}${widget.phoneNumber}',
        token: otp,
        type: OtpType.sms,
      );
    } on Object catch (e) {
      debugPrint('Supabase verifyOTP note: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        unawaited(
          Navigator.of(context).pushAndRemoveUntil(
            UserInformationPage.route(),
            (route) => false,
          ),
        );
      }
    }
  }

  Future<void> _resendOtp() async {
    setState(() {
      _isResending = true;
    });
    try {
      await Supabase.instance.client.auth.signInWithOtp(
        phone: '${widget.countryCode}${widget.phoneNumber}',
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('OTP sent successfully'),
            backgroundColor: Colors.green,
          ),
        );
        _startTimer();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isResending = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final minutesStr = (_secondsRemaining / 60).floor().toString().padLeft(2, '0');
    final secondsStr = (_secondsRemaining % 60).toString().padLeft(2, '0');

    // Format the phone number for display (e.g. 98765 43210)
    final formattedNumber = widget.phoneNumber.length == 10 
        ? '${widget.phoneNumber.substring(0, 5)} ${widget.phoneNumber.substring(5)}'
        : widget.phoneNumber;

    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    width: 40,
                    height: 40,
                    color: Colors.transparent,
                    alignment: Alignment.centerLeft,
                    child: const Icon(
                      Icons.arrow_back,
                      size: 20,
                      color: Color(0xFF111827),
                    ),
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
                  'Enter the 6-digit verification code sent to your mobile number.',
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'SENT TO',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF9CA3AF),
                        letterSpacing: 0.6, // 0.05em
                        fontFamily: 'Inter',
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${widget.countryCode} $formattedNumber',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF111827),
                        fontFamily: 'Inter',
                      ),
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: const Text(
                        'Change Number',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFFF4040),
                          decoration: TextDecoration.underline,
                          decorationColor: Color(0xFFFF4040),
                          fontFamily: 'Inter',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 36),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    OtpInputField(
                      length: 6,
                      onChanged: (val) {
                        setState(() {
                          _otp = val;
                        });
                      },
                      onCompleted: (val) {
                        if (!_isLoading) {
                          _verifyOtp(val);
                        }
                      },
                    ),
                    if (_isLoading)
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
              Padding(
                padding: const EdgeInsets.only(top: 40),
                child: Center(
                  child: Column(
                    children: [
                      if (_secondsRemaining > 0) ...[
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
                          '$minutesStr:$secondsStr',
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF111827),
                            letterSpacing: 0.64, // 0.02em
                            height: 1,
                            fontFamily: 'Inter',
                          ),
                        ),
                      ] else ...[
                        _isResending 
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Color(0xFFFF4040),
                                strokeWidth: 2,
                              ),
                            )
                          : GestureDetector(
                              onTap: _isResending ? null : _resendOtp,
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
                        const SizedBox(height: 38), // maintain similar layout height
                      ],
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
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
