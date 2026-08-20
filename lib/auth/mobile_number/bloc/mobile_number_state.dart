import 'package:equatable/equatable.dart';

enum MobileNumberStatus { initial, submitting, success, failure }

class MobileNumberState extends Equatable {
  const MobileNumberState({
    this.phoneNumber = '',
    this.countryCode = '+91',
    this.status = MobileNumberStatus.initial,
    this.errorMessage,
  });

  final String phoneNumber;
  final String countryCode;
  final MobileNumberStatus status;
  final String? errorMessage;

  bool get isValid => phoneNumber.replaceAll(RegExp(r'\D'), '').length == 10;
  String get fullPhoneNumber => '$countryCode$phoneNumber';

  MobileNumberState copyWith({
    String? phoneNumber,
    String? countryCode,
    MobileNumberStatus? status,
    String? errorMessage,
  }) {
    return MobileNumberState(
      phoneNumber: phoneNumber ?? this.phoneNumber,
      countryCode: countryCode ?? this.countryCode,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [phoneNumber, countryCode, status, errorMessage];
}
