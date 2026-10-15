/// Validation for the mobile numbers vendors sign in with.
///
/// Sign-in is limited to Indian mobile numbers until a country picker is
/// added: 10 digits starting with 6–9, sent to Supabase in E.164 format.
abstract final class PhoneNumber {
  static const indiaCountryCode = '+91';

  static final _indianMobile = RegExp(r'^[6-9]\d{9}$');

  /// Whether [nationalNumber] is a valid Indian mobile number.
  static bool isValidIndianMobile(String nationalNumber) =>
      _indianMobile.hasMatch(nationalNumber);

  /// Formats [nationalNumber] as E.164, e.g. `+919876543210`.
  static String toE164(String countryCode, String nationalNumber) =>
      '$countryCode$nationalNumber';

  /// Formats an E.164 Indian number for display, e.g. `+91 98765 43210`.
  static String display(String e164) {
    if (!e164.startsWith(indiaCountryCode) || e164.length != 13) return e164;
    final national = e164.substring(3);
    return '$indiaCountryCode ${national.substring(0, 5)} '
        '${national.substring(5)}';
  }
}
