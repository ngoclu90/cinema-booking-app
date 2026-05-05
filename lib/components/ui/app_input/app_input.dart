import 'package:flutter/material.dart';

import '../../../design_system/tokens/index.dart';

class AppInput extends StatelessWidget {
  final TextEditingController? controller;
  final String? initialValue;
  final String? placeholder;
  final bool secureTextEntry;
  final TextInputType? keyboardType;
  final String? error;
  final Widget? leftIcon;
  final Widget? rightIcon;
  final ValueChanged<String>? onChanged;
  final String? Function(String?)? validator;
  final TextInputAction? textInputAction;
  final VoidCallback? onEditingComplete;

  const AppInput({
    super.key,
    this.controller,
    this.initialValue,
    this.placeholder,
    this.secureTextEntry = false,
    this.keyboardType,
    this.error,
    this.leftIcon,
    this.rightIcon,
    this.onChanged,
    this.validator,
    this.textInputAction,
    this.onEditingComplete,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      initialValue: controller == null ? initialValue : null,
      obscureText: secureTextEntry,
      keyboardType: keyboardType,
      onChanged: onChanged,
      validator: validator,
      textInputAction: textInputAction,
      onEditingComplete: onEditingComplete,
      style: AppTypography.body.copyWith(color: AppColors.textPrimary),
      decoration: InputDecoration(
        hintText: placeholder,
        errorText: error,
        prefixIcon: leftIcon == null
            ? null
            : Padding(
                padding: const EdgeInsets.only(left: 14, right: 10),
                child: IconTheme(
                  data: const IconThemeData(
                    color: AppColors.textMuted,
                    size: 20,
                  ),
                  child: leftIcon!,
                ),
              ),
        prefixIconConstraints: const BoxConstraints(minWidth: 44),
        suffixIcon: rightIcon == null
            ? null
            : IconTheme(
                data: const IconThemeData(color: AppColors.textMuted, size: 20),
                child: rightIcon!,
              ),
        constraints: const BoxConstraints(minHeight: 48),
      ),
    );
  }
}
