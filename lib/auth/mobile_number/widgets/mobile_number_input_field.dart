import 'package:evently_vendor/auth/mobile_number/widgets/country_code_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MobileNumberInputField extends StatelessWidget {
  const MobileNumberInputField({
    required this.phoneNumber,
    required this.countryCode,
    required this.onPhoneNumberChanged,
    required this.onCountryCodeChanged,
    super.key,
  });

  final String phoneNumber;
  final String countryCode;
  final ValueChanged<String> onPhoneNumberChanged;
  final ValueChanged<String> onCountryCodeChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Mobile Number',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: Color(0xFF111827),
            fontFamily: 'Inter',
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 52,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: const Color(0xFFE7E7E7),
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              CountryCodeSelector(
                selectedCode: countryCode,
                onChanged: onCountryCodeChanged,
              ),
              Container(
                width: 1,
                height: 28,
                color: const Color(0xFFE7E7E7),
              ),
              Expanded(
                child: TextField(
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(10),
                  ],
                  onChanged: onPhoneNumberChanged,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF111827),
                    letterSpacing: 0.5,
                    fontFamily: 'Inter',
                  ),
                  decoration: const InputDecoration(
                    hintText: '98765 43210',
                    hintStyle: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF9CA3AF),
                      fontFamily: 'Inter',
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 14),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
