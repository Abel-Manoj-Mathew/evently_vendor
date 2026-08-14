import 'dart:async';
import 'package:flutter/foundation.dart';

/// {@template debouncer}
/// A simple debouncer utility to delay execution of actions
/// (e.g. search inputs).
/// {@endtemplate}
class Debouncer {
  /// {@macro debouncer}
  Debouncer({this.duration = const Duration(milliseconds: 300)});

  /// Duration to wait before executing the callback.
  final Duration duration;

  Timer? _timer;

  /// Runs [action] after [duration]. Cancels any previously scheduled action.
  void run(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(duration, action);
  }

  /// Cancels any active timer.
  void cancel() {
    _timer?.cancel();
  }

  /// Disposes the debouncer.
  void dispose() {
    _timer?.cancel();
  }
}
