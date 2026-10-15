import 'package:authentication_client/src/authentication_exception.dart';
import 'package:authentication_client/src/models/models.dart';
import 'package:supabase/supabase.dart';

/// {@template authentication_client}
/// Phone OTP authentication backed by Supabase Auth.
///
/// This is the only place in the app that talks to Supabase Auth directly.
/// {@endtemplate}
class AuthenticationClient {
  /// {@macro authentication_client}
  const AuthenticationClient({required GoTrueClient authClient})
    : _auth = authClient;

  final GoTrueClient _auth;

  /// Emits whenever the signed-in user changes.
  ///
  /// Supabase replays the session restored at startup, so the first event
  /// reflects the persisted session. Token refreshes for the same user are
  /// collapsed. Transient refresh failures (for example while offline) are
  /// surfaced by Supabase as stream errors and are dropped here: the session
  /// is kept and retried, and a refresh that is definitively rejected
  /// arrives as a sign-out with [Unauthenticated.sessionExpired] set.
  Stream<AuthenticationChange> get changes => _auth.onAuthStateChange
      .handleError((Object _) {})
      .map(_toChange)
      .where((change) => change != null)
      .cast<AuthenticationChange>()
      .distinct();

  /// The currently signed-in user, if any.
  AuthenticatedUser? get currentUser => _toUser(_auth.currentUser);

  /// Sends a one-time password by SMS to [phoneNumber] (E.164 format).
  ///
  /// Throws a [SendOtpFailure] on error.
  Future<void> sendOtp({required String phoneNumber}) async {
    try {
      await _auth.signInWithOtp(phone: phoneNumber);
    } on Object catch (error, stackTrace) {
      Error.throwWithStackTrace(
        SendOtpFailure(classifyAuthError(error), error),
        stackTrace,
      );
    }
  }

  /// Verifies the SMS [code] sent to [phoneNumber], signing the user in.
  ///
  /// Throws a [VerifyOtpFailure] on error.
  Future<void> verifyOtp({
    required String phoneNumber,
    required String code,
  }) async {
    try {
      final response = await _auth.verifyOTP(
        phone: phoneNumber,
        token: code,
        type: OtpType.sms,
      );
      if (response.session == null) {
        throw const AuthException('No session returned', code: 'otp_expired');
      }
    } on Object catch (error, stackTrace) {
      Error.throwWithStackTrace(
        VerifyOtpFailure(classifyAuthError(error), error),
        stackTrace,
      );
    }
  }

  /// Signs out and clears the locally persisted session.
  ///
  /// The local session is removed even when the server cannot be reached.
  /// Throws a [SignOutFailure] on error.
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } on Object catch (error, stackTrace) {
      Error.throwWithStackTrace(
        SignOutFailure(classifyAuthError(error), error),
        stackTrace,
      );
    }
  }

  static AuthenticationChange? _toChange(AuthState state) {
    switch (state.event) {
      case AuthChangeEvent.initialSession:
      case AuthChangeEvent.signedIn:
      case AuthChangeEvent.tokenRefreshed:
      case AuthChangeEvent.userUpdated:
        final user = _toUser(state.session?.user);
        return user == null ? const Unauthenticated() : Authenticated(user);
      case AuthChangeEvent.signedOut:
        return Unauthenticated(
          sessionExpired:
              state.signOutReason != null &&
              state.signOutReason != SignOutReason.userInitiated,
        );
      // Required for exhaustiveness; Supabase never emits this event.
      // ignore: deprecated_member_use
      case AuthChangeEvent.userDeleted:
      case AuthChangeEvent.passwordRecovery:
      case AuthChangeEvent.mfaChallengeVerified:
        return null;
    }
  }

  static AuthenticatedUser? _toUser(User? user) {
    if (user == null) return null;
    final phone = user.phone;
    return AuthenticatedUser(
      id: user.id,
      phone: phone == null || phone.isEmpty
          ? null
          : (phone.startsWith('+') ? phone : '+$phone'),
    );
  }
}
