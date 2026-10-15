import 'package:flutter/material.dart';

/// Shown instead of the app when the build configuration is invalid.
///
/// This replaces any silent fallback to another environment: a build
/// without its `config/<environment>.json` file cannot reach a backend.
class ConfigErrorApp extends StatelessWidget {
  const ConfigErrorApp({required this.problems, super.key});

  final List<String> problems;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              const Icon(Icons.error_outline, size: 40, color: Colors.red),
              const SizedBox(height: 16),
              const Text(
                'This build is not configured',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              const Text(
                'The app was built without a valid configuration file and '
                'cannot connect to Evently.',
              ),
              const SizedBox(height: 16),
              for (final problem in problems)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text('• $problem'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
