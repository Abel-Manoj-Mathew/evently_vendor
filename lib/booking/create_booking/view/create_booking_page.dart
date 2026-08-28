import 'dart:async';

import 'package:customer_repository/customer_repository.dart';
import 'package:evently_vendor/customer/customer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Customer data model for booking selection.
class CustomerItem {
  const CustomerItem({
    required this.name,
    required this.phone,
    required this.initials,
    required this.email,
    required this.customerSince,
    required this.bookingsCount,
    required this.lastEvent,
    required this.upcomingEvent,
  });

  final String name;
  final String phone;
  final String initials;
  final String email;
  final String customerSince;
  final int bookingsCount;
  final String lastEvent;
  final String upcomingEvent;
}

const List<CustomerItem> kRecentCustomers = [
  CustomerItem(
    name: 'Sarah Johnson',
    phone: '+1 (555) 201-4892',
    initials: 'SJ',
    email: 'sarah.johnson@email.com',
    customerSince: 'Mar 2023',
    bookingsCount: 3,
    lastEvent: 'Wedding',
    upcomingEvent: 'None',
  ),
  CustomerItem(
    name: 'Marcus Rivera',
    phone: '+1 (555) 384-7710',
    initials: 'MR',
    email: 'marcus.rivera@email.com',
    customerSince: 'Jan 2024',
    bookingsCount: 2,
    lastEvent: 'Birthday',
    upcomingEvent: 'Corporate',
  ),
  CustomerItem(
    name: 'Priya Nair',
    phone: '+1 (555) 609-3345',
    initials: 'PN',
    email: 'priya.nair@email.com',
    customerSince: 'Nov 2023',
    bookingsCount: 5,
    lastEvent: 'Anniversary',
    upcomingEvent: 'Wedding',
  ),
  CustomerItem(
    name: 'Tom Okafor',
    phone: '+1 (555) 772-0128',
    initials: 'TO',
    email: 'tom.okafor@email.com',
    customerSince: 'Feb 2024',
    bookingsCount: 1,
    lastEvent: 'Conference',
    upcomingEvent: 'None',
  ),
];

/// First step in Create Booking flow to select or search a customer.
class CreateBookingPage extends StatefulWidget {
  const CreateBookingPage({super.key});

  static Route<void> route() {
    return MaterialPageRoute<void>(
      builder: (_) => const CreateBookingPage(),
    );
  }

  @override
  State<CreateBookingPage> createState() => _CreateBookingPageState();
}

