import 'dart:async';

import 'package:evently_vendor/home/home.dart';
import 'package:evently_vendor/onboarding/business_details/cubit/business_details_cubit.dart';
import 'package:evently_vendor/onboarding/business_details/cubit/business_details_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BusinessDetailsView extends StatefulWidget {
  const BusinessDetailsView({super.key});

  @override
  State<BusinessDetailsView> createState() => _BusinessDetailsViewState();
}

class _BusinessDetailsViewState extends State<BusinessDetailsView> {
  final TextEditingController _businessNameController = TextEditingController();
  final FocusNode _businessNameFocus = FocusNode();

  bool _isBusinessNameFocused = false;
  bool _showAllCategories = false;
  final Set<String> _selectedCategories = {'Photographer'};

  @override
  void initState() {
    super.initState();
    _businessNameFocus.addListener(() {
      setState(() {
        _isBusinessNameFocused = _businessNameFocus.hasFocus;
      });
    });
    _businessNameController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _businessNameController.dispose();
    _businessNameFocus.dispose();
    super.dispose();
  }

  bool get _isFormValid =>
      _businessNameController.text.trim().isNotEmpty &&
      _selectedCategories.isNotEmpty;

  void _toggleCategory(String category) {
    setState(() {
      if (_selectedCategories.contains(category)) {
        _selectedCategories.remove(category);
      } else {
        _selectedCategories.add(category);
      }
    });
  }

  void _removeCategory(String category) {
    setState(() {
      _selectedCategories.remove(category);
    });
  }

  void _onCreateBusinessPressed() {
    if (!_isFormValid) return;

    final businessName = _businessNameController.text.trim();
    final categories = _selectedCategories.toList();

    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      unawaited(
        context.read<BusinessDetailsCubit>().createBusiness(
          ownerId: user.id,
          businessName: businessName,
          categories: categories,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<BusinessDetailsCubit, BusinessDetailsState>(
      listener: (context, state) {
        if (state.status == BusinessDetailsStatus.success) {
          unawaited(
            Navigator.of(context).pushAndRemoveUntil(
              HomePage.route(),
              (route) => false,
            ),
          );
        } else if (state.status == BusinessDetailsStatus.failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to create business. Please try again.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state.status == BusinessDetailsStatus.loading;
        final isLoadingCategories =
            state.status == BusinessDetailsStatus.loadingCategories;

        final categoriesToDisplay = _showAllCategories
            ? state.categories
            : state.categories.take(6).toList();

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
                    'What business do you manage?',
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
                    width: 310,
                    child: Text(
                      "This is the business you'll manage in Evently. "
                      'You can update these details anytime.',
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

                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Business Name Input
                          const Text(
                            'What should we call your business?',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF111827),
                              fontFamily: 'Inter',
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
                                color: _isBusinessNameFocused
                                    ? const Color(0xFFFF4040)
                                    : const Color(0xFFE5E7EB),
                                width: _isBusinessNameFocused ? 2 : 1,
                              ),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            alignment: Alignment.center,
                            child: TextField(
                              controller: _businessNameController,
                              focusNode: _businessNameFocus,
                              textCapitalization: TextCapitalization.words,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w400,
                                color: Color(0xFF111827),
                                fontFamily: 'Inter',
                              ),
                              decoration: const InputDecoration(
                                hintText: 'e.g. Abel Photography',
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

                          const SizedBox(height: 32),

                          // Selected Chips Section
                          if (_selectedCategories.isNotEmpty) ...[
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'SELECTED',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF111827),
                                    letterSpacing: 0.65,
                                    fontFamily: 'Inter',
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: _selectedCategories.map((cat) {
                                    return Container(
                                      height: 32,
                                      padding: const EdgeInsets.only(
                                        left: 12,
                                        right: 10,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFF4040),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            cat,
                                            style: const TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                              color: Color(0xFFFFFFFF),
                                              fontFamily: 'Inter',
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          GestureDetector(
                                            onTap: () => _removeCategory(cat),
                                            child: const Text(
                                              '×',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                                color: Color(0xFFFFFFFF),
                                                height: 1,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                ),
                                const SizedBox(height: 16),
                                const Divider(
                                  height: 1,
                                  thickness: 1,
                                  color: Color(0xFFE5E7EB),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                          ],

                          // Choose Categories Section
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'CHOOSE CATEGORIES',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF111827),
                                  letterSpacing: 0.65,
                                  fontFamily: 'Inter',
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'You can select multiple categories.',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                  color: Color(0xFF9CA3AF),
                                  fontFamily: 'Inter',
                                ),
                              ),
                              const SizedBox(height: 12),
                              if (isLoadingCategories)
                                const Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(16),
                                    child: CircularProgressIndicator(
                                      color: Color(0xFFFF4040),
                                    ),
                                  ),
                                )
                              else if (categoriesToDisplay.isEmpty)
                                const Padding(
                                  padding: EdgeInsets.all(16),
                                  child: Text(
                                    'No categories available.',
                                    style: TextStyle(
                                      color: Color(0xFF6B7280),
                                      fontSize: 14,
                                    ),
                                  ),
                                )
                              else
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: categoriesToDisplay.map((cat) {
                                    final isSelected = _selectedCategories
                                        .contains(cat);
                                    return GestureDetector(
                                      onTap: () => _toggleCategory(cat),
                                      child: AnimatedContainer(
                                        duration: const Duration(
                                          milliseconds: 200,
                                        ),
                                        height: 36,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 14,
                                        ),
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? const Color(0xFFFF4040)
                                              : const Color(0xFFFFFFFF),
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                          border: isSelected
                                              ? null
                                              : Border.all(
                                                  color: const Color(
                                                    0xFFE5E7EB,
                                                  ),
                                                ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              cat,
                                              style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w600,
                                                color: isSelected
                                                    ? const Color(0xFFFFFFFF)
                                                    : const Color(0xFF111827),
                                                fontFamily: 'Inter',
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              const SizedBox(height: 12),
                              if (!isLoadingCategories &&
                                  state.categories.isNotEmpty &&
                                  state.categories.length > 6)
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _showAllCategories = !_showAllCategories;
                                    });
                                  },
                                  child: Text(
                                    _showAllCategories
                                        ? '- Show Fewer Categories'
                                        : '+ View All Categories',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFFFF4040),
                                      fontFamily: 'Inter',
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Helper Footer Text
                  const Center(
                    child: Text(
                      'Business details can be changed later.',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF9CA3AF),
                        fontFamily: 'Inter',
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Create Business Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 200),
                      opacity: _isFormValid ? 1.0 : 0.5,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: _isFormValid
                              ? const [
                                  BoxShadow(
                                    color: Color(0x1AFF4040),
                                    blurRadius: 12,
                                    offset: Offset(0, 4),
                                  ),
                                ]
                              : null,
                        ),
                        child: ElevatedButton(
                          onPressed: isLoading
                              ? null
                              : _onCreateBusinessPressed,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFF4040),
                            foregroundColor: const Color(0xFFFFFFFF),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 0,
                          ),
                          child: isLoading
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    color: Color(0xFFFFFFFF),
                                    strokeWidth: 2.5,
                                  ),
                                )
                              : const Text(
                                  'Create Business',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: 'Inter',
                                  ),
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
