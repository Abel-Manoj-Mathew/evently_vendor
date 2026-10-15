/// Normalization and comparison rules for customer phone numbers.
///
/// Customer phones are optional and may be shared (for example by family
/// members), so matching numbers only produce a duplicate warning. Rules
/// are lenient so legitimate international numbers are accepted.
abstract final class CustomerPhone {
  /// Fewest digits accepted; rules out obvious typos.
  static const minDigits = 7;

  /// Most digits accepted; the E.164 maximum.
  static const maxDigits = 15;

  static final _allowed = RegExp(r'^\+?[\d\s\-().]+$');
  static final _indianMobile = RegExp(r'^[6-9]\d{9}$');

  /// Whether [input] is empty (phone is optional) or a plausible number.
  static bool isValid(String input) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) return true;
    if (!_allowed.hasMatch(trimmed)) return false;
    final digits = _digits(trimmed);
    return digits.length >= minDigits && digits.length <= maxDigits;
  }

  /// Returns a canonical form for storage, or `null` when [input] is empty.
  ///
  /// A bare 10-digit Indian mobile number is stored as `+91…`; numbers that
  /// start with `+` keep their country code; anything else keeps its digits.
  static String? normalize(String input) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) return null;
    final digits = _digits(trimmed);
    if (trimmed.startsWith('+')) return '+$digits';
    if (_indianMobile.hasMatch(digits)) return '+91$digits';
    if (digits.length == 11 && digits.startsWith('0')) {
      final national = digits.substring(1);
      if (_indianMobile.hasMatch(national)) return '+91$national';
    }
    return digits;
  }

  /// Whether two stored or typed numbers likely refer to the same phone.
  ///
  /// Compares digits only, and treats numbers as matching when their last
  /// ten digits agree so `98765 43210` matches `+91 98765 43210`.
  static bool isLikelySame(String a, String b) {
    final left = _digits(a);
    final right = _digits(b);
    if (left.isEmpty || right.isEmpty) return false;
    if (left == right) return true;
    if (left.length < 10 || right.length < 10) return false;
    return left.substring(left.length - 10) ==
        right.substring(right.length - 10);
  }

  static String _digits(String value) => value.replaceAll(RegExp(r'\D'), '');
}
