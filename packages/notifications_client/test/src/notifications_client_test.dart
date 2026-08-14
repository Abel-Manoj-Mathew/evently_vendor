import 'package:flutter_test/flutter_test.dart';
import 'package:notifications_client/notifications_client.dart';

class _FakeNotificationsClient implements NotificationsClient {
  @override
  Future<String?> fetchToken() async => 'token';

  @override
  Stream<String> onTokenRefresh() => const Stream.empty();

  @override
  Future<void> requestPermission() async {}
}

void main() {
  group('NotificationsClient', () {
    test('can be implemented', () {
      expect(_FakeNotificationsClient(), isNotNull);
    });
  });
}
