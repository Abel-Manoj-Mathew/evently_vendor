/// {@template notifications_repository_exception}
/// Base exception for notifications repository failures.
/// {@endtemplate}
abstract class NotificationsRepositoryException implements Exception {
  /// {@macro notifications_repository_exception}
  const NotificationsRepositoryException(this.error, this.stackTrace);

  /// The original error.
  final Object error;

  /// The stack trace.
  final StackTrace stackTrace;
}

/// {@template notifications_permission_exception}
/// Thrown when requesting notification permission fails.
/// {@endtemplate}
class NotificationsPermissionException
    extends NotificationsRepositoryException {
  /// {@macro notifications_permission_exception}
  const NotificationsPermissionException(super.error, super.stackTrace);
}

/// {@template notifications_token_exception}
/// Thrown when fetching the notification token fails.
/// {@endtemplate}
class NotificationsTokenException extends NotificationsRepositoryException {
  /// {@macro notifications_token_exception}
  const NotificationsTokenException(super.error, super.stackTrace);
}
