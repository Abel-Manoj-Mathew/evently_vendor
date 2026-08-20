import 'package:bloc/bloc.dart';
import 'package:evently_vendor/auth/mobile_number/bloc/mobile_number_event.dart';
import 'package:evently_vendor/auth/mobile_number/bloc/mobile_number_state.dart';

class MobileNumberBloc extends Bloc<MobileNumberEvent, MobileNumberState> {
  MobileNumberBloc() : super(const MobileNumberState()) {
    on<MobileNumberPhoneNumberChanged>(_onPhoneNumberChanged);
    on<MobileNumberCountryCodeChanged>(_onCountryCodeChanged);
    on<MobileNumberSubmitted>(_onSubmitted);
  }

  void _onPhoneNumberChanged(
    MobileNumberPhoneNumberChanged event,
    Emitter<MobileNumberState> emit,
  ) {
    emit(
      state.copyWith(
        phoneNumber: event.phoneNumber,
        status: MobileNumberStatus.initial,
      ),
    );
  }

  void _onCountryCodeChanged(
    MobileNumberCountryCodeChanged event,
    Emitter<MobileNumberState> emit,
  ) {
    emit(
      state.copyWith(
        countryCode: event.countryCode,
        status: MobileNumberStatus.initial,
      ),
    );
  }

  Future<void> _onSubmitted(
    MobileNumberSubmitted event,
    Emitter<MobileNumberState> emit,
  ) async {
    if (!state.isValid) return;

    emit(state.copyWith(status: MobileNumberStatus.submitting));

    try {
      await Future<void>.delayed(const Duration(milliseconds: 300));
      emit(state.copyWith(status: MobileNumberStatus.success));
    } catch (e) {
      emit(
        state.copyWith(
          status: MobileNumberStatus.failure,
          errorMessage: 'Failed to send OTP code. Please try again.',
        ),
      );
    }
  }
}
