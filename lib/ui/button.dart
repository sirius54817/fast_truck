import 'package:flutter/material.dart';

enum ButtonVariant { primary, secondary, outline, ghost }
enum ButtonSize { sm, md, lg }

class Button extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final ButtonVariant variant;
  final ButtonSize size;
  final bool isLoading;
  final Icon? icon;

  const Button({
    super.key,
    required this.onPressed,
    required this.child,
    this.variant = ButtonVariant.primary,
    this.size = ButtonSize.md,
    this.isLoading = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDisabled = onPressed == null || isLoading;

    // Size configurations
    final EdgeInsets padding;
    final double height;
    final double fontSize;

    switch (size) {
      case ButtonSize.sm:
        padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 8);
        height = 36;
        fontSize = 14;
        break;
      case ButtonSize.lg:
        padding = const EdgeInsets.symmetric(horizontal: 32, vertical: 16);
        height = 48;
        fontSize = 16;
        break;
      case ButtonSize.md:
      default:
        padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 12);
        height = 40;
        fontSize = 14;
        break;
    }

    // Variant configurations
    final Color backgroundColor;
    final Color foregroundColor;
    final Border? border;

    switch (variant) {
      case ButtonVariant.primary:
        backgroundColor = isDisabled ? Colors.grey[300]! : theme.primaryColor;
        foregroundColor = isDisabled ? Colors.grey[500]! : Colors.white;
        border = null;
        break;
      case ButtonVariant.secondary:
        backgroundColor = isDisabled ? Colors.grey[200]! : Colors.grey[100]!;
        foregroundColor = isDisabled ? Colors.grey[400]! : Colors.grey[900]!;
        border = null;
        break;
      case ButtonVariant.outline:
        backgroundColor = Colors.transparent;
        foregroundColor = isDisabled ? Colors.grey[400]! : Colors.grey[900]!;
        border = Border.all(
          color: isDisabled ? Colors.grey[300]! : Colors.grey[300]!,
        );
        break;
      case ButtonVariant.ghost:
        backgroundColor = Colors.transparent;
        foregroundColor = isDisabled ? Colors.grey[400]! : Colors.grey[900]!;
        border = null;
        break;
    }

    return SizedBox(
      height: height,
      child: Material(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: isDisabled ? null : onPressed,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              border: border,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isLoading)
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: foregroundColor,
                    ),
                  )
                else ...[
                  if (icon != null) ...[
                    Icon(icon!.icon, size: 16, color: foregroundColor),
                    const SizedBox(width: 8),
                  ],
                  DefaultTextStyle(
                    style: TextStyle(
                      color: foregroundColor,
                      fontSize: fontSize,
                      fontWeight: FontWeight.w500,
                    ),
                    child: child,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
