import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_dimensions.dart';
import 'app_loader.dart';

enum AppButtonVariant { primary, secondary, outlined, text }

/// Reusable application button supporting multiple visual variants and loading state.
class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final bool isLoading;
  final IconData? icon;
  final bool fullWidth;
  final double height;
  final Color? customBackgroundColor;
  final Color? customForegroundColor;

  const AppButton({
    super.key,
    required this.text,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.isLoading = false,
    this.icon,
    this.fullWidth = true,
    this.height = AppDimensions.buttonHeight,
    this.customBackgroundColor,
    this.customForegroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    Widget child;
    if (isLoading) {
      final loaderColor = variant == AppButtonVariant.primary
          ? Colors.white
          : theme.colorScheme.primary;
      child = AppLoader(size: 20, color: loaderColor);
    } else {
      child = Row(
        mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 18),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
            ),
          ),
        ],
      );
    }

    Widget buttonWidget;
    switch (variant) {
      case AppButtonVariant.primary:
        buttonWidget = ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: customBackgroundColor ?? AppColors.primary,
            foregroundColor: customForegroundColor ?? Colors.white,
            elevation: 2,
            shadowColor: AppColors.primary.withOpacity(0.35),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            minimumSize: Size(fullWidth ? double.infinity : 0, height),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: child,
        );
        break;

      case AppButtonVariant.secondary:
        buttonWidget = ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: customBackgroundColor ??
                (isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9)),
            foregroundColor: customForegroundColor ??
                (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            minimumSize: Size(fullWidth ? double.infinity : 0, height),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: BorderSide(
                color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                width: 1,
              ),
            ),
          ),
          child: child,
        );
        break;

      case AppButtonVariant.outlined:
        buttonWidget = OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: customForegroundColor ?? theme.colorScheme.primary,
            side: BorderSide(
              color: customBackgroundColor ?? theme.colorScheme.primary,
              width: 1.5,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            minimumSize: Size(fullWidth ? double.infinity : 0, height),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: child,
        );
        break;

      case AppButtonVariant.text:
        buttonWidget = TextButton(
          onPressed: isLoading ? null : onPressed,
          style: TextButton.styleFrom(
            foregroundColor: customForegroundColor ?? theme.colorScheme.primary,
            minimumSize: Size(fullWidth ? double.infinity : 0, height),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: child,
        );
        break;
    }

    if (fullWidth) {
      return SizedBox(
        width: double.infinity,
        height: height,
        child: buttonWidget,
      );
    }
    return SizedBox(height: height, child: buttonWidget);
  }
}
