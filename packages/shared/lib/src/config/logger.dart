import 'dart:developer' as developer;

/// Log error method for printing errors.
void logE(
  dynamic message, {
  DateTime? time,
  Object? error,
  StackTrace? stackTrace,
}) => developer.log(
  message.toString(),
  name: 'EVENTLY_ERROR',
  time: time,
  error: error,
  stackTrace: stackTrace,
  level: 1000,
);

/// Log warning for printing warning messages.
void logW(
  dynamic message, {
  DateTime? time,
  Object? error,
  StackTrace? stackTrace,
}) => developer.log(
  message.toString(),
  name: 'EVENTLY_WARNING',
  time: time,
  error: error,
  stackTrace: stackTrace,
  level: 900,
);

/// Log info method for printing info messages.
void logI(
  dynamic message, {
  DateTime? time,
  Object? error,
  StackTrace? stackTrace,
}) => developer.log(
  message.toString(),
  name: 'EVENTLY_INFO',
  time: time,
  error: error,
  stackTrace: stackTrace,
  level: 800,
);

/// Log debug method for debug mode logging.
void logD(
  dynamic message, {
  DateTime? time,
  Object? error,
  StackTrace? stackTrace,
}) => developer.log(
  message.toString(),
  name: 'EVENTLY_DEBUG',
  time: time,
  error: error,
  stackTrace: stackTrace,
  level: 500,
);
