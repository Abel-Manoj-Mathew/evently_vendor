import 'package:flutter/material.dart';

class SecurityNoteCard extends StatelessWidget {
  const SecurityNoteCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFE7E7E7),
        ),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.lock_outline,
            size: 18,
            color: Color(0xFF6B7280),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Your mobile number is safe with us. We use it solely to verify your identity and manage your vendor business account.',
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF6B7280),
                height: 1.45,
                fontFamily: 'Inter',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
