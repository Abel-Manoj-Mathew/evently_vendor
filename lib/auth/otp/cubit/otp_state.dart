part of 'otp_cubit.dart';

enum OtpStatus {
  initial,
  verifying,
  verified,
  verificationFailed,
  resending,
  resent,
  resendFailed,
}

final class OtpState extends Equatable {
  const OtpState({
    required this.phoneNumber,
    this.status = OtpStatus.initial,
    this.failureReason,
    this.attempt = 0,
  });

  /// E.164 phone number the code was sent to.
  final String phoneNumber;
  final OtpStatus status;

  /// Set when [status] is a failure.
  final AuthFailureReason? failureReason;

  /// Incremented on every verification or resend outcome so repeated
  /// identical failures are still delivered to listeners.
  final int attempt;

  bool get isBusy =>
      status == OtpStatus.verifying ||
      status == OtpStatus.resending ||
      status == OtpStatus.verified;

  OtpState copyWith({
    OtpStatus? status,
    AuthFailureReason? failureReason,
    int? attempt,
  }) {
    return OtpState(
      phoneNumber: phoneNumber,
      status: status ?? this.status,
      failureReason: failureReason,
      attempt: attempt ?? this.attempt,
    );
  }

  @override
  List<Object?> get props => [phoneNumber, status, failureReason, attempt];
}
