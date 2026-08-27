/// {@template notifications_client_exception}
/// Base exception for notifications client failures.
/// {@endtemplate}
abstract class NotificationsClientException implements Exception {
  /// {@macro notifications_client_exception}
  const NotificationsClientException(this.error, this.stackTrace);

  /// The original error that caused this exception.
  final Object error;

  /// The stack trace associated with the original error.
  final StackTrace stackTrace;
}

/// {@template fetch_token_failure}
/// Thrown when fetching the push notification token fails.
/// {@endtemplate}
class FetchTokenFailure extends NotificationsClientException {
  /// {@macro fetch_token_failure}
  const FetchTokenFailure(super.error, super.stackTrace);
}

/// {@template request_permission_failure}
/// Thrown when requesting permission to send push notifications fails.
/// {@endtemplate}
class RequestPermissionFailure extends NotificationsClientException {
  /// {@macro request_permission_failure}
  const RequestPermissionFailure(super.error, super.stackTrace);
}
