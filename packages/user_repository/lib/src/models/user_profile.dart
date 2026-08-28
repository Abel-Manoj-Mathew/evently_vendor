import 'package:equatable/equatable.dart';

/// {@template user_profile}
/// Domain model for a user profile.
/// {@endtemplate}
class UserProfile extends Equatable {
  /// {@macro user_profile}
  const UserProfile({
    required this.id,
    this.firstName,
    this.lastName,
    this.phone,
    this.email,
  });

  /// The unique identifier of the user (UUID).
  final String id;

  /// The user's first name.
  final String? firstName;

  /// The user's last name.
  final String? lastName;

  /// The user's phone number.
  final String? phone;

  /// The user's email address.
  final String? email;

  @override
  List<Object?> get props => [id, firstName, lastName, phone, email];
}
