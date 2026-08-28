import 'package:flutter/material.dart';

class EditBusinessPage extends StatefulWidget {
  const EditBusinessPage({super.key});

  static Route<void> route() {
    return MaterialPageRoute<void>(
      builder: (_) => const EditBusinessPage(),
    );
  }

  @override
  State<EditBusinessPage> createState() => _EditBusinessPageState();
}

class _EditBusinessPageState extends State<EditBusinessPage> {
  final List<String> _selectedCategories = [
    'Photography',
    'Videography',
    'Decoration'
  ];

  final List<String> _availableCategories = [
    'Photography',
    'Videography',
    'Decoration',
    'Catering',
    'DJ & Music',
    'Makeup & Beauty',
    'Event Planning',
    'Rentals',
    'Florist',
    'Other'
  ];

  bool _isShowingCategoriesList = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFFFFF),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF111827)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Edit Business',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xFF111827),
            fontFamily: 'Inter',
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: const Color(0xFFE7E7E7),
            height: 1,
          ),
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.only(
                top: 28,
                left: 16,
                right: 16,
                bottom: 100, // Space for bottom button
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo Section
                  Column(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFAFAFA),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFE7E7E7)),
                        ),
                        alignment: Alignment.center,
                        child: const Text(
                          'ABC',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF111827),
                            fontFamily: 'Inter',
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      OutlinedButton.icon(
                        onPressed: () {},
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFFFF4040),
                          side: const BorderSide(color: Color(0xFFFF4040)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          minimumSize: const Size(0, 32),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                        ),
                        icon: const Icon(Icons.upload_outlined, size: 13),
                        label: const Text(
                          'Change Logo',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Inter',
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Business Name
                  const Text(
                    'Business Name *',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF111827),
                      fontFamily: 'Inter',
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    height: 46,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFFFFF),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE7E7E7)),
                    ),
                    alignment: Alignment.centerLeft,
                    child: const Text(
                      'ABC Events',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF111827),
                        fontFamily: 'Inter',
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Business Categories
                  const Text(
                    'Business Categories *',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF111827),
                      fontFamily: 'Inter',
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Select all categories that your business offers.',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF6B7280),
                      fontFamily: 'Inter',
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  // Selected Categories Chips
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _selectedCategories.map((category) {
                      return Container(
                        height: 32,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          color: const Color(0x14FF4040), // 8% opacity
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFFF4040)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              category,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF111827),
                                fontFamily: 'Inter',
                              ),
                            ),
                            const SizedBox(width: 6),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedCategories.remove(category);
                                });
                              },
                              child: const Icon(
                                Icons.close,
                                size: 14,
                                color: Color(0xFF111827),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 8),

                  // Add Category Button
                  OutlinedButton.icon(
                    onPressed: () {
                      setState(() {
                        _isShowingCategoriesList = !_isShowingCategoriesList;
                      });
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF111827),
                      side: const BorderSide(color: Color(0xFFE7E7E7)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      minimumSize: const Size(double.infinity, 40),
                    ),
                    icon: Icon(
                      _isShowingCategoriesList ? Icons.keyboard_arrow_up : Icons.add,
                      size: 16,
                    ),
                    label: const Text(
                      'Add Category',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ),

                  // Category List (Expandable)
                  if (_isShowingCategoriesList) ...[
                    const SizedBox(height: 4),
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFFFFF),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE7E7E7)),
                      ),
                      child: Column(
                        children: _availableCategories.map((category) {
                          final isLast = category == _availableCategories.last;
                          final isSelected = _selectedCategories.contains(category);
                          
                          return InkWell(
                            onTap: () {
                              setState(() {
                                if (isSelected) {
                                  _selectedCategories.remove(category);
                                } else {
                                  _selectedCategories.add(category);
                                }
                              });
                            },
                            child: Container(
                              height: 40,
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                border: isLast
                                    ? null
                                    : const Border(
                                        bottom: BorderSide(
                                          color: Color(0xFFE7E7E7),
                                        ),
                                      ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    category,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w400,
                                      color: Color(0xFF111827),
                                      fontFamily: 'Inter',
                                    ),
                                  ),
                                  Icon(
                                    isSelected ? Icons.check : Icons.add,
                                    size: 16,
                                    color: isSelected 
                                        ? const Color(0xFFFF4040) 
                                        : const Color(0xFF9CA3AF),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),

                  // Business Location
                  const Text(
                    'Business Location',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF111827),
                      fontFamily: 'Inter',
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    height: 46,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFFFFF),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE7E7E7)),
                    ),
                    alignment: Alignment.centerLeft,
                    child: const Text(
                      'Trivandrum',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF111827),
                        fontFamily: 'Inter',
                      ),
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Optional',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF9CA3AF),
                      fontFamily: 'Inter',
                    ),
                  ),
                ],
              ),
            ),

            // Save Changes Bottom Bar
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.only(
                  top: 8,
                  bottom: 16,
                  left: 16,
                  right: 16,
                ),
                decoration: const BoxDecoration(
                  color: Color(0xFFFFFFFF),
                  border: Border(
                    top: BorderSide(color: Color(0xFFE7E7E7)),
                  ),
                ),
                child: FilledButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFFF4040),
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                    shadowColor: const Color(0x14FF4040),
                  ),
                  child: const Text(
                    'Save Changes',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Inter',
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
