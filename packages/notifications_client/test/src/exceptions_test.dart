import 'package:flutter_test/flutter_test.dart';
import 'package:notifications_client/notifications_client.dart';

void main() {
  group('NotificationsException', () {
    test('RequestPermissionFailure can be instantiated', () {
      expect(const RequestPermissionFailure('error', StackTrace.empty), isNotNull);
    });

    test('FetchTokenFailure can be instantiated', () {
      expect(const FetchTokenFailure('error', StackTrace.empty), isNotNull);
    });
  });
}
