import 'package:flutter/material.dart';

class Input extends StatefulWidget {
  final TextEditingController? controller;
  final String? label;
  final String? placeholder;
  final String? Function(String?)? validator;
  final bool obscureText;
  final TextInputType? keyboardType;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final int? maxLines;
  final bool enabled;

  const Input({
    super.key,
    this.controller,
    this.label,
    this.placeholder,
    this.validator,
    this.obscureText = false,
    this.keyboardType,
    this.prefixIcon,
    this.suffixIcon,
    this.maxLines = 1,
    this.enabled = true,
  });

  @override
  State<Input> createState() => _InputState();
}

class _InputState extends State<Input> {
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey[900],
            ),
          ),
          const SizedBox(height: 6),
        ],
        Focus(
          onFocusChange: (focused) => setState(() => _isFocused = focused),
          child: TextFormField(
            controller: widget.controller,
            obscureText: widget.obscureText,
            keyboardType: widget.keyboardType,
            enabled: widget.enabled,
            maxLines: widget.maxLines,
            validator: widget.validator,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[900],
            ),
            decoration: InputDecoration(
              hintText: widget.placeholder,
              hintStyle: TextStyle(
                fontSize: 14,
                color: Colors.grey[400],
              ),
              prefixIcon: widget.prefixIcon,
              suffixIcon: widget.suffixIcon,
              filled: true,
              fillColor: widget.enabled ? Colors.white : Colors.grey[50],
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: Theme.of(context).primaryColor,
                  width: 2,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.red[400]!, width: 1),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.red[400]!, width: 2),
              ),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey[200]!, width: 1),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
