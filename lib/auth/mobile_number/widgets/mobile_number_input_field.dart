import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Mobile number field with a fixed country code.
///
/// Only Indian (+91) numbers are supported until a country picker exists.
class MobileNumberInputField extends StatefulWidget {
  const MobileNumberInputField({
    required this.countryCode,
    required this.onPhoneNumberChanged,
    this.errorText,
    this.enabled = true,
    super.key,
  });

  final String countryCode;
  final ValueChanged<String> onPhoneNumberChanged;
  final String? errorText;
  final bool enabled;

  @override
  State<MobileNumberInputField> createState() => _MobileNumberInputFieldState();
}

class _MobileNumberInputFieldState extends State<MobileNumberInputField> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _clear() {
    _controller.clear();
    widget.onPhoneNumberChanged('');
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final countryCode = widget.countryCode;
    return TextField(
      controller: _controller,
      enabled: widget.enabled,
      autofocus: true,
      keyboardType: TextInputType.phone,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(10),
      ],
      onChanged: (value) {
        setState(() {});
        widget.onPhoneNumberChanged(value);
      },
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: Color(0xFF111827),
        letterSpacing: 0.5,
        fontFamily: 'Inter',
      ),
      decoration: InputDecoration(
        hintText: 'Mobile Number',
        errorText: widget.errorText,
        errorMaxLines: 3,
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
              Semantics(
                label: 'Country code $countryCode',
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
        suffixIcon: _controller.text.isNotEmpty && widget.enabled
            ? GestureDetector(
                onTap: _clear,
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
