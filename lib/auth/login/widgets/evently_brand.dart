import 'package:flutter/material.dart';

class EventlyBrand extends StatelessWidget {
  const EventlyBrand({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: const Color(0x14FF4040),
            borderRadius: BorderRadius.circular(14),
          ),
          alignment: Alignment.center,
          child: const Icon(
            Icons.electric_bolt_outlined,
            size: 28,
            color: Color(0xFFFF4040),
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'E V E N T L Y',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            letterSpacing: 2.4,
            color: Color(0xFF111827),
            fontFamily: 'Inter',
          ),
        ),
      ],
    );
  }
}
