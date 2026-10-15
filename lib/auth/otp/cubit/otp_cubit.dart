import 'package:authentication_client/authentication_client.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'otp_state.dart';

/// Verifies the SMS code sent to a phone number and resends it on request.
///
/// A successful verification signs the user in; navigation then follows
/// from the app-level authentication state, not from this cubit.
class OtpCubit extends Cubit<OtpState> {
  OtpCubit({
    required String phoneNumber,
    required this._authenticationClient,
  }) : super(OtpState(phoneNumber: phoneNumber));

  static const codeLength = 6;

  final AuthenticationClient _authenticationClient;

  bool get _busy =>
      state.status == OtpStatus.verifying ||
      state.status == OtpStatus.resending ||
      state.status == OtpStatus.verified;

  Future<void> verify(String code) async {
    if (_busy || code.length != codeLength) return;
    emit(state.copyWith(status: OtpStatus.verifying));
    try {
      await _authenticationClient.verifyOtp(
        phoneNumber: state.phoneNumber,
        code: code,
      );
      emit(state.copyWith(status: OtpStatus.verified));
    } on VerifyOtpFailure catch (failure) {
      emit(
        state.copyWith(
          status: OtpStatus.verificationFailed,
          failureReason: failure.reason,
          attempt: state.attempt + 1,
        ),
      );
    }
  }

  Future<void> resend() async {
    if (_busy) return;
    emit(state.copyWith(status: OtpStatus.resending));
    try {
      await _authenticationClient.sendOtp(phoneNumber: state.phoneNumber);
      emit(
        state.copyWith(status: OtpStatus.resent, attempt: state.attempt + 1),
      );
    } on SendOtpFailure catch (failure) {
      emit(
        state.copyWith(
          status: OtpStatus.resendFailed,
          failureReason: failure.reason,
          attempt: state.attempt + 1,
        ),
      );
    }
  }
}
