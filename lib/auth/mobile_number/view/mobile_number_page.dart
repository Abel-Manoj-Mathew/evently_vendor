import 'dart:async';

import 'package:evently_vendor/auth/mobile_number/widgets/mobile_number_input_field.dart';
import 'package:evently_vendor/auth/otp/otp.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MobileNumberPage extends StatefulWidget {
  const MobileNumberPage({super.key});

  static Route<void> route() {
    return MaterialPageRoute<void>(
      builder: (_) => const MobileNumberPage(),
    );
  }

  @override
  State<MobileNumberPage> createState() => _MobileNumberPageState();
}

class _MobileNumberPageState extends State<MobileNumberPage> {
  String _phoneNumber = '';
  String _countryCode = '+91';
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 16, bottom: 12),
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
              Padding(
                padding: const EdgeInsets.only(top: 32),
                child: MobileNumberInputField(
                  phoneNumber: _phoneNumber,
                  countryCode: _countryCode,
                  onPhoneNumberChanged: (val) {
                    setState(() {
                      _phoneNumber = val;
                    });
                  },
                  onCountryCodeChanged: (code) {
                    setState(() {
                      _countryCode = code;
                    });
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 24),
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _phoneNumber.length >= 10 && !_isLoading
                        ? () async {
                            setState(() {
                              _isLoading = true;
                            });
                            try {
                              await Supabase.instance.client.auth.signInWithOtp(
                                phone: '$_countryCode$_phoneNumber',
                              );
                            } on Object catch (e) {
                              debugPrint('Supabase signInWithOtp note: $e');
                            } finally {
                              if (context.mounted) {
                                setState(() {
                                  _isLoading = false;
                                });
                                unawaited(
                                  Navigator.of(context).push(
                                    OtpPage.route(
                                      phoneNumber: _phoneNumber,
                                      countryCode: _countryCode,
                                    ),
                                  ),
                                );
                              }
                            }
                          }
                        : null,
                    style:
                        ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF4040),
                          disabledBackgroundColor: const Color(
                            0xFFFF4040,
                          ).withValues(alpha: 0.5),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                          shadowColor: const Color(
                            0xFFFF4040,
                          ).withValues(alpha: 0.1),
                        ).copyWith(
                          elevation: WidgetStateProperty.resolveWith<double>(
                            (states) {
                              if (states.contains(WidgetState.disabled)) {
                                return 0;
                              }
                              return 4;
                            },
                          ),
                        ),
                    child: _isLoading
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
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(top: 16),
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
    );
  }
}
