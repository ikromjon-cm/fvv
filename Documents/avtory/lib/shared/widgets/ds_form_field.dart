import 'package:flutter/material.dart';
import '../../core/constants/design_tokens.dart';
import '../../core/responsive/responsive.dart';

class DsFormField extends StatelessWidget {
  const DsFormField({
    super.key,
    required this.label,
    this.hintText,
    this.helperText,
    this.errorText,
    this.required = false,
    this.controller,
    this.keyboardType,
    this.validator,
    this.obscureText = false,
    this.prefixIcon,
    this.suffixIcon,
    this.maxLines = 1,
    this.maxLength,
    this.textCapitalization = TextCapitalization.none,
    this.onChanged,
  });

  final String label;
  final String? hintText;
  final String? helperText;
  final String? errorText;
  final bool required;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final bool obscureText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final int? maxLines;
  final int? maxLength;
  final TextCapitalization textCapitalization;
  final void Function(String)? onChanged;

  @override
  Widget build(BuildContext context) {
    final hasError = errorText != null && errorText!.isNotEmpty;

    return Semantics(
      container: true,
      label: label,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (label.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(bottom: context.spSM),
              child: RichText(
                text: TextSpan(
                  style: context.bodyMedium(color: context.cTextPrimary),
                  children: [
                    TextSpan(text: label),
                    if (required)
                      TextSpan(
                        text: ' *',
                        style: TextStyle(color: context.cDanger),
                      ),
                  ],
                ),
              ),
            ),
          TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            validator: validator,
            obscureText: obscureText,
            maxLines: maxLines,
            maxLength: maxLength,
            textCapitalization: textCapitalization,
            onChanged: onChanged,
            style: context.bodyMedium(color: context.cTextPrimary),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: context.bodyMedium(color: context.cTextTertiary),
              helperText: hasError ? null : helperText,
              helperStyle: context.bodySmall(color: context.cTextTertiary),
              helperMaxLines: 2,
              errorText: hasError ? errorText : null,
              errorStyle: context.bodySmall(color: context.cDanger),
              errorMaxLines: 3,
              prefixIcon: prefixIcon,
              suffixIcon: suffixIcon,
              filled: true,
              fillColor: context.cFieldFill,
              contentPadding: EdgeInsets.symmetric(
                horizontal: context.spMD,
                vertical: context.spSM,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(context.radiusMD),
                borderSide: BorderSide(color: context.cBorder),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(context.radiusMD),
                borderSide: BorderSide(color: context.cBorder),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(context.radiusMD),
                borderSide:
                    BorderSide(color: context.cPrimary, width: 1.5),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(context.radiusMD),
                borderSide: BorderSide(color: context.cDanger),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(context.radiusMD),
                borderSide:
                    BorderSide(color: context.cDanger, width: 1.5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
