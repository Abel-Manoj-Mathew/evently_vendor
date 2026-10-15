import 'dart:async';

import 'package:authentication_client/authentication_client.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:evently_vendor/auth/mobile_number/cubit/mobile_number_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/helpers.dart';

void main() {
  late AuthenticationClient client;

  setUp(() => client = MockAuthenticationClient());

  MobileNumberCubit build() => MobileNumberCubit(authenticationClient: client);

  group('validation', () {
    test('accepts 10-digit Indian mobile numbers only', () {
      expect(
        const MobileNumberState(nationalNumber: '9876543210').isValid,
        isTrue,
      );
      expect(
        const MobileNumberState(nationalNumber: '5876543210').isValid,
        isFalse,
      );
      expect(const MobileNumberState(nationalNumber: '98765').isValid, isFalse);
    });

    test('shows a format error only for a complete but invalid number', () {
      expect(
        const MobileNumberState(nationalNumber: '12345').showFormatError,
        isFalse,
      );
      expect(
        const MobileNumberState(nationalNumber: '1234567890').showFormatError,
        isTrue,
      );
    });

    test('formats E.164', () {
      expect(
        const MobileNumberState(nationalNumber: '9876543210').e164,
        '+919876543210',
      );
    });
  });

  blocTest<MobileNumberCubit, MobileNumberState>(
    'does not send an invalid number',
    build: build,
    act: (cubit) async {
      cubit.numberChanged('123');
      await cubit.submit();
    },
    expect: () => const [MobileNumberState(nationalNumber: '123')],
    verify: (_) => verifyNever(
      () => client.sendOtp(phoneNumber: any(named: 'phoneNumber')),
    ),
  );

  blocTest<MobileNumberCubit, MobileNumberState>(
    'sends the code and reports success',
    setUp: () => when(
      () => client.sendOtp(phoneNumber: '+919876543210'),
    ).thenAnswer((_) async {}),
    build: build,
    seed: () => const MobileNumberState(nationalNumber: '9876543210'),
    act: (cubit) => cubit.submit(),
    expect: () => const [
      MobileNumberState(
        nationalNumber: '9876543210',
        status: MobileNumberStatus.sending,
      ),
      MobileNumberState(
        nationalNumber: '9876543210',
        status: MobileNumberStatus.sent,
      ),
    ],
  );

  blocTest<MobileNumberCubit, MobileNumberState>(
    'reports OTP sending failure with a reason and never reaches sent',
    setUp: () => when(
      () => client.sendOtp(phoneNumber: any(named: 'phoneNumber')),
    ).thenThrow(const SendOtpFailure(AuthFailureReason.network, 'offline')),
    build: build,
    seed: () => const MobileNumberState(nationalNumber: '9876543210'),
    act: (cubit) => cubit.submit(),
    expect: () => const [
      MobileNumberState(
        nationalNumber: '9876543210',
        status: MobileNumberStatus.sending,
      ),
      MobileNumberState(
        nationalNumber: '9876543210',
        status: MobileNumberStatus.failure,
        failureReason: AuthFailureReason.network,
      ),
    ],
  );

  blocTest<MobileNumberCubit, MobileNumberState>(
    'ignores repeated submits while a request is in flight',
    setUp: () {
      final completer = Completer<void>();
      when(
        () => client.sendOtp(phoneNumber: any(named: 'phoneNumber')),
      ).thenAnswer((_) => completer.future);
    },
    build: build,
    seed: () => const MobileNumberState(nationalNumber: '9876543210'),
    act: (cubit) {
      unawaited(cubit.submit());
      unawaited(cubit.submit());
      cubit.numberChanged('9999999999');
    },
    expect: () => const [
      MobileNumberState(
        nationalNumber: '9876543210',
        status: MobileNumberStatus.sending,
      ),
    ],
    verify: (_) => verify(
      () => client.sendOtp(phoneNumber: any(named: 'phoneNumber')),
    ).called(1),
  );

  blocTest<MobileNumberCubit, MobileNumberState>(
    'acknowledgeSent returns to initial only from sent',
    build: build,
    seed: () => const MobileNumberState(
      nationalNumber: '9876543210',
      status: MobileNumberStatus.sent,
    ),
    act: (cubit) => cubit
      ..acknowledgeSent()
      ..acknowledgeSent(),
    expect: () => const [MobileNumberState(nationalNumber: '9876543210')],
  );
}
