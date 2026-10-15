part of 'mobile_number_cubit.dart';

enum MobileNumberStatus { initial, sending, sent, failure }

final class MobileNumberState extends Equatable {
  const MobileNumberState({
    this.countryCode = PhoneNumber.indiaCountryCode,
    this.nationalNumber = '',
    this.status = MobileNumberStatus.initial,
    this.failureReason,
  });

  final String countryCode;
  final String nationalNumber;
  final MobileNumberStatus status;

  /// Set when [status] is [MobileNumberStatus.failure].
  final AuthFailureReason? failureReason;

  bool get isValid => PhoneNumber.isValidIndianMobile(nationalNumber);

  /// Whether to show a format hint: only once a full-length number has been
  /// typed, so the user is not scolded while still typing.
  bool get showFormatError => nationalNumber.length == 10 && !isValid;

  String get e164 => PhoneNumber.toE164(countryCode, nationalNumber);

  MobileNumberState copyWith({
    MobileNumberStatus? status,
    AuthFailureReason? failureReason,
  }) {
    return MobileNumberState(
      countryCode: countryCode,
      nationalNumber: nationalNumber,
      status: status ?? this.status,
      failureReason: failureReason,
    );
  }

  @override
  List<Object?> get props => [
    countryCode,
    nationalNumber,
    status,
    failureReason,
  ];
}
