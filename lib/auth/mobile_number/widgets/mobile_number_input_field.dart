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
    return TextField(
      keyboardType: TextInputType.phone,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(10),
      ],
      onChanged: onPhoneNumberChanged,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: Color(0xFF111827),
        letterSpacing: 0.5,
        fontFamily: 'Inter',
      ),
      decoration: InputDecoration(
        hintText: 'Mobile Number',
        hintStyle: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w400,
          color: Color(0xFF9CA3AF),
          letterSpacing: 0,
          fontFamily: 'Inter',
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 18),
        // Use prefixIcon to put the country code inside the main text field
        prefixIcon: IntrinsicHeight(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              GestureDetector(
                onTap: () {
                  // TODO(developer): Implement country picker
                },
                child: Container(
                  color: Colors.transparent,
                  padding: const EdgeInsets.only(left: 16, right: 12),
                  child: Row(
                    children: [
                      Text(
                        countryCode.isEmpty ? '+91' : countryCode,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF111827),
                          fontFamily: 'Inter',
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 20,
                        color: Color(0xFF9CA3AF),
                      ),
                    ],
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: VerticalDivider(
                  width: 1,
                  thickness: 1.5,
                  color: Color(0xFFE5E7EB),
                ),
              ),
              const SizedBox(width: 16),
            ],
          ),
        ),
        // Use suffixIcon to clear text when there is input
        suffixIconConstraints: const BoxConstraints(
          maxHeight: 40,
          maxWidth: 40,
        ),
        suffixIcon: phoneNumber.isNotEmpty
            ? GestureDetector(
                onTap: () => onPhoneNumberChanged(''),
                child: Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Color(0xFFE5E7EB),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close_rounded,
                      size: 16,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ),
              )
            : null,
      ),
    );
  }
}
