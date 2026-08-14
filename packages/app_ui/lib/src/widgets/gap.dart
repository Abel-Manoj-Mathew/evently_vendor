import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';

/// {@template gap}
/// A responsive spacing widget for Flex layouts (Row / Column).
/// {@endtemplate}
class Gap extends StatelessWidget {
  /// Custom size gap.
  const Gap(this.size, {super.key});

  /// Extra small gap (4px).
  const Gap.xs({super.key}) : size = AppSpacing.xs;

  /// Small gap (8px).
  const Gap.sm({super.key}) : size = AppSpacing.sm;

  /// Medium gap (16px).
  const Gap.md({super.key}) : size = AppSpacing.md;

  /// Large gap (24px).
  const Gap.lg({super.key}) : size = AppSpacing.lg;

  /// Extra large gap (32px).
  const Gap.xl({super.key}) : size = AppSpacing.xl;

  /// The gap size in logical pixels.
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
    );
  }
}
