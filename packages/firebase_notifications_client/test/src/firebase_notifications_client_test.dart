import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_notifications_client/firebase_notifications_client.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:notifications_client/notifications_client.dart';

class MockFirebaseMessaging extends Mock implements FirebaseMessaging {}

void main() {
  group('FirebaseNotificationsClient', () {
    late FirebaseMessaging firebaseMessaging;
    late FirebaseNotificationsClient client;

    setUp(() {
      firebaseMessaging = MockFirebaseMessaging();
      client = FirebaseNotificationsClient(
        firebaseMessaging: firebaseMessaging,
      );
    });

    test('can be instantiated', () {
      expect(
        FirebaseNotificationsClient(firebaseMessaging: firebaseMessaging),
        isNotNull,
      );
    });

    group('requestPermission', () {
      test('completes normally when Firebase succeeds', () async {
        when(() => firebaseMessaging.requestPermission()).thenAnswer(
          (_) async => const NotificationSettings(
            authorizationStatus: AuthorizationStatus.authorized,
            alert: AppleNotificationSetting.enabled,
            announcement: AppleNotificationSetting.enabled,
            badge: AppleNotificationSetting.enabled,
            carPlay: AppleNotificationSetting.enabled,
            criticalAlert: AppleNotificationSetting.enabled,
            sound: AppleNotificationSetting.enabled,
            timeSensitive: AppleNotificationSetting.enabled,
            lockScreen: AppleNotificationSetting.enabled,
            notificationCenter: AppleNotificationSetting.enabled,
            showPreviews: AppleShowPreviewSetting.always,
            providesAppNotificationSettings:
                AppleNotificationSetting.notSupported,
          ),
        );

        await expectLater(client.requestPermission(), completes);
        verify(() => firebaseMessaging.requestPermission()).called(1);
      });

      test('throws RequestPermissionFailure on Firebase error', () async {
        when(
          () => firebaseMessaging.requestPermission(),
        ).thenThrow(Exception('oops'));

        await expectLater(
          client.requestPermission(),
          throwsA(isA<RequestPermissionFailure>()),
        );
      });
    });

    group('fetchToken', () {
      test('returns token when Firebase succeeds', () async {
        const token = 'test_token';
        when(() => firebaseMessaging.getToken()).thenAnswer((_) async => token);

        final result = await client.fetchToken();
        expect(result, equals(token));
        verify(() => firebaseMessaging.getToken()).called(1);
      });

      test('throws FetchTokenFailure on Firebase error', () async {
        when(() => firebaseMessaging.getToken()).thenThrow(Exception('oops'));

        await expectLater(
          client.fetchToken(),
          throwsA(isA<FetchTokenFailure>()),
        );
      });
    });

    group('onTokenRefresh', () {
      test('returns stream of tokens', () {
        const stream = Stream<String>.empty();
        when(() => firebaseMessaging.onTokenRefresh).thenAnswer((_) => stream);

        expect(client.onTokenRefresh(), equals(stream));
        verify(() => firebaseMessaging.onTokenRefresh).called(1);
      });
    });
  });
}
