import 'package:authentication_client/authentication_client.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:evently_vendor/auth/shared/phone_number.dart';

part 'mobile_number_state.dart';

/// Validates the vendor's mobile number and requests a sign-in code.
class MobileNumberCubit extends Cubit<MobileNumberState> {
  MobileNumberCubit({required this._authenticationClient})
    : super(const MobileNumberState());

  final AuthenticationClient _authenticationClient;

  void numberChanged(String nationalNumber) {
    if (state.status == MobileNumberStatus.sending) return;
    emit(
      MobileNumberState(
        countryCode: state.countryCode,
        nationalNumber: nationalNumber,
      ),
    );
  }

  /// Sends the code. Ignored while a request is in flight or when the
  /// number is invalid, so double taps cannot send two SMS messages.
  Future<void> submit() async {
    if (!state.isValid || state.status == MobileNumberStatus.sending) return;
    emit(state.copyWith(status: MobileNumberStatus.sending));
    try {
      await _authenticationClient.sendOtp(phoneNumber: state.e164);
      emit(state.copyWith(status: MobileNumberStatus.sent));
    } on SendOtpFailure catch (failure) {
      emit(
        state.copyWith(
          status: MobileNumberStatus.failure,
          failureReason: failure.reason,
        ),
      );
    }
  }

  /// Returns to [MobileNumberStatus.initial] after the code-sent state has
  /// been handled, so returning to this screen does not re-navigate.
  void acknowledgeSent() {
    if (state.status != MobileNumberStatus.sent) return;
    emit(state.copyWith(status: MobileNumberStatus.initial));
  }
}
