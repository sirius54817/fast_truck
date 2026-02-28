import 'package:flutter/material.dart';

class CardWidget extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final VoidCallback? onTap;

  const CardWidget({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final content = Container(
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!, width: 1),
      ),
      child: child,
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: content,
        ),
      );
    }

    return content;
  }
}

class CardHeader extends StatelessWidget {
  final Widget? title;
  final Widget? description;

  const CardHeader({
    super.key,
    this.title,
    this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null)
          DefaultTextStyle(
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[900],
            ),
            child: title!,
          ),
        if (description != null) ...[
          const SizedBox(height: 4),
          DefaultTextStyle(
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
            child: description!,
          ),
        ],
      ],
    );
  }
}
