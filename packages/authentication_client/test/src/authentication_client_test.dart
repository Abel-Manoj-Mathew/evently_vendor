import 'dart:async';

import 'package:authentication_client/authentication_client.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase/supabase.dart';
import 'package:test/test.dart';

class _MockGoTrueClient extends Mock implements GoTrueClient {}

class _MockSession extends Mock implements Session {}

class _MockUser extends Mock implements User {}

class _MockAuthResponse extends Mock implements AuthResponse {}

const _phone = '+919876543210';

User _user({String id = 'user-1', String? phone = '919876543210'}) {
  final user = _MockUser();
  when(() => user.id).thenReturn(id);
  when(() => user.phone).thenReturn(phone);
  return user;
}

Session _session(User user) {
  final session = _MockSession();
  when(() => session.user).thenReturn(user);
  return session;
}

void main() {
  late GoTrueClient auth;
  late StreamController<AuthState> authStates;
  late AuthenticationClient client;

  setUp(() {
    auth = _MockGoTrueClient();
    authStates = StreamController<AuthState>.broadcast();
    when(() => auth.onAuthStateChange).thenAnswer((_) => authStates.stream);
    client = AuthenticationClient(authClient: auth);
  });

  tearDown(() => authStates.close());

  group('changes', () {
    test('maps restored, signed-in and signed-out sessions', () async {
      final user = _user();
      final expectation = expectLater(
        client.changes,
        emitsInOrder(const [
          Unauthenticated(),
          Authenticated(AuthenticatedUser(id: 'user-1', phone: _phone)),
          Unauthenticated(),
        ]),
      );
      authStates
        ..add(const AuthState(AuthChangeEvent.initialSession, null))
        ..add(AuthState(AuthChangeEvent.signedIn, _session(user)))
        ..add(
          const AuthState(
            AuthChangeEvent.signedOut,
            null,
            signOutReason: SignOutReason.userInitiated,
          ),
        );
      await expectation;
    });

    test('collapses token refreshes for the same user', () async {
      final user = _user();
      final expectation = expectLater(
        client.changes,
        emitsInOrder(<Matcher>[
          equals(
            const Authenticated(AuthenticatedUser(id: 'user-1', phone: _phone)),
          ),
          equals(const Unauthenticated()),
        ]),
      );
      authStates
        ..add(AuthState(AuthChangeEvent.initialSession, _session(user)))
        ..add(AuthState(AuthChangeEvent.tokenRefreshed, _session(user)))
        ..add(const AuthState(AuthChangeEvent.signedOut, null));
      await expectation;
    });

    test('flags involuntary sign-outs as session expiry', () async {
      final expectation = expectLater(
        client.changes,
        emits(const Unauthenticated(sessionExpired: true)),
      );
      authStates.add(
        const AuthState(
          AuthChangeEvent.signedOut,
          null,
          signOutReason: SignOutReason.sessionExpired,
        ),
      );
      await expectation;
    });

    test('drops transient stream errors and ignores unrelated events', () {
      final user = _user();
      final expectation = expectLater(
        client.changes,
        emits(
          const Authenticated(AuthenticatedUser(id: 'user-1', phone: _phone)),
        ),
      );
      authStates
        ..addError(AuthRetryableFetchException(message: 'offline'))
        ..add(const AuthState(AuthChangeEvent.passwordRecovery, null))
        ..add(AuthState(AuthChangeEvent.signedIn, _session(user)));
      return expectation;
    });

    test('keeps phone null when the account has none', () {
      final user = _user(phone: '');
      final expectation = expectLater(
        client.changes,
        emits(const Authenticated(AuthenticatedUser(id: 'user-1'))),
      );
      authStates.add(AuthState(AuthChangeEvent.signedIn, _session(user)));
      return expectation;
    });
  });

  test('currentUser maps the Supabase user', () {
    final user = _user(phone: _phone);
    when(() => auth.currentUser).thenReturn(user);
    expect(
      client.currentUser,
      const AuthenticatedUser(id: 'user-1', phone: _phone),
    );

    when(() => auth.currentUser).thenReturn(null);
    expect(client.currentUser, isNull);
  });

  group('sendOtp', () {
    test('requests an SMS code', () async {
      when(() => auth.signInWithOtp(phone: _phone)).thenAnswer((_) async {});
      await client.sendOtp(phoneNumber: _phone);
      verify(() => auth.signInWithOtp(phone: _phone)).called(1);
    });

    final cases = <Object, AuthFailureReason>{
      AuthRetryableFetchException(message: 'offline'):
          AuthFailureReason.network,
      const AuthApiException('slow down', code: 'over_sms_send_rate_limit'):
          AuthFailureReason.rateLimited,
      const AuthApiException('slow down', statusCode: '429'):
          AuthFailureReason.rateLimited,
      const AuthApiException('provider', code: 'phone_provider_disabled'):
          AuthFailureReason.smsUnavailable,
      const AuthApiException('sms', code: 'sms_send_failed'):
          AuthFailureReason.smsUnavailable,
      const AuthApiException('bad phone', code: 'validation_failed'):
          AuthFailureReason.invalidPhoneNumber,
      const AuthApiException('?', statusCode: '400'): AuthFailureReason.unknown,
      StateError('boom'): AuthFailureReason.unknown,
    };
    for (final MapEntry(key: error, value: reason) in cases.entries) {
      test('maps $error to ${reason.name}', () {
        when(() => auth.signInWithOtp(phone: _phone)).thenThrow(error);
        expect(
          () => client.sendOtp(phoneNumber: _phone),
          throwsA(
            isA<SendOtpFailure>()
                .having((e) => e.reason, 'reason', reason)
                .having((e) => e.error, 'error', error),
          ),
        );
      });
    }
  });

  group('verifyOtp', () {
    void stubVerify(Future<AuthResponse> Function() answer) {
      when(
        () => auth.verifyOTP(
          phone: _phone,
          token: '123456',
          type: OtpType.sms,
        ),
      ).thenAnswer((_) => answer());
    }

    test('completes when a session is returned', () async {
      final response = _MockAuthResponse();
      final session = _session(_user());
      when(() => response.session).thenReturn(session);
      stubVerify(() async => response);
      await client.verifyOtp(phoneNumber: _phone, code: '123456');
    });

    test('treats a missing session as an invalid code', () {
      final response = _MockAuthResponse();
      when(() => response.session).thenReturn(null);
      stubVerify(() async => response);
      expect(
        () => client.verifyOtp(phoneNumber: _phone, code: '123456'),
        throwsA(
          isA<VerifyOtpFailure>().having(
            (e) => e.reason,
            'reason',
            AuthFailureReason.invalidOrExpiredCode,
          ),
        ),
      );
    });

    test('maps wrong or expired codes', () {
      stubVerify(
        () async => throw const AuthApiException(
          'Token has expired or is invalid',
          code: 'otp_expired',
        ),
      );
      expect(
        () => client.verifyOtp(phoneNumber: _phone, code: '123456'),
        throwsA(
          isA<VerifyOtpFailure>().having(
            (e) => e.reason,
            'reason',
            AuthFailureReason.invalidOrExpiredCode,
          ),
        ),
      );
    });

    test('maps network failures', () {
      stubVerify(
        () async => throw AuthRetryableFetchException(message: 'x'),
      );
      expect(
        () => client.verifyOtp(phoneNumber: _phone, code: '123456'),
        throwsA(
          isA<VerifyOtpFailure>().having(
            (e) => e.reason,
            'reason',
            AuthFailureReason.network,
          ),
        ),
      );
    });
  });

  group('signOut', () {
    test('signs out', () async {
      when(() => auth.signOut()).thenAnswer((_) async {});
      await client.signOut();
      verify(() => auth.signOut()).called(1);
    });

    test('wraps errors', () {
      when(() => auth.signOut()).thenThrow(Exception('x'));
      expect(client.signOut, throwsA(isA<SignOutFailure>()));
    });
  });

  test('exception toString hides the underlying error', () {
    const failure = SendOtpFailure(AuthFailureReason.network, 'secret detail');
    expect(failure.toString(), 'SendOtpFailure(network)');
  });
}
