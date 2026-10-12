import 'package:flutter/material.dart';
import '../core/constants/app_dimensions.dart';

/// Reusable application card widget with subtle elevation and border styling.
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final Color? borderColor;
  final double? borderRadius;
  final double? elevation;

  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppDimensions.md),
    this.margin,
    this.onTap,
    this.backgroundColor,
    this.borderColor,
    this.borderRadius,
    this.elevation,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final radius = borderRadius ?? AppDimensions.radiusLg;

    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radius),
      side: borderColor != null
          ? BorderSide(color: borderColor!, width: 1)
          : (theme.cardTheme.shape as RoundedRectangleBorder?)?.side ??
              BorderSide.none,
    );

    final card = Card(
      color: backgroundColor ?? theme.cardTheme.color,
      elevation: elevation ?? theme.cardTheme.elevation ?? AppDimensions.cardElevation,
      margin: margin ?? EdgeInsets.zero,
      shape: shape,
      clipBehavior: Clip.antiAlias,
      child: onTap != null
          ? InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(radius),
              child: Padding(
                padding: padding,
                child: child,
              ),
            )
          : Padding(
              padding: padding,
              child: child,
            ),
    );

    return card;
  }
}
