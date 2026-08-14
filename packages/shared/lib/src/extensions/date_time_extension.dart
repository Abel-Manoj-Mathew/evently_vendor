import 'package:intl/intl.dart';

/// Extension on [DateTime] providing formatting utilities for Evently.
extension DateTimeX on DateTime {
  /// Formats date to 'dd MMM yyyy' (e.g., 14 Aug 2026).
  String toFormattedDate() => DateFormat('dd MMM yyyy').format(this);

  /// Formats time to 'hh:mm a' (e.g., 10:30 AM).
  String toFormattedTime() => DateFormat('hh:mm a').format(this);

  /// Formats full date & time (e.g., 14 Aug 2026, 10:30 AM).
  String toFormattedDateTime() =>
      DateFormat('dd MMM yyyy, hh:mm a').format(this);

  /// Returns true if this date is today.
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  /// Returns true if this date is in the future.
  bool get isUpcoming => isAfter(DateTime.now());
}
