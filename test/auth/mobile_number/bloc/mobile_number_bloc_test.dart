import 'package:bloc_test/bloc_test.dart';
import 'package:evently_vendor/auth/mobile_number/bloc/mobile_number_bloc.dart';
import 'package:evently_vendor/auth/mobile_number/bloc/mobile_number_event.dart';
import 'package:evently_vendor/auth/mobile_number/bloc/mobile_number_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MobileNumberBloc', () {
    late MobileNumberBloc bloc;

    setUp(() {
      bloc = MobileNumberBloc();
    });

    tearDown(() {
      bloc.close();
    });

    test('initial state is correct', () {
      expect(bloc.state, const MobileNumberState());
      expect(bloc.state.isValid, isFalse);
    });

    blocTest<MobileNumberBloc, MobileNumberState>(
      'emits updated state when MobileNumberPhoneNumberChanged is added',
      build: MobileNumberBloc.new,
      act: (bloc) => bloc.add(const MobileNumberPhoneNumberChanged('9876543210')),
      expect: () => [
        const MobileNumberState(
          phoneNumber: '9876543210',
        ),
      ],
      verify: (bloc) {
        expect(bloc.state.isValid, isTrue);
        expect(bloc.state.fullPhoneNumber, '+919876543210');
      },
    );

    blocTest<MobileNumberBloc, MobileNumberState>(
      'emits updated country code when MobileNumberCountryCodeChanged is added',
      build: MobileNumberBloc.new,
      act: (bloc) => bloc.add(const MobileNumberCountryCodeChanged('+1')),
      expect: () => [
        const MobileNumberState(
          countryCode: '+1',
        ),
      ],
    );

    blocTest<MobileNumberBloc, MobileNumberState>(
      'does nothing when MobileNumberSubmitted is added with invalid phone number',
      build: MobileNumberBloc.new,
      act: (bloc) => bloc.add(const MobileNumberSubmitted()),
      expect: () => <MobileNumberState>[],
    );

    blocTest<MobileNumberBloc, MobileNumberState>(
      'emits submitting and success when MobileNumberSubmitted is added with valid phone number',
      build: MobileNumberBloc.new,
      seed: () => const MobileNumberState(phoneNumber: '9876543210'),
      act: (bloc) => bloc.add(const MobileNumberSubmitted()),
      wait: const Duration(milliseconds: 350),
      expect: () => [
        const MobileNumberState(
          phoneNumber: '9876543210',
          status: MobileNumberStatus.submitting,
        ),
        const MobileNumberState(
          phoneNumber: '9876543210',
          status: MobileNumberStatus.success,
        ),
      ],
    );
  });
}
