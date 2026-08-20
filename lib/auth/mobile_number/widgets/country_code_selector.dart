import 'package:flutter/material.dart';

class CountryCodeSelector extends StatelessWidget {
  const CountryCodeSelector({
    required this.selectedCode,
    required this.onChanged,
    super.key,
  });

  final String selectedCode;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        // Dropdown options for country code (e.g. +91)
        onChanged(selectedCode);
      },
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(12),
        bottomLeft: Radius.circular(12),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '🇮🇳',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(width: 6),
            Text(
              selectedCode,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Color(0xFF111827),
                fontFamily: 'Inter',
              ),
            ),
            const SizedBox(width: 4),
            const Icon(
              Icons.keyboard_arrow_down,
              size: 18,
              color: Color(0xFF6B7280),
            ),
          ],
        ),
      ),
    );
  }
}
