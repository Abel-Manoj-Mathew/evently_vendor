// Ignore for testing purposes

import 'package:evently_vendor/app/app.dart';
import 'package:evently_vendor/auth/login/login.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:notifications_repository/notifications_repository.dart';

class MockNotificationsRepository extends Mock
    implements NotificationsRepository {}

void main() {
  group('App', () {
    late NotificationsRepository notificationsRepository;

    setUp(() {
      notificationsRepository = MockNotificationsRepository();
    });
    testWidgets('renders LoginPage', (tester) async {
      tester.view.physicalSize = const Size(375, 812);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        App(notificationsRepository: notificationsRepository),
      );
      expect(find.byType(LoginPage), findsOneWidget);
    });
  });
}
