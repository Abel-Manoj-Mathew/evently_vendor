import 'package:supabase/supabase.dart';

/// Why an authentication request failed, safe to show to users.
enum AuthFailureReason {
  /// The phone number was rejected by the server.
  invalidPhoneNumber,

  /// The verification code is wrong or has expired.
  invalidOrExpiredCode,

  /// Too many attempts; the user must wait before retrying.
  rateLimited,

  /// The device could not reach the server.
  network,

  /// SMS sign-in is disabled or the SMS provider failed.
  smsUnavailable,

  /// Anything else. Details are kept out of the UI.
  unknown,
}

/// {@template authentication_exception}
/// Base class for authentication failures.
///
/// [reason] is meant for the UI; [error] keeps the original cause for
/// diagnostics and must not be shown to users.
/// {@endtemplate}
sealed class AuthenticationException implements Exception {
  /// {@macro authentication_exception}
  const AuthenticationException(this.reason, this.error);

  /// User-presentable classification of the failure.
  final AuthFailureReason reason;

  /// The underlying error.
  final Object error;

  @override
  String toString() {
    final name = switch (this) {
      SendOtpFailure() => 'SendOtpFailure',
      VerifyOtpFailure() => 'VerifyOtpFailure',
      SignOutFailure() => 'SignOutFailure',
    };
    return '$name(${reason.name})';
  }
}

/// {@template send_otp_failure}
/// Sending a one-time password failed.
/// {@endtemplate}
final class SendOtpFailure extends AuthenticationException {
  /// {@macro send_otp_failure}
  const SendOtpFailure(super.reason, super.error);
}

/// {@template verify_otp_failure}
/// Verifying a one-time password failed.
/// {@endtemplate}
final class VerifyOtpFailure extends AuthenticationException {
  /// {@macro verify_otp_failure}
  const VerifyOtpFailure(super.reason, super.error);
}

/// {@template sign_out_failure}
/// Signing out failed.
/// {@endtemplate}
final class SignOutFailure extends AuthenticationException {
  /// {@macro sign_out_failure}
  const SignOutFailure(super.reason, super.error);
}

/// Maps a Supabase Auth error to an [AuthFailureReason].
AuthFailureReason classifyAuthError(Object error) {
  if (error is AuthRetryableFetchException) return AuthFailureReason.network;
  if (error is! AuthException) return AuthFailureReason.unknown;
  switch (error.code) {
    case 'otp_expired':
      return AuthFailureReason.invalidOrExpiredCode;
    case 'over_sms_send_rate_limit':
    case 'over_request_rate_limit':
      return AuthFailureReason.rateLimited;
    case 'sms_send_failed':
    case 'phone_provider_disabled':
    case 'otp_disabled':
      return AuthFailureReason.smsUnavailable;
    case 'validation_failed':
      return AuthFailureReason.invalidPhoneNumber;
  }
  if (error.statusCode == '429') return AuthFailureReason.rateLimited;
  return AuthFailureReason.unknown;
}
