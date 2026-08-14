import 'package:flutter_test/flutter_test.dart';
import 'package:shared/shared.dart';

void main() {
  group('Shared Utilities & Extensions', () {
    test('AppFlavor provides correct values', () {
      expect(AppFlavor.development, isNotNull);
      expect(AppFlavor.staging, isNotNull);
      expect(AppFlavor.production, isNotNull);
    });

    test('StringX capitalizes text correctly', () {
      expect('evently'.capitalize(), equals('Evently'));
      expect(
        'evently vendor app'.capitalizeWords(),
        equals('Evently Vendor App'),
      );
    });

    test('Formatter formats currency and phone numbers correctly', () {
      expect(Formatter.formatCurrency(1500), contains('1,500'));
      expect(
        Formatter.formatPhoneNumber('9876543210'),
        contains('+91 98765 43210'),
      );
    });

    test('DateTimeX formats dates and times correctly', () {
      final dt = DateTime(2026, 8, 14, 10, 30);
      expect(dt.toFormattedDate(), equals('14 Aug 2026'));
      expect(dt.toFormattedTime(), equals('10:30 AM'));
    });
  });
}
