/// {@template notifications_client}
/// A generic interface for notification services.
/// {@endtemplate}
abstract interface class NotificationsClient {
  /// Requests permission to receive notifications.
  Future<void> requestPermission();

  /// Fetches the current notification token.
  Future<String?> fetchToken();

  /// A stream of refreshed notification tokens.
  Stream<String> onTokenRefresh();
}
