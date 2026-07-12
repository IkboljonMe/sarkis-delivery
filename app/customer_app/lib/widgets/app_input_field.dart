import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../utils/app_colors.dart';
import '../utils/app_text_styles.dart';

/// Themed text input matching the dark design system.
class AppInputField extends StatelessWidget {
  final TextEditingController? controller;
  final String label;
  final String? hint;
  final IconData? prefixIcon;
  final Widget? suffix;
  final TextInputType keyboardType;
  final bool obscureText;
  final bool enabled;
  final int maxLines;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final TextCapitalization textCapitalization;
  final String? errorText;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;

  const AppInputField({
    super.key,
    this.controller,
    required this.label,
    this.hint,
    this.prefixIcon,
    this.suffix,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.enabled = true,
    this.maxLines = 1,
    this.inputFormatters,
    this.validator,
    this.onChanged,
    this.textCapitalization = TextCapitalization.none,
    this.errorText,
    this.textInputAction,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    final hasError = errorText != null && errorText!.isNotEmpty;
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      enabled: enabled,
      maxLines: maxLines,
      inputFormatters: inputFormatters,
      validator: validator,
      onChanged: onChanged,
      onFieldSubmitted: onSubmitted,
      textInputAction: textInputAction,
      textCapitalization: textCapitalization,
      style: AppTextStyles.body,
      cursorColor: AppColors.primary,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        errorText: hasError ? errorText : null,
        errorStyle: const TextStyle(color: AppColors.error),
        errorMaxLines: 2,
        prefixIcon: prefixIcon != null
            ? Icon(prefixIcon,
                color: hasError ? AppColors.error : AppColors.primary, size: 20)
            : null,
        suffixIcon: suffix,
      ),
    );
  }
}
