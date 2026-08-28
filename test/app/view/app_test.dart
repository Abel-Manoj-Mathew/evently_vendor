// Ignore for testing purposes

import 'package:business_repository/business_repository.dart';
import 'package:evently_vendor/app/app.dart';
import 'package:evently_vendor/auth/login/login.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:notifications_repository/notifications_repository.dart';
import 'package:user_repository/user_repository.dart';

class MockNotificationsRepository extends Mock
    implements NotificationsRepository {}

class MockUserRepository extends Mock implements UserRepository {}

class MockBusinessRepository extends Mock implements BusinessRepository {}

void main() {
  group('App', () {
    late NotificationsRepository notificationsRepository;
    late UserRepository userRepository;
    late BusinessRepository businessRepository;

    setUp(() {
      notificationsRepository = MockNotificationsRepository();
      userRepository = MockUserRepository();
      businessRepository = MockBusinessRepository();
    });
    testWidgets('renders LoginPage', (tester) async {
      tester.view.physicalSize = const Size(375, 812);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        App(
          notificationsRepository: notificationsRepository,
          userRepository: userRepository,
          businessRepository: businessRepository,
        ),
      );
      expect(find.byType(LoginPage), findsOneWidget);
    });
  });
}
