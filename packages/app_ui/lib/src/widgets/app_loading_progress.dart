import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';

/// {@template app_loading_progress}
/// A centered circular progress indicator using Evently primary color.
/// {@endtemplate}
class AppLoadingProgress extends StatelessWidget {
  /// {@macro app_loading_progress}
  const AppLoadingProgress({
    super.key,
    this.color,
    this.size = 32.0,
    this.strokeWidth = 3.0,
  });

  /// Custom color override (defaults to Evently primary red).
  final Color? color;

  /// Size of the circular loader indicator.
  final double size;

  /// Stroke width of the circular progress line.
  final double strokeWidth;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: size,
        height: size,
        child: CircularProgressIndicator(
          strokeWidth: strokeWidth,
          valueColor: AlwaysStoppedAnimation<Color>(
            color ?? AppColors.primary,
          ),
        ),
      ),
    );
  }
}
