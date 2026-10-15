import 'package:customer_repository/src/models/models.dart';
import 'package:database_client/database_client.dart';

/// {@template customer_phone_already_exists}
/// The database rejected a customer because its phone number is already
/// used. Only possible while the legacy unique constraint from migration
/// `0002` is still applied.
/// {@endtemplate}
class CustomerPhoneAlreadyExistsException implements Exception {
  /// {@macro customer_phone_already_exists}
  const CustomerPhoneAlreadyExistsException();
}

/// {@template customer_repository}
/// A repository that manages customer data.
/// {@endtemplate}
class CustomerRepository {
  /// {@macro customer_repository}
  const CustomerRepository({required this._databaseClient});

  final DatabaseClient _databaseClient;

  /// Fetches the business ID owned by the specified user.
  Future<String?> getBusinessIdForUser(String ownerId) async {
    try {
      return await _databaseClient.getBusinessIdForUser(ownerId);
    } catch (e) {
      throw Exception('Failed to fetch business ID for user: $e');
    }
  }

  /// Creates a new customer and returns it.
  ///
  /// [phone] is optional and is normalized with [CustomerPhone.normalize].
  /// This never merges with an existing customer; call
  /// [findPotentialDuplicates] first to warn the user.
  ///
  /// Throws [CustomerPhoneAlreadyExistsException] if the database still
  /// enforces unique phone numbers.
  Future<Customer> createCustomer({
    required String businessId,
    required String name,
    String? phone,
    String? email,
    String? notes,
  }) async {
    String? emptyToNull(String? value) {
      final trimmed = value?.trim();
      return trimmed == null || trimmed.isEmpty ? null : trimmed;
    }

    try {
      final data = await _databaseClient.insertCustomer(
        businessId: businessId,
        name: name.trim(),
        phone: phone == null ? null : CustomerPhone.normalize(phone),
        email: emptyToNull(email),
        notes: emptyToNull(notes),
      );
      return Customer.fromJson(data);
    } on DuplicateRecordException {
      throw const CustomerPhoneAlreadyExistsException();
    } catch (e) {
      throw Exception('Failed to create customer: $e');
    }
  }

  /// Returns customers of [businessId] whose phone likely matches [phone].
  ///
  /// Matches are a hint for the user, not a uniqueness rule. This loads the
  /// business's customers to compare normalized numbers; it moves to an
  /// indexed local query when offline storage is introduced.
  Future<List<Customer>> findPotentialDuplicates({
    required String businessId,
    required String phone,
  }) async {
    if (phone.trim().isEmpty) return const [];
    final customers = await getCustomers(businessId: businessId);
    return customers.where((customer) {
      final existing = customer.phone;
      return existing != null && CustomerPhone.isLikelySame(existing, phone);
    }).toList();
  }

  /// Fetches a customer by [id], or `null` when it does not exist or is not
  /// accessible to the current user.
  Future<Customer?> getCustomer(String id) async {
    try {
      final data = await _databaseClient.getCustomerById(id);
      return data == null ? null : Customer.fromJson(data);
    } catch (e) {
      throw Exception('Failed to fetch customer: $e');
    }
  }

  /// Fetches all customers for a given business ID.
  Future<List<Customer>> getCustomers({required String businessId}) async {
    try {
      final list = await _databaseClient.getCustomers(businessId: businessId);
      return list.map(Customer.fromJson).toList();
    } catch (e) {
      throw Exception('Failed to fetch customers: $e');
    }
  }
}
