import 'package:customer_repository/src/models/models.dart';
import 'package:database_client/database_client.dart';

/// {@template customer_repository}
/// A repository that manages customer data.
/// {@endtemplate}
class CustomerRepository {
  /// {@macro customer_repository}
  const CustomerRepository({
    required DatabaseClient databaseClient,
  }) : _databaseClient = databaseClient;

  final DatabaseClient _databaseClient;

  /// Fetches the business ID owned by the specified user.
  Future<String?> getBusinessIdForUser(String ownerId) async {
    try {
      return await _databaseClient.getBusinessIdForUser(ownerId);
    } catch (e) {
      throw Exception('Failed to fetch business ID for user: $e');
    }
  }

  /// Creates a new customer and returns the created [Customer] model.
  Future<Customer> createCustomer({
    required String businessId,
    required String name,
    required String phone,
    String? email,
    String? notes,
  }) async {
    try {
      final data = await _databaseClient.insertCustomer(
        businessId: businessId,
        name: name,
        phone: phone,
        email: email,
        notes: notes,
      );
      return Customer.fromJson(data);
    } catch (e) {
      throw Exception('Failed to create customer: $e');
    }
  }

  /// Fetches all customers for a given business ID.
  Future<List<Customer>> getCustomers({
    required String businessId,
  }) async {
    try {
      final list = await _databaseClient.getCustomers(businessId: businessId);
      return list.map(Customer.fromJson).toList();
    } catch (e) {
      throw Exception('Failed to fetch customers: $e');
    }
  }
}
