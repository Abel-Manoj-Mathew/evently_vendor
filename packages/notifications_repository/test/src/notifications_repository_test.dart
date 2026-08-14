import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:notifications_client/notifications_client.dart';
import 'package:notifications_repository/notifications_repository.dart';

class MockNotificationsClient extends Mock implements NotificationsClient {}

void main() {
  group('NotificationsRepository', () {
    late NotificationsClient notificationsClient;
    late NotificationsRepository repository;

    setUp(() {
      notificationsClient = MockNotificationsClient();
      repository = NotificationsRepository(
        notificationsClient: notificationsClient,
      );
    });

    test('can be instantiated', () {
      expect(
        NotificationsRepository(notificationsClient: notificationsClient),
        isNotNull,
      );
    });

    group('requestPermission', () {
      test('completes normally when client succeeds', () async {
        when(() => notificationsClient.requestPermission())
            .thenAnswer((_) async {});

        await expectLater(repository.requestPermission(), completes);
        verify(() => notificationsClient.requestPermission()).called(1);
      });

      test('throws NotificationsPermissionException on client error', () async {
        when(() => notificationsClient.requestPermission())
            .thenThrow(Exception('oops'));

        await expectLater(
          repository.requestPermission(),
          throwsA(isA<NotificationsPermissionException>()),
        );
      });
    });

    group('fetchToken', () {
      test('returns token when client succeeds', () async {
        const token = 'test_token';
        when(() => notificationsClient.fetchToken())
            .thenAnswer((_) async => token);

        final result = await repository.fetchToken();
        expect(result, equals(token));
        verify(() => notificationsClient.fetchToken()).called(1);
      });

      test('throws NotificationsTokenException on client error', () async {
        when(() => notificationsClient.fetchToken())
            .thenThrow(Exception('oops'));

        await expectLater(
          repository.fetchToken(),
          throwsA(isA<NotificationsTokenException>()),
        );
      });
    });

    group('onTokenRefresh', () {
      test('returns stream from client', () {
        const stream = Stream<String>.empty();
        when(() => notificationsClient.onTokenRefresh())
            .thenAnswer((_) => stream);

        expect(repository.onTokenRefresh(), equals(stream));
        verify(() => notificationsClient.onTokenRefresh()).called(1);
      });
    });
  });
}
