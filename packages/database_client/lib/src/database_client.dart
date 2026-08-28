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

  /// Upserts a user's profile information.
  Future<void> upsertProfile({
    required String id,
    String? firstName,
    String? lastName,
    String? phone,
  }) async {
    await _supabaseClient.from('profiles').upsert({
      'id': id,
      'first_name': firstName,
      'last_name': lastName,
      'phone': phone,
      'updated_at': DateTime.now().toIso8601String(),
    });
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
          'updated_at': DateTime.now().toIso8601String(),
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
}
