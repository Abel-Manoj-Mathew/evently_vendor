import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';

/// Variant of an [AppButton].
enum AppButtonVariant {
  /// Primary button with filled brand background (#FF4040).
  primary,

  /// Secondary button with muted background.
  secondary,

  /// Outlined button with border outline.
  outlined,

  /// Text button with no background.
  text,
}

/// {@template app_button}
/// A customized button component for Evently UI Kit.
/// {@endtemplate}
class AppButton extends StatelessWidget {
  /// {@macro app_button}
  const AppButton({
    required this.text,
    super.key,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.isLoading = false,
    this.icon,
    this.height = 48.0,
    this.width,
    this.borderRadius,
  });

  /// The button text.
  final String text;

  /// Callback when pressed.
  final VoidCallback? onPressed;

  /// The visual variant of the button.
  final AppButtonVariant variant;

  /// Whether to display a loading indicator.
  final bool isLoading;

  /// Optional icon to show before text.
  final Widget? icon;

  /// Button height (default 48.0).
  final double height;

  /// Button width (default expands to full width if null).
  final double? width;

  /// Custom border radius.
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    final effectiveBorderRadius = borderRadius ?? BorderRadius.circular(12);

    final backgroundColor = switch (variant) {
      AppButtonVariant.primary => AppColors.primary,
      AppButtonVariant.secondary => AppColors.primaryLight,
      AppButtonVariant.outlined => AppColors.transparent,
      AppButtonVariant.text => AppColors.transparent,
    };

    final textColor = switch (variant) {
      AppButtonVariant.primary => AppColors.white,
      AppButtonVariant.secondary => AppColors.primary,
      AppButtonVariant.outlined => AppColors.primary,
      AppButtonVariant.text => AppColors.primary,
    };

    final border = switch (variant) {
      AppButtonVariant.outlined => Border.all(color: AppColors.primary),
      _ => null,
    };

    final childWidget = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: width == null ? MainAxisSize.max : MainAxisSize.min,
      children: [
        if (isLoading) ...[
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(textColor),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
        ] else if (icon != null) ...[
          icon!,
          const SizedBox(width: AppSpacing.sm),
        ],
        Text(
          text,
          style: ContentTextStyle.button.copyWith(
            color: onPressed == null ? textColor.withAlpha(128) : textColor,
            fontWeight: AppFontWeight.semiBold,
          ),
        ),
      ],
    );

    return Tappable.scaled(
      onTap: isLoading ? null : onPressed,
      borderRadius: effectiveBorderRadius,
      backgroundColor: onPressed == null
          ? backgroundColor.withAlpha(128)
          : backgroundColor,
      child: Container(
        height: height,
        width: width,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        decoration: BoxDecoration(
          borderRadius: effectiveBorderRadius,
          border: border,
        ),
        child: childWidget,
      ),
    );
  }
}
