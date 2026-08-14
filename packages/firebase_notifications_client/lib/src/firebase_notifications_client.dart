import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:notifications_client/notifications_client.dart';

/// {@template firebase_notifications_client}
/// Firebase implementation of [NotificationsClient].
/// {@endtemplate}
class FirebaseNotificationsClient implements NotificationsClient {
  /// {@macro firebase_notifications_client}
  const FirebaseNotificationsClient({
    required this._firebaseMessaging,
  });

  final FirebaseMessaging _firebaseMessaging;

  @override
  Future<String?> fetchToken() async {
    try {
      return await _firebaseMessaging.getToken();
    } catch (error, stackTrace) {
      throw FetchTokenFailure(error, stackTrace);
    }
  }

  @override
  Stream<String> onTokenRefresh() {
    return _firebaseMessaging.onTokenRefresh;
  }

  @override
  Future<void> requestPermission() async {
    try {
      await _firebaseMessaging.requestPermission();
    } catch (error, stackTrace) {
      throw RequestPermissionFailure(error, stackTrace);
    }
  }
}
