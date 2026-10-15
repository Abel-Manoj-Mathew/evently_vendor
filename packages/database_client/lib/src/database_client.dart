import 'package:database_client/src/exceptions.dart';
import 'package:supabase/supabase.dart';

/// Postgres error code for unique constraint violations.
const _uniqueViolation = '23505';

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

  /// Whether a profile row exists for the user with [id].
  Future<bool> profileExists(String id) async {
    final existing = await _supabaseClient
        .from('profiles')
        .select('id')
        .eq('id', id)
        .maybeSingle();
    return existing != null;
  }

  /// Creates or updates the profile for the user with [id].
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
    // Ordered and limited: nothing in the schema yet prevents a retried
    // onboarding request from creating a second business, and
    // `maybeSingle` would throw on duplicates and lock the user out.
    final response = await _supabaseClient
        .from('businesses')
        .select('id')
        .eq('owner_id', ownerId)
        .order('created_at')
        .limit(1)
        .maybeSingle();

    return response != null ? response['id'] as String : null;
  }

  /// Gets the first business ID associated with the current user.
  Future<String?> getDefaultBusinessId() async {
    final currentUser = _supabaseClient.auth.currentUser;
    if (currentUser == null) return null;
    return getBusinessIdForUser(currentUser.id);
  }

  /// Inserts a new customer record and returns the stored row.
  ///
  /// Shared phone numbers are allowed by product decision; duplicate
  /// detection is a warning handled by the caller. Throws a
  /// [DuplicateRecordException] if the database still enforces a unique
  /// phone number (migrations before `0004`).
  Future<Map<String, dynamic>> insertCustomer({
    required String businessId,
    required String name,
    String? phone,
    String? email,
    String? notes,
  }) async {
    final payload = <String, dynamic>{
      'business_id': businessId,
      'name': name,
      'phone': ?phone,
      'email': ?email,
      'notes': ?notes,
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    };

    try {
      return await _supabaseClient
          .from('customers')
          .insert(payload)
          .select()
          .single();
    } on PostgrestException catch (error) {
      if (error.code == _uniqueViolation) {
        throw DuplicateRecordException(error);
      }
      rethrow;
    }
  }

  /// Fetches a customer by [id], or `null` if it does not exist or the
  /// current user may not access it.
  Future<Map<String, dynamic>?> getCustomerById(String id) {
    return _supabaseClient
        .from('customers')
        .select()
        .eq('id', id)
        .maybeSingle();
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

    return response;
  }

  /// Fetches the current user's vendor profile details.
  Future<Map<String, dynamic>> getVendorProfileDetails() async {
    final user = _supabaseClient.auth.currentUser!;

    // Default fallback values
    var businessName =
        user.userMetadata?['business_name'] as String? ?? 'Unknown Business';
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

        final categoriesList =
            businessResponse['business_category_selections'] as List<dynamic>?;
        if (categoriesList != null && categoriesList.isNotEmpty) {
          category =
              (categoriesList.first as Map<String, dynamic>)['name']
                  as String? ??
              category;
        }
      }
    } on PostgrestException {
      // Fall back to the account-level values above; the caller still
      // receives a usable profile.
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
