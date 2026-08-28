import 'package:database_client/database_client.dart';

/// {@template user_repository}
/// A repository that manages user profile data.
/// {@endtemplate}
class UserRepository {
  /// {@macro user_repository}
  const UserRepository({
    required this._databaseClient,
  });

  final DatabaseClient _databaseClient;

  Future<bool> profileExists(String id) async {
    try {
      return await _databaseClient.profileExists(id);
    } catch (e) {
      throw Exception('Failed to check profile existence: $e');
    }
  }

  /// Updates or inserts the user's profile information in the database.
  Future<void> updateProfile({
    required String id,
    String? firstName,
    String? lastName,
    String? phone,
  }) async {
    try {
      await _databaseClient.upsertProfile(
        id: id,
        firstName: firstName,
        lastName: lastName,
        phone: phone,
      );
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }
}

