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

  /// Gets the first business ID associated with the current user.
  Future<String?> getDefaultBusinessId() async {
    final response = await _supabaseClient
        .from('businesses')
        .select('id')
        .eq('owner_id', _supabaseClient.auth.currentUser!.id)
        .limit(1)
        .maybeSingle();
    return response != null ? response['id'] as String : null;
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
    final response = await _supabaseClient
        .from('customers')
        .insert({
          'business_id': businessId,
          'name': name,
          'phone': phone,
          if (email != null && email.isNotEmpty) 'email': email,
          if (notes != null && notes.isNotEmpty) 'notes': notes,
        })
        .select('id')
        .single();
    
    return response['id'] as String;
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
