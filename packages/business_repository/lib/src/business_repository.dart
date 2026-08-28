import 'package:business_repository/src/models/models.dart';
import 'package:database_client/database_client.dart';

/// {@template business_repository}
/// A repository that manages business data and categories.
/// {@endtemplate}
class BusinessRepository {
  /// {@macro business_repository}
  const BusinessRepository({
    required this._databaseClient,
  });

  final DatabaseClient _databaseClient;

  /// Fetches all available business categories from the database.
  Future<List<String>> getCategories() async {
    try {
      return await _databaseClient.getCategories();
    } catch (e) {
      throw Exception('Failed to fetch categories: $e');
    }
  }

  /// Creates a new business and associates its categories.
  /// Returns the created [Business] domain model.
  Future<Business> createBusiness({
    required String ownerId,
    required String businessName,
    required List<String> categories,
  }) async {
    try {
      final businessId = await _databaseClient.insertBusiness(
        ownerId: ownerId,
        businessName: businessName,
        categories: categories,
      );

      return Business(
        id: businessId,
        ownerId: ownerId,
        name: businessName,
        categories: categories,
      );
    } catch (e) {
      throw Exception('Failed to create business: $e');
    }
  }

  /// Gets the first business ID associated with the current user.
  Future<String?> getDefaultBusinessId() async {
    try {
      return await _databaseClient.getDefaultBusinessId();
    } catch (e) {
      throw Exception('Failed to fetch default business ID: $e');
    }
  }

  /// Creates a new customer for a given business.
  Future<String> createCustomer({
    required String businessId,
    required String name,
    required String phone,
    String? email,
    String? notes,
  }) async {
    try {
      return await _databaseClient.createCustomer(
        businessId: businessId,
        name: name,
        phone: phone,
        email: email,
        notes: notes,
      );
    } catch (e) {
      throw Exception('Failed to create customer: $e');
    }
  }

  /// Fetches the vendor profile details (Business and Account data).
  Future<VendorProfile> getVendorProfileDetails() async {
    try {
      final data = await _databaseClient.getVendorProfileDetails();
      return VendorProfile(
        businessName: data['businessName'] as String,
        location: data['location'] as String,
        category: data['category'] as String,
        phone: data['phone'] as String,
        email: data['email'] as String,
      );
    } catch (e) {
      throw Exception('Failed to fetch vendor profile: $e');
    }
  }
}
