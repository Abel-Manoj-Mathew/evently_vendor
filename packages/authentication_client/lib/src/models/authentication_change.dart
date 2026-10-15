import 'package:authentication_client/src/models/authenticated_user.dart';
import 'package:equatable/equatable.dart';

/// {@template authentication_change}
/// A change in whether a user is signed in.
/// {@endtemplate}
sealed class AuthenticationChange extends Equatable {
  /// {@macro authentication_change}
  const AuthenticationChange();
}

/// {@template authenticated}
/// A valid session exists for [user].
/// {@endtemplate}
final class Authenticated extends AuthenticationChange {
  /// {@macro authenticated}
  const Authenticated(this.user);

  /// The signed-in user.
  final AuthenticatedUser user;

  @override
  List<Object?> get props => [user];
}

/// {@template unauthenticated}
/// No session exists.
/// {@endtemplate}
final class Unauthenticated extends AuthenticationChange {
  /// {@macro unauthenticated}
  const Unauthenticated({this.sessionExpired = false});

  /// Whether the session ended without the user signing out, for example
  /// because the refresh token was revoked or expired.
  final bool sessionExpired;

  @override
  List<Object?> get props => [sessionExpired];
}
