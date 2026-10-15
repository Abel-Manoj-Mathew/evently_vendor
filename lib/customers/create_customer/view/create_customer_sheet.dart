import 'dart:async';

import 'package:customer_repository/customer_repository.dart';
import 'package:evently_vendor/app/bloc/app_bloc.dart';
import 'package:evently_vendor/customers/create_customer/cubit/create_customer_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Bottom sheet for adding a customer.
///
/// Resolves to the created customer, to an existing customer the user chose
/// to reuse after a duplicate warning, or to `null` when dismissed.
class CreateCustomerSheet extends StatelessWidget {
  const CreateCustomerSheet({super.key});

  static Future<Customer?> show(BuildContext context) {
    final ownerId = context.read<AppBloc>().state.user?.id;
    if (ownerId == null) return Future.value();
    final customerRepository = context.read<CustomerRepository>();
    return showModalBottomSheet<Customer>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider(
        create: (_) => CreateCustomerCubit(
          customerRepository: customerRepository,
          ownerId: ownerId,
        ),
        child: const CreateCustomerSheet(),
      ),
    );
  }

  static String _failureMessage(CreateCustomerFailure? failure) =>
      switch (failure) {
        CreateCustomerFailure.noBusiness =>
          'Set up your business before adding customers.',
        CreateCustomerFailure.phoneAlreadyUsed =>
          'Another customer already uses this phone number.',
        CreateCustomerFailure.unknown || null =>
          "Couldn't save the customer. Check your connection and try again.",
      };

  Future<void> _showDuplicateWarning(
    BuildContext context,
    CreateCustomerState state,
  ) async {
    final cubit = context.read<CreateCustomerCubit>();
    final navigator = Navigator.of(context);
    final choice = await showDialog<_DuplicateChoice>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Possible duplicate'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                state.duplicates.length == 1
                    ? 'A customer with this phone number already exists. '
                          'Use the existing customer, or create a new one if '
                          'they share a phone.'
                    : '${state.duplicates.length} customers already use this '
                          'phone number. Use one of them, or create a new '
                          'customer.',
              ),
              const SizedBox(height: 12),
              for (final customer in state.duplicates)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(child: Text(customer.initials)),
                  title: Text(customer.name),
                  subtitle: Text(customer.phone ?? ''),
                  trailing: const Text('Use'),
                  onTap: () => Navigator.of(
                    dialogContext,
                  ).pop(_DuplicateChoice.useExisting(customer)),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(
              dialogContext,
            ).pop(const _DuplicateChoice.create()),
            child: const Text('Create new customer'),
          ),
        ],
      ),
    );
    switch (choice) {
      case _DuplicateChoice(:final existing?):
        navigator.pop(existing);
      case _DuplicateChoice():
        await cubit.createAnyway();
      case null:
        cubit.dismissDuplicateWarning();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return BlocListener<CreateCustomerCubit, CreateCustomerState>(
      listenWhen: (previous, current) => previous.status != current.status,
      listener: (context, state) {
        switch (state.status) {
          case CreateCustomerStatus.success:
            Navigator.of(context).pop(state.createdCustomer);
          case CreateCustomerStatus.duplicateWarning:
            unawaited(_showDuplicateWarning(context, state));
          case CreateCustomerStatus.failure:
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(_failureMessage(state.failure)),
                backgroundColor: const Color(0xFFEF4444),
              ),
            );
          case CreateCustomerStatus.editing:
          case CreateCustomerStatus.saving:
            break;
        }
      },
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 20,
          bottom: 24 + bottomInset,
        ),
        child: const SingleChildScrollView(child: _CustomerForm()),
      ),
    );
  }
}

class _DuplicateChoice {
  const _DuplicateChoice.create() : existing = null;
  const _DuplicateChoice.useExisting(Customer this.existing);

  final Customer? existing;
}

class _CustomerForm extends StatelessWidget {
  const _CustomerForm();

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<CreateCustomerCubit>();
    final state = context.watch<CreateCustomerCubit>().state;
    String? errorIf(String? error) => state.showValidation ? error : null;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFE5E7EB),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            const Expanded(
              child: Text(
                'Add New Customer',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF111827),
                  fontFamily: 'Inter',
                ),
              ),
            ),
            IconButton(
              tooltip: 'Close',
              onPressed: state.isBusy
                  ? null
                  : () => Navigator.of(context).pop(),
              icon: const Icon(Icons.close, color: Color(0xFF6B7280)),
            ),
          ],
        ),
        const SizedBox(height: 20),
        _LabeledField(
          label: 'Full Name *',
          hint: 'e.g. Anu Thomas',
          icon: Icons.person_outline,
          enabled: !state.isBusy,
          errorText: errorIf(state.nameError),
          textCapitalization: TextCapitalization.words,
          onChanged: cubit.nameChanged,
        ),
        _LabeledField(
          label: 'Phone Number (Optional)',
          hint: 'e.g. 98765 43210',
          icon: Icons.phone_outlined,
          enabled: !state.isBusy,
          errorText: errorIf(state.phoneError),
          keyboardType: TextInputType.phone,
          onChanged: cubit.phoneChanged,
        ),
        _LabeledField(
          label: 'Email Address (Optional)',
          hint: 'e.g. anu@example.com',
          icon: Icons.mail_outline,
          enabled: !state.isBusy,
          errorText: errorIf(state.emailError),
          keyboardType: TextInputType.emailAddress,
          onChanged: cubit.emailChanged,
        ),
        _LabeledField(
          label: 'Notes (Optional)',
          hint: 'Add special preferences or notes...',
          icon: Icons.notes_outlined,
          enabled: !state.isBusy,
          maxLines: 2,
          onChanged: cubit.notesChanged,
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: state.isBusy ? null : () => unawaited(cubit.submit()),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF4040),
              foregroundColor: Colors.white,
              disabledBackgroundColor: const Color(
                0xFFFF4040,
              ).withValues(alpha: 0.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: state.isBusy
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text(
                    'Save Customer',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Inter',
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}

class _LabeledField extends StatelessWidget {
  const _LabeledField({
    required this.label,
    required this.hint,
    required this.icon,
    required this.onChanged,
    required this.enabled,
    this.errorText,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.none,
    this.maxLines = 1,
  });

  final String label;
  final String hint;
  final IconData icon;
  final ValueChanged<String> onChanged;
  final bool enabled;
  final String? errorText;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    OutlineInputBorder border(Color color) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: color),
    );
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF374151),
              fontFamily: 'Inter',
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            enabled: enabled,
            onChanged: onChanged,
            keyboardType: keyboardType,
            textCapitalization: textCapitalization,
            maxLines: maxLines,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF111827),
              fontFamily: 'Inter',
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(
                color: Color(0xFF9CA3AF),
                fontSize: 14,
              ),
              errorText: errorText,
              prefixIcon: Icon(icon, size: 20),
              filled: true,
              fillColor: const Color(0xFFF9FAFB),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              border: border(const Color(0xFFE5E7EB)),
              enabledBorder: border(const Color(0xFFE5E7EB)),
              focusedBorder: border(const Color(0xFFFF4040)),
            ),
          ),
        ],
      ),
    );
  }
}
