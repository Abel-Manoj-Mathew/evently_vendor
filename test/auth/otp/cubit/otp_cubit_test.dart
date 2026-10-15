import 'dart:async';

import 'package:authentication_client/authentication_client.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:evently_vendor/auth/otp/cubit/otp_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/helpers.dart';

const _phone = '+919876543210';

void main() {
  late AuthenticationClient client;

  setUp(() => client = MockAuthenticationClient());

  OtpCubit build() =>
      OtpCubit(phoneNumber: _phone, authenticationClient: client);

  void stubVerify(Future<void> Function() answer) => when(
    () => client.verifyOtp(
      phoneNumber: any(named: 'phoneNumber'),
      code: any(named: 'code'),
    ),
  ).thenAnswer((_) => answer());

  blocTest<OtpCubit, OtpState>(
    'verifies a complete code',
    setUp: () => stubVerify(() async {}),
    build: build,
    act: (cubit) => cubit.verify('123456'),
    expect: () => const [
      OtpState(phoneNumber: _phone, status: OtpStatus.verifying),
      OtpState(phoneNumber: _phone, status: OtpStatus.verified),
    ],
    verify: (_) => verify(
      () => client.verifyOtp(phoneNumber: _phone, code: '123456'),
    ).called(1),
  );

  blocTest<OtpCubit, OtpState>(
    'ignores incomplete codes',
    build: build,
    act: (cubit) => cubit.verify('123'),
    expect: () => const <OtpState>[],
  );

  blocTest<OtpCubit, OtpState>(
    'gives invalid OTP feedback and allows another attempt',
    setUp: () => stubVerify(
      () async => throw const VerifyOtpFailure(
        AuthFailureReason.invalidOrExpiredCode,
        'otp_expired',
      ),
    ),
    build: build,
    act: (cubit) async {
      await cubit.verify('111111');
      await cubit.verify('222222');
    },
    expect: () => const [
      OtpState(phoneNumber: _phone, status: OtpStatus.verifying),
      OtpState(
        phoneNumber: _phone,
        status: OtpStatus.verificationFailed,
        failureReason: AuthFailureReason.invalidOrExpiredCode,
        attempt: 1,
      ),
      OtpState(phoneNumber: _phone, status: OtpStatus.verifying, attempt: 1),
      OtpState(
        phoneNumber: _phone,
        status: OtpStatus.verificationFailed,
        failureReason: AuthFailureReason.invalidOrExpiredCode,
        attempt: 2,
      ),
    ],
  );

  blocTest<OtpCubit, OtpState>(
    'reports network failures during verification',
    setUp: () => stubVerify(
      () async =>
          throw const VerifyOtpFailure(AuthFailureReason.network, 'offline'),
    ),
    build: build,
    act: (cubit) => cubit.verify('123456'),
    expect: () => const [
      OtpState(phoneNumber: _phone, status: OtpStatus.verifying),
      OtpState(
        phoneNumber: _phone,
        status: OtpStatus.verificationFailed,
        failureReason: AuthFailureReason.network,
        attempt: 1,
      ),
    ],
  );

  blocTest<OtpCubit, OtpState>(
    'prevents duplicate verification and resend while verifying',
    setUp: () => stubVerify(() => Completer<void>().future),
    build: build,
    act: (cubit) {
      unawaited(cubit.verify('123456'));
      unawaited(cubit.verify('123456'));
      unawaited(cubit.resend());
    },
    expect: () => const [
      OtpState(phoneNumber: _phone, status: OtpStatus.verifying),
    ],
    verify: (_) {
      verify(
        () => client.verifyOtp(
          phoneNumber: any(named: 'phoneNumber'),
          code: any(named: 'code'),
        ),
      ).called(1);
      verifyNever(() => client.sendOtp(phoneNumber: any(named: 'phoneNumber')));
    },
  );

  blocTest<OtpCubit, OtpState>(
    'ignores input after a successful verification',
    build: build,
    seed: () => const OtpState(phoneNumber: _phone, status: OtpStatus.verified),
    act: (cubit) => cubit.verify('123456'),
    expect: () => const <OtpState>[],
  );

  group('resend', () {
    blocTest<OtpCubit, OtpState>(
      'sends a new code',
      setUp: () => when(
        () => client.sendOtp(phoneNumber: _phone),
      ).thenAnswer((_) async {}),
      build: build,
      act: (cubit) => cubit.resend(),
      expect: () => const [
        OtpState(phoneNumber: _phone, status: OtpStatus.resending),
        OtpState(phoneNumber: _phone, status: OtpStatus.resent, attempt: 1),
      ],
    );

    blocTest<OtpCubit, OtpState>(
      'reports rate limiting',
      setUp: () => when(() => client.sendOtp(phoneNumber: _phone)).thenThrow(
        const SendOtpFailure(AuthFailureReason.rateLimited, '429'),
      ),
      build: build,
      act: (cubit) => cubit.resend(),
      expect: () => const [
        OtpState(phoneNumber: _phone, status: OtpStatus.resending),
        OtpState(
          phoneNumber: _phone,
          status: OtpStatus.resendFailed,
          failureReason: AuthFailureReason.rateLimited,
          attempt: 1,
        ),
      ],
    );
  });
}
