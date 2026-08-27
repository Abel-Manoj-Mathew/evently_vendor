import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  static Route<void> route() {
    return MaterialPageRoute<void>(
      builder: (_) => const HomePage(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      appBar: AppBar(
        title: const Text('Evently Vendor Home'),
        backgroundColor: const Color(0xFFFFFFFF),
        elevation: 0,
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'Welcome to Evently Vendor!',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Color(0xFF111827),
            fontFamily: 'Inter',
          ),
        ),
      ),
    );
  }
}
