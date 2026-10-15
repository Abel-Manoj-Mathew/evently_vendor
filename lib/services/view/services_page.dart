import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';

/// Services screen, reached from Profile. Service management is not built
/// yet; shown as unavailable rather than as an empty list.
class ServicesPage extends StatelessWidget {
  const ServicesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(title: const Text('Services')),
      body: const AppEmptyState(
        icon: Icons.work_outline_rounded,
        title: 'Service management is coming soon',
        message:
            'You will be able to add the services you offer and choose '
            'them when creating bookings.',
      ),
    );
  }
}
