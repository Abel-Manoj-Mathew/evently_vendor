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

  /// Inserts a new customer record into the database.
  Future<Map<String, dynamic>> insertCustomer({
    required String businessId,
    required String name,
    required String phone,
    String? email,
    String? notes,
  }) async {
    final payload = <String, dynamic>{
      'business_id': businessId,
      'name': name,
      'phone': phone,
      if (email != null && email.isNotEmpty) 'email': email,
      if (notes != null && notes.isNotEmpty) 'notes': notes,
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    };

    final response = await _supabaseClient
        .from('customers')
        .insert(payload)
        .select()
        .single();

    return response as Map<String, dynamic>;
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
}


