import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'custom_text.dart';

enum ButtonVariant { solid, outline, text, gradient }

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonVariant variant;
  final bool isLoading;
  final Widget? icon;
  final double? width;
  final double height;
  final Color? backgroundColor;
  final Color? textColor;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.variant = ButtonVariant.solid,
    this.isLoading = false,
    this.icon,
    this.width,
    this.height = 54.0,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    Widget childWidget = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null && !isLoading) ...[icon!, const SizedBox(width: 10)],
        if (isLoading)
          const SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          )
        else
          CustomText(
            text,
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: _getTextColor(theme, isDark),
          ),
      ],
    );

    Widget button;

    switch (variant) {
      case ButtonVariant.gradient:
        button = Container(
          width: width ?? double.infinity,
          height: height,
          decoration: BoxDecoration(
            gradient: onPressed != null ? AppColors.primaryGradient : null,
            color: onPressed == null ? AppColors.textDisabled : null,
            borderRadius: BorderRadius.circular(16),
            boxShadow: onPressed != null
                ? [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: isLoading ? null : onPressed,
              borderRadius: BorderRadius.circular(16),
              child: Center(child: childWidget),
            ),
          ),
        );
        break;

      case ButtonVariant.outline:
        button = SizedBox(
          width: width ?? double.infinity,
          height: height,
          child: OutlinedButton(
            onPressed: isLoading ? null : onPressed,
            style: OutlinedButton.styleFrom(
              side: BorderSide(
                color: backgroundColor ?? AppColors.primary,
                width: 1.5,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: childWidget,
          ),
        );
        break;

      case ButtonVariant.text:
        button = SizedBox(
          width: width,
          height: height,
          child: TextButton(
            onPressed: isLoading ? null : onPressed,
            child: childWidget,
          ),
        );
        break;

      case ButtonVariant.solid:
      default:
        button = SizedBox(
          width: width ?? double.infinity,
          height: height,
          child: ElevatedButton(
            onPressed: isLoading ? null : onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: backgroundColor ?? AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: childWidget,
          ),
        );
    }

    return button;
  }

  Color _getTextColor(ThemeData theme, bool isDark) {
    if (textColor != null) return textColor!;
    switch (variant) {
      case ButtonVariant.solid:
      case ButtonVariant.gradient:
        return Colors.white;
      case ButtonVariant.outline:
        return backgroundColor ?? AppColors.primary;
      case ButtonVariant.text:
        return AppColors.secondary;
    }
  }
}
