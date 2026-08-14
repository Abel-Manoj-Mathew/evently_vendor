import 'package:notifications_client/notifications_client.dart';
import 'package:notifications_repository/src/exceptions.dart';

/// {@template notifications_repository}
/// Repository which manages notifications.
/// {@endtemplate}
class NotificationsRepository {
  /// {@macro notifications_repository}
  const NotificationsRepository({
    required this._notificationsClient,
  });

  final NotificationsClient _notificationsClient;

  /// Requests permission to receive notifications.
  Future<void> requestPermission() async {
    try {
      await _notificationsClient.requestPermission();
    } catch (error, stackTrace) {
      throw NotificationsPermissionException(error, stackTrace);
    }
  }

  /// Fetches the current notification token.
  Future<String?> fetchToken() async {
    try {
      return await _notificationsClient.fetchToken();
    } catch (error, stackTrace) {
      throw NotificationsTokenException(error, stackTrace);
    }
  }

  /// A stream of refreshed notification tokens.
  Stream<String> onTokenRefresh() {
    return _notificationsClient.onTokenRefresh();
  }
}
