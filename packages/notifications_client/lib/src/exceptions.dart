/// {@template notifications_exception}
/// Base exception for notification failures.
/// {@endtemplate}
abstract class NotificationsException implements Exception {
  /// {@macro notifications_exception}
  const NotificationsException(this.error, this.stackTrace);

  /// The original error.
  final Object error;

  /// The stack trace.
  final StackTrace stackTrace;
}

/// {@template request_permission_failure}
/// Thrown when requesting notification permission fails.
/// {@endtemplate}
class RequestPermissionFailure extends NotificationsException {
  /// {@macro request_permission_failure}
  const RequestPermissionFailure(super.error, super.stackTrace);
}

/// {@template fetch_token_failure}
/// Thrown when fetching the notification token fails.
/// {@endtemplate}
class FetchTokenFailure extends NotificationsException {
  /// {@macro fetch_token_failure}
  const FetchTokenFailure(super.error, super.stackTrace);
}
