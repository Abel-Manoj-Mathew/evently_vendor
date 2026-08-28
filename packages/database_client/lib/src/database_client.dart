import 'package:supabase/supabase.dart';

/// {@template database_client}
/// A client that handles all direct database interactions with Supabase.
/// {@endtemplate}
class DatabaseClient {
  /// {@macro database_client}
  const DatabaseClient({
    required this._supabaseClient,
  });

  final SupabaseClient _supabaseClient;

  /// Fetches all available business categories from the database.
  Future<List<String>> getCategories() async {
    final response = await _supabaseClient
        .from('business_catagories')
        .select('name')
        .order('name', ascending: true);

    return (response as List<dynamic>)
        .map((row) => (row as Map<String, dynamic>)['name'] as String)
        .toList();
  }

  Future<bool> profileExists(String id) async {
    print('DEBUG: Checking if profile exists for ID: $id');
    final existing = await _supabaseClient
        .from('profiles')
        .select('id')
        .eq('id', id)
        .maybeSingle();
    print('DEBUG: Profile check result: $existing');
    return existing != null;
  }

  Future<void> upsertProfile({
    required String id,
    String? firstName,
    String? lastName,
    String? phone,
  }) async {
    final payload = {
      'first_name': firstName,
      'last_name': lastName,
      'phone': phone,
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    };

    // Explicitly check for existence to avoid upsert RLS policy issues
    final existing = await _supabaseClient
        .from('profiles')
        .select('id')
        .eq('id', id)
        .maybeSingle();

    if (existing != null) {
      await _supabaseClient.from('profiles').update(payload).eq('id', id);
    } else {
      payload['id'] = id;
      await _supabaseClient.from('profiles').insert(payload);
    }
  }

  /// Inserts a new business and its categories.
  /// Returns the created business ID.
  Future<String> insertBusiness({
    required String ownerId,
    required String businessName,
    required List<String> categories,
  }) async {
    // Insert business
    final businessResponse = await _supabaseClient
        .from('businesses')
        .insert({
          'owner_id': ownerId,
          'name': businessName,
          'updated_at': DateTime.now().toUtc().toIso8601String(),
        })
        .select('id')
        .single();

    final businessId = businessResponse['id'] as String;

    // Insert categories
    if (categories.isNotEmpty) {
      final categoryRows = categories
          .map(
            (cat) => {
              'business_id': businessId,
              'name': cat,
            },
          )
          .toList();

      await _supabaseClient
          .from('business_category_selections')
          .insert(categoryRows);
    }

    return businessId;
  }

  /// Fetches the business ID for a given user owner ID.
  Future<String?> getBusinessIdForUser(String ownerId) async {
    final response = await _supabaseClient
        .from('businesses')
        .select('id')
        .eq('owner_id', ownerId)
        .maybeSingle();

    return response != null ? response['id'] as String : null;
  }

  /// Gets the first business ID associated with the current user.
  Future<String?> getDefaultBusinessId() async {
    final currentUser = _supabaseClient.auth.currentUser;
    if (currentUser == null) return null;
    return getBusinessIdForUser(currentUser.id);
  }

  /// Fetches a customer record by business ID and phone number if one exists.
  Future<Map<String, dynamic>?> getCustomerByPhone({
    required String businessId,
    required String phone,
  }) async {
    final response = await _supabaseClient
        .from('customers')
        .select()
        .eq('business_id', businessId)
        .eq('phone', phone)
        .order('created_at', ascending: false)
        .limit(1)
        .maybeSingle();

    if (response != null) return response as Map<String, dynamic>;

    // Digit-only fallback check for matching phone numbers (e.g. "+1 (555) 201-4892" vs "+15552014892")
    final sanitizedInput = phone.replaceAll(RegExp(r'\D'), '');
    if (sanitizedInput.isNotEmpty) {
      final allCustomers = await getCustomers(businessId: businessId);
      for (final c in allCustomers) {
        final cPhone = (c['phone'] as String? ?? '').replaceAll(RegExp(r'\D'), '');
        if (cPhone.isNotEmpty && cPhone == sanitizedInput) {
          return c;
        }
      }
    }

    return null;
  }

  /// Inserts a new customer record into the database, or returns an existing one if phone already exists.
  Future<Map<String, dynamic>> insertCustomer({
    required String businessId,
    required String name,
    required String phone,
    String? email,
    String? notes,
  }) async {
    final existing = await getCustomerByPhone(
      businessId: businessId,
      phone: phone,
    );
    if (existing != null) {
      return existing;
    }

    final payload = <String, dynamic>{
      'business_id': businessId,
      'name': name,
      'phone': phone,
      if (email != null && email.isNotEmpty) 'email': email,
      if (notes != null && notes.isNotEmpty) 'notes': notes,
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    };

    try {
      final response = await _supabaseClient
          .from('customers')
          .insert(payload)
          .select()
          .single();

      return response as Map<String, dynamic>;
    } catch (_) {
      // Fallback check in case of concurrent insert / database unique constraint
      final existingAfterErr = await getCustomerByPhone(
        businessId: businessId,
        phone: phone,
      );
      if (existingAfterErr != null) {
        return existingAfterErr;
      }
      rethrow;
    }
  }

  /// Creates a new customer for a given business.
  /// Returns the newly created customer ID.
  Future<String> createCustomer({
    required String businessId,
    required String name,
    required String phone,
    String? email,
    String? notes,
  }) async {
    final result = await insertCustomer(
      businessId: businessId,
      name: name,
      phone: phone,
      email: email,
      notes: notes,
    );
    return result['id'] as String;
  }

  /// Fetches all customers for a given business ID.
  Future<List<Map<String, dynamic>>> getCustomers({
    required String businessId,
  }) async {
    final response = await _supabaseClient
        .from('customers')
        .select()
        .eq('business_id', businessId)
        .order('created_at', ascending: false);

    return (response as List<dynamic>)
        .map((row) => row as Map<String, dynamic>)
        .toList();
  }

  /// Fetches the current user's vendor profile details.
  Future<Map<String, dynamic>> getVendorProfileDetails() async {
    final user = _supabaseClient.auth.currentUser!;
    
    // Default fallback values
    var businessName = user.userMetadata?['business_name'] as String? ?? 'Unknown Business';
    var location = 'Location not set';
    var category = 'Category not set';
    final phone = user.phone ?? 'No phone number';
    final email = user.email ?? 'No email provided';

    try {
      final businessResponse = await _supabaseClient
          .from('businesses')
          .select('name, location, business_category_selections(name)')
          .eq('owner_id', user.id)
          .limit(1)
          .maybeSingle();

      if (businessResponse != null) {
        businessName = businessResponse['name'] as String? ?? businessName;
        location = businessResponse['location'] as String? ?? location;
        
        final categoriesList = businessResponse['business_category_selections'] as List<dynamic>?;
        if (categoriesList != null && categoriesList.isNotEmpty) {
          category = (categoriesList.first as Map<String, dynamic>)['name'] as String? ?? category;
        }
      }
    } catch (e) {
      print('DEBUG: Error fetching business profile details: $e');
    }

    return {
      'businessName': businessName,
      'location': location,
      'category': category,
      'phone': phone,
      'email': email,
    };
  }
}


