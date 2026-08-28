import 'package:business_repository/business_repository.dart';
import 'package:evently_vendor/customers/create_customer/cubit/create_customer_cubit.dart';
import 'package:evently_vendor/customers/create_customer/cubit/create_customer_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CreateCustomerPage extends StatelessWidget {
  const CreateCustomerPage({super.key});

  static Route<void> route() {
    return MaterialPageRoute<void>(
      builder: (_) => const CreateCustomerPage(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CreateCustomerCubit(
        businessRepository: context.read<BusinessRepository>(),
      ),
      child: const CreateCustomerView(),
    );
  }
}

class CreateCustomerView extends StatelessWidget {
  const CreateCustomerView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<CreateCustomerCubit, CreateCustomerState>(
      listenWhen: (previous, current) => previous.status != current.status,
      listener: (context, state) {
        if (state.status == CreateCustomerStatus.success) {
          // Success! Pop the page.
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Customer created successfully!')),
          );
          Navigator.of(context).pop();
        } else if (state.status == CreateCustomerStatus.failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to create customer.')),
          );
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFFFFFFF),
        body: SafeArea(
          child: Column(
            children: [
              // Custom AppBar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Color(0xFFEAEAEA)),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        width: 44,
                        height: 44,
                        color: Colors.transparent,
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.arrow_back_rounded,
                          color: Color(0xFF1A1A1A),
                          size: 20,
                        ),
                      ),
                    ),
                    const Text(
                      'Create Customer',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A1A1A),
                        fontFamily: 'Inter',
                      ),
                    ),
                    const SizedBox(width: 44),
                  ],
                ),
              ),

              // Progress Bar
              Container(
                height: 3,
                width: double.infinity,
                color: const Color(0xFFF1F1F1),
                alignment: Alignment.centerLeft,
                child: FractionallySizedBox(
                  widthFactor: 0.45,
                  child: Container(
                    color: const Color(0xFFFF4040),
                  ),
                ),
              ),

              // Body
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 28, 20, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header Text
                      const Text(
                        'Add a new customer',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1A1A1A),
                          height: 1.2,
                          fontFamily: 'Inter',
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Enter the basic details below to continue creating the booking.',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF6B6B6B),
                          height: 1.5,
                          fontFamily: 'Inter',
                        ),
                      ),
                      const SizedBox(height: 28),

                      // Customer Name Field
                      _buildLabel('Customer Name', isRequired: true),
                      const SizedBox(height: 6),
                      _buildTextField(
                        hintText: 'Sarah Johnson',
                        onChanged: (val) =>
                            context.read<CreateCustomerCubit>().nameChanged(val),
                      ),
                      const SizedBox(height: 20),

                      // Mobile Number Field
                      _buildLabel('Mobile Number', isRequired: true),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Container(
                            height: 48,
                            width: 68,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFAFAFA),
                              border: Border.all(color: const Color(0xFFEAEAEA)),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Text(
                                  '+1',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF1A1A1A),
                                    fontFamily: 'Inter',
                                  ),
                                ),
                                SizedBox(width: 4),
                                Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  size: 14,
                                  color: Color(0xFF8A8A8A),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildTextField(
                              hintText: 'Enter mobile number',
                              keyboardType: TextInputType.phone,
                              onChanged: (val) => context
                                  .read<CreateCustomerCubit>()
                                  .phoneChanged(val),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Email Address Field
                      _buildLabel('Email Address', isOptional: true),
                      const SizedBox(height: 6),
                      _buildTextField(
                        hintText: 'Enter email address',
                        keyboardType: TextInputType.emailAddress,
                        onChanged: (val) =>
                            context.read<CreateCustomerCubit>().emailChanged(val),
                      ),
                      const SizedBox(height: 20),

                      // Notes Field
                      _buildLabel('Notes', isOptional: true),
                      const SizedBox(height: 6),
                      _buildTextField(
                        hintText: 'Add notes about this customer',
                        maxLines: 3,
                        height: 80,
                        onChanged: (val) =>
                            context.read<CreateCustomerCubit>().notesChanged(val),
                      ),
                      const SizedBox(height: 28),

                      // Submit Button
                      BlocBuilder<CreateCustomerCubit, CreateCustomerState>(
                        builder: (context, state) {
                          final isSubmitting =
                              state.status == CreateCustomerStatus.loading;
                          final isValid =
                              state.name.trim().isNotEmpty &&
                              state.phone.trim().isNotEmpty;

                          return GestureDetector(
                            onTap: (isValid && !isSubmitting)
                                ? () => context.read<CreateCustomerCubit>().submit()
                                : null,
                            child: Container(
                              height: 52,
                              decoration: BoxDecoration(
                                color: (isValid && !isSubmitting)
                                    ? const Color(0xFFFF4040)
                                    : const Color(0xFFFF4040).withOpacity(0.5),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0x1AFF4040),
                                    blurRadius: 10,
                                    offset: Offset(0, 4),
                                  ),
                                ],
                              ),
                              alignment: Alignment.center,
                              child: isSubmitting
                                  ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text(
                                      'Create & Continue',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFFFFFFFF),
                                        fontFamily: 'Inter',
                                      ),
                                    ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 16),

                      // Info Text
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(
                            Icons.info_outline_rounded,
                            size: 14,
                            color: Color(0xFF8A8A8A),
                          ),
                          SizedBox(width: 6),
                          Text(
                            'The customer will be saved and attached to this booking.',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w400,
                              color: Color(0xFF8A8A8A),
                              fontFamily: 'Inter',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(
    String text, {
    bool isRequired = false,
    bool isOptional = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Text(
              text,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1A1A),
                fontFamily: 'Inter',
              ),
            ),
            if (isRequired)
              const Padding(
                padding: EdgeInsets.only(left: 4),
                child: Text(
                  '*',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFFFF4040),
                    fontFamily: 'Inter',
                  ),
                ),
              ),
          ],
        ),
        if (isOptional)
          const Text(
            'Optional',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w400,
              color: Color(0xFF8A8A8A),
              fontFamily: 'Inter',
            ),
          ),
      ],
    );
  }

  Widget _buildTextField({
    required String hintText,
    required void Function(String) onChanged,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    double? height,
  }) {
    return Container(
      height: height ?? 48,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        border: Border.all(color: const Color(0xFFEAEAEA)),
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: maxLines > 1 ? Alignment.topLeft : Alignment.center,
      child: TextField(
        onChanged: onChanged,
        keyboardType: keyboardType,
        maxLines: maxLines,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: Color(0xFF1A1A1A),
          fontFamily: 'Inter',
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: Color(0xFF8A8A8A),
            fontFamily: 'Inter',
          ),
          border: InputBorder.none,
          isDense: true,
          contentPadding: maxLines > 1
              ? const EdgeInsets.only(top: 12)
              : EdgeInsets.zero,
        ),
      ),
    );
  }
}
