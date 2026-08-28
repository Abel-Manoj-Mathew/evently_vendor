// Not required for test files
// ignore_for_file: prefer_const_constructors
import 'package:notifications_client/notifications_client.dart';
import 'package:test/test.dart';

class TestNotificationsClient extends NotificationsClient {
  const TestNotificationsClient();

  @override
  Future<String?> fetchToken() async => null;

  @override
  Future<void> requestPermission() async {}

  @override
  Stream<String> onTokenRefresh() => const Stream.empty();
}

void main() {
  group('NotificationsClient', () {
    test('can be instantiated', () {
      expect(TestNotificationsClient(), isNotNull);
    });
  });

  group('NotificationsClientException', () {
    test('FetchTokenFailure can be instantiated', () {
      final error = Exception('error');
      final stackTrace = StackTrace.current;
      final exception = FetchTokenFailure(error, stackTrace);
      expect(exception.error, equals(error));
      expect(exception.stackTrace, equals(stackTrace));
    });

    test('RequestPermissionFailure can be instantiated', () {
      final error = Exception('error');
      final stackTrace = StackTrace.current;
      final exception = RequestPermissionFailure(error, stackTrace);
      expect(exception.error, equals(error));
      expect(exception.stackTrace, equals(stackTrace));
    });
  });
}
