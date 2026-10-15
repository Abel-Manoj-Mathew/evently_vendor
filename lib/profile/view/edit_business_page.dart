import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';

/// Editing business details is not available yet.
///
/// The previous form showed hard-coded categories and its Save button did
/// not persist anything, so it is replaced by an honest notice until
/// organization management is built on the new schema.
class EditBusinessPage extends StatelessWidget {
  const EditBusinessPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(title: const Text('Edit Business')),
      body: const AppEmptyState(
        icon: Icons.edit_note_outlined,
        title: 'Editing is coming soon',
        message:
            "You'll be able to update your business name, categories, "
            'location and contact details here. Your current details are '
            'shown on your profile.',
      ),
    );
  }
}
