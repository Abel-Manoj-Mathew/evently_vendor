import 'package:authentication_client/authentication_client.dart';

/// User-facing text for authentication failures. Raw backend errors are
/// never shown.
extension AuthFailureMessage on AuthFailureReason {
  String get message => switch (this) {
    AuthFailureReason.invalidPhoneNumber =>
      'That mobile number was not accepted. Check it and try again.',
    AuthFailureReason.invalidOrExpiredCode =>
      'That code is incorrect or has expired. Check the SMS or request a '
          'new code.',
    AuthFailureReason.rateLimited =>
      'Too many attempts. Please wait a minute and try again.',
    AuthFailureReason.network =>
      "Couldn't connect. Check your internet connection and try again.",
    AuthFailureReason.smsUnavailable =>
      "We couldn't send an SMS right now. Please try again later.",
    AuthFailureReason.unknown => 'Something went wrong. Please try again.',
  };
}
