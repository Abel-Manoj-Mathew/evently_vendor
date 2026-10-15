import 'package:equatable/equatable.dart';

/// {@template authenticated_user}
/// The signed-in account, independent of the auth provider's user type.
/// {@endtemplate}
class AuthenticatedUser extends Equatable {
  /// {@macro authenticated_user}
  const AuthenticatedUser({required this.id, this.phone});

  /// Stable account identifier (Supabase `auth.users.id`).
  final String id;

  /// Verified phone number in E.164 format, when available.
  final String? phone;

  @override
  List<Object?> get props => [id, phone];
}
