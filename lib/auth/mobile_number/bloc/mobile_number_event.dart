import 'package:equatable/equatable.dart';

sealed class MobileNumberEvent extends Equatable {
  const MobileNumberEvent();

  @override
  List<Object?> get props => [];
}

final class MobileNumberPhoneNumberChanged extends MobileNumberEvent {
  const MobileNumberPhoneNumberChanged(this.phoneNumber);

  final String phoneNumber;

  @override
  List<Object?> get props => [phoneNumber];
}

final class MobileNumberCountryCodeChanged extends MobileNumberEvent {
  const MobileNumberCountryCodeChanged(this.countryCode);

  final String countryCode;

  @override
  List<Object?> get props => [countryCode];
}

final class MobileNumberSubmitted extends MobileNumberEvent {
  const MobileNumberSubmitted();
}
