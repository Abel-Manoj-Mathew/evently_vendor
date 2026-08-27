/// {@template notifications_client}
/// A Very Good Project created by Very Good CLI.
/// {@endtemplate}
abstract class NotificationsClient {
  /// {@macro notifications_client}
  const NotificationsClient();

  /// Fetches the push notification token.
  Future<String?> fetchToken();

  /// Requests permission to send push notifications.
  Future<void> requestPermission();

  /// A stream that emits when the push notification token is refreshed.
  Stream<String> onTokenRefresh();
}