class _CreateBookingPageState extends State<CreateBookingPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  late List<CustomerItem> _customers;

  @override
  void initState() {
    super.initState();
    _customers = List<CustomerItem>.from(kRecentCustomers);
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCustomersFromDatabase();
    });
  }

  Future<void> _loadCustomersFromDatabase() async {
    try {
      final customerRepo = context.read<CustomerRepository>();
      final currentUser = Supabase.instance.client.auth.currentUser;
      if (currentUser == null) return;

      final businessId =
          await customerRepo.getBusinessIdForUser(currentUser.id);
      if (businessId == null) return;

      final dbCustomers =
          await customerRepo.getCustomers(businessId: businessId);
      if (dbCustomers.isNotEmpty && mounted) {
        final mappedItems = dbCustomers.map((c) {
          return CustomerItem(
            name: c.name,
            phone: c.phone,
            initials: c.initials,
            email: c.email ?? '',
            customerSince: 'Recent',
            bookingsCount: 0,
            lastEvent: 'None',
            upcomingEvent: 'None',
          );
        }).toList();

        setState(() {
          _customers = [
            ...mappedItems,
            ...kRecentCustomers.where(
              (demo) => !mappedItems.any(
                (item) => item.phone == demo.phone,
              ),
            ),
          ];
        });
      }
    } catch (_) {
      // Ignore background load failures silently if unauthenticated or offline
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<CustomerItem> get _filteredCustomers {
    if (_searchQuery.isEmpty) return _customers;
    return _customers.where((customer) {
      return customer.name.toLowerCase().contains(_searchQuery) ||
          customer.phone.toLowerCase().contains(_searchQuery);
    }).toList();
  }

  void _onCustomerSelected(CustomerItem customer) {
    unawaited(
      Navigator.of(context).push(
        CustomerDetailsPage.route(customer: customer),
      ),
    );
  }

  Future<void> _onNewCustomerPressed() async {
    final newCustomer = await CreateCustomerSheet.show(context);
    if (newCustomer != null && mounted) {
      setState(() {
        _customers.insert(0, newCustomer);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Customer ${newCustomer.name} saved successfully!'),
          backgroundColor: const Color(0xFF10B981),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar
            Container(
              color: const Color(0xFFFFFFFF),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 16,
                      right: 20,
                      top: 14,
                      bottom: 14,
                    ),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          child: Container(
                            width: 44,
                            height: 44,
                            color: Colors.transparent,
                            alignment: Alignment.centerLeft,
                            child: const Icon(
                              Icons.arrow_back,
                              size: 20,
                              color: Color(0xFF1A1A1A),
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Text(
                          'Create Booking',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1A1A1A),
                            height: 1.2,
                            fontFamily: 'Inter',
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Progress Step Indicator (Step 1 of 6: 16.66%)
                  Container(
                    width: double.infinity,
                    height: 3,
                    color: const Color(0xFFF1F1F1),
                    alignment: Alignment.centerLeft,
                    child: FractionallySizedBox(
                      widthFactor: 0.1666,
                      child: Container(
                        color: const Color(0xFFFF4040),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Scrollable Content Body
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.only(
                  left: 20,
                  right: 20,
                  top: 24,
                  bottom: 120,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title Block
                    const Text(
                      'Select a customer',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A1A1A),
                        height: 1.25,
                        fontFamily: 'Inter',
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Search an existing customer or create a new one.',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF6B6B6B),
                        height: 1.5,
                        fontFamily: 'Inter',
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Search Input Bar
                    Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFAFAFA),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFFEAEAEA),
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.search,
                            size: 18,
                            color: Color(0xFF8A8A8A),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: Color(0xFF1A1A1A),
                                fontFamily: 'Inter',
                              ),
                              decoration: const InputDecoration(
                                hintText:
                                    'Search by customer name or mobile number',
                                hintStyle: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: Color(0xFF8A8A8A),
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
                    ),

                    const SizedBox(height: 24),

                    // Recent Customers Section
                    const Padding(
                      padding: EdgeInsets.only(left: 4, bottom: 12),
                      child: Text(
                        'RECENT CUSTOMERS',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF6B6B6B),
                          letterSpacing: 0.65,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ),

                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFFFFF),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFFEAEAEA),
                        ),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: _filteredCustomers.isEmpty
                          ? const Padding(
                              padding: EdgeInsets.all(24),
                              child: Center(
                                child: Text(
                                  'No customers found matching your search.',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w400,
                                    color: Color(0xFF8A8A8A),
                                    fontFamily: 'Inter',
                                  ),
                                ),
                              ),
                            )
                          : Column(
                              children: List.generate(
                                _filteredCustomers.length,
                                (index) {
                                  final customer = _filteredCustomers[index];
                                  final isLast = index ==
                                      _filteredCustomers.length - 1;
                                  return Column(
                                    children: [
                                      InkWell(
                                        onTap: () =>
                                            _onCustomerSelected(customer),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 14,
                                          ),
                                          child: Row(
                                            children: [
                                              // Avatar Circle with Initials
                                              Container(
                                                width: 40,
                                                height: 40,
                                                decoration: BoxDecoration(
                                                  color:
                                                      const Color(0xFFF5F5F5),
                                                  shape: BoxShape.circle,
                                                  border: Border.all(
                                                    color:
                                                        const Color(0xFFEAEAEA),
                                                  ),
                                                ),
                                                alignment: Alignment.center,
                                                child: Text(
                                                  customer.initials,
                                                  style: const TextStyle(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w700,
                                                    color: Color(0xFF6B6B6B),
                                                    fontFamily: 'Inter',
                                                  ),
                                                ),
                                              ),

                                              const SizedBox(width: 12),

                                              // Name & Phone Number Column
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      customer.name,
                                                      style: const TextStyle(
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color: Color(0xFF1A1A1A),
                                                        height: 1.2,
                                                        fontFamily: 'Inter',
                                                      ),
                                                      maxLines: 1,
                                                      overflow: TextOverflow
                                                          .ellipsis,
                                                    ),
                                                    const SizedBox(height: 3),
                                                    Text(
                                                      customer.phone,
                                                      style: const TextStyle(
                                                        fontSize: 13,
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        color: Color(0xFF8A8A8A),
                                                        height: 1.2,
                                                        fontFamily: 'Inter',
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),

                                              const SizedBox(width: 12),

                                              // Chevron Right Icon
                                              const Icon(
                                                Icons.chevron_right_rounded,
                                                size: 18,
                                                color: Color(0xFFA0A0A0),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      if (!isLast)
                                        const Divider(
                                          height: 1,
                                          thickness: 1,
                                          color: Color(0xFFF1F1F1),
                                        ),
                                    ],
                                  );
                                },
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom Fixed Button Bar
            Container(
              decoration: const BoxDecoration(
                color: Color(0xFFFFFFFF),
                border: Border(
                  top: BorderSide(
                    color: Color(0xFFEAEAEA),
                  ),
                ),
              ),
              padding: const EdgeInsets.only(
                left: 20,
                right: 20,
                top: 16,
                bottom: 24,
              ),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton(
                  onPressed: _onNewCustomerPressed,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFFF4040),
                    side: const BorderSide(
                      color: Color(0xFFFF4040),
                      width: 1.5,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    '+ New Customer',
                    style: TextStyle(
                      fontSize: 15,
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
    );
  }
}
