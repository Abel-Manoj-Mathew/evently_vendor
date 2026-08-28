import 'dart:async';

import 'package:evently_vendor/onboarding/business_details/business_details.dart';
import 'package:evently_vendor/onboarding/user_information/cubit/user_information_cubit.dart';
import 'package:evently_vendor/onboarding/user_information/cubit/user_information_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserInformationView extends StatefulWidget {
  const UserInformationView({super.key});

  @override
  State<UserInformationView> createState() => _UserInformationViewState();
}

class _UserInformationViewState extends State<UserInformationView> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();

  final FocusNode _firstNameFocus = FocusNode();
  final FocusNode _lastNameFocus = FocusNode();

  bool _isFirstNameFocused = true;
  bool _isLastNameFocused = false;

  @override
  void initState() {
    super.initState();
    _firstNameFocus.addListener(() {
      setState(() {
        _isFirstNameFocused = _firstNameFocus.hasFocus;
      });
    });
    _lastNameFocus.addListener(() {
      setState(() {
        _isLastNameFocused = _lastNameFocus.hasFocus;
      });
    });
    _firstNameController.addListener(() {
      setState(() {});
    });

    // Auto-focus First Name field on page load to match focused wireframe
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _firstNameFocus.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _firstNameFocus.dispose();
    _lastNameFocus.dispose();
    super.dispose();
  }

  bool get _isFormValid => _firstNameController.text.trim().isNotEmpty;

  void _onContinuePressed() {
    if (!_isFormValid) return;

    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();

    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      unawaited(
        context.read<UserInformationCubit>().updateProfile(
          id: user.id,
          firstName: firstName,
          lastName: lastName,
          phone: user.phone ?? '',
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<UserInformationCubit, UserInformationState>(
      listener: (context, state) {
        if (state.status == UserInformationStatus.success) {
          unawaited(
            Navigator.of(context).push(
              BusinessDetailsPage.route(),
            ),
          );
        } else if (state.status == UserInformationStatus.failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to update profile. Please try again.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state.status == UserInformationStatus.loading;
        return Scaffold(
          backgroundColor: const Color(0xFFFFFFFF),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(
                left: 20,
                right: 20,
                bottom: 64,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Bar / Back button
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        width: 40,
                        height: 40,
                        color: Colors.transparent,
                        alignment: Alignment.centerLeft,
                        child: const Icon(
                          Icons.arrow_back,
                          size: 20,
                          color: Color(0xFF111827),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Title and Subtitle
                  const Text(
                    'Tell us about yourself',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF111827),
                      height: 1.3,
                      fontFamily: 'Inter',
                    ),
                  ),
                  const SizedBox(height: 8),
                  const SizedBox(
                    width: 300,
                    child: Text(
                      "We'll use your name to personalize your workspace.",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF6B7280),
                        height: 1.6,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Form Fields Container
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // First Name Field
                      RichText(
                        text: const TextSpan(
                          text: 'First Name',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF111827),
                            fontFamily: 'Inter',
                          ),
                          children: [
                            TextSpan(
                              text: '*',
                              style: TextStyle(
                                color: Color(0xFFFF4040),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        height: 52,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFFFFF),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: _isFirstNameFocused
                                ? const Color(0xFFFF4040)
                                : const Color(0xFFE5E7EB),
                            width: _isFirstNameFocused ? 2 : 1,
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        alignment: Alignment.center,
                        child: TextField(
                          controller: _firstNameController,
                          focusNode: _firstNameFocus,
                          textCapitalization: TextCapitalization.words,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF111827),
                            fontFamily: 'Inter',
                          ),
                          decoration: const InputDecoration(
                            hintText: 'First name',
                            hintStyle: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w400,
                              color: Color(0xFF9CA3AF),
                              fontFamily: 'Inter',
                            ),
                            filled: false,
                            fillColor: Colors.transparent,
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            disabledBorder: InputBorder.none,
                            errorBorder: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                            isDense: true,
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Last Name Field
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Last Name',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF111827),
                              fontFamily: 'Inter',
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Optional',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              color: Color(0xFF9CA3AF),
                              fontFamily: 'Inter',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        height: 52,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFFFFF),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: _isLastNameFocused
                                ? const Color(0xFFFF4040)
                                : const Color(0xFFE5E7EB),
                            width: _isLastNameFocused ? 2 : 1,
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        alignment: Alignment.center,
                        child: TextField(
                          controller: _lastNameController,
                          focusNode: _lastNameFocus,
                          textCapitalization: TextCapitalization.words,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF111827),
                            fontFamily: 'Inter',
                          ),
                          decoration: const InputDecoration(
                            hintText: 'Last name',
                            hintStyle: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w400,
                              color: Color(0xFF9CA3AF),
                              fontFamily: 'Inter',
                            ),
                            filled: false,
                            fillColor: Colors.transparent,
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            disabledBorder: InputBorder.none,
                            errorBorder: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                            isDense: true,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const Spacer(),

                  // Continue Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 200),
                      opacity: _isFormValid ? 1.0 : 0.5,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _onContinuePressed,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF4040),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          padding: EdgeInsets.zero,
                        ),
                        child: isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.5,
                                ),
                              )
                            : const Text(
                                'Continue',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'Inter',
                                ),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
