import 'package:flutter_test/flutter_test.dart';
import 'package:notifications_repository/notifications_repository.dart';

void main() {
  group('NotificationsRepositoryException', () {
    test('NotificationsPermissionException can be instantiated', () {
      expect(
        const NotificationsPermissionException('error', StackTrace.empty),
        isNotNull,
      );
    });

    test('NotificationsTokenException can be instantiated', () {
      expect(
        const NotificationsTokenException('error', StackTrace.empty),
        isNotNull,
      );
    });
  });
}
