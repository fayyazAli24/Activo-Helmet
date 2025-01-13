import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app_colors.dart';

class CustomTextFormField extends StatelessWidget {
  CustomTextFormField(
      {super.key,
      required this.controller,
      this.onTap,
      this.autovalidateMode,
      required this.obscureText,
      this.onSuffixTap,
      this.onChanged,
      this.filled,
      this.inputFormatters,
      this.hint,
      this.maxLines,
      this.keyboardType,
      this.prefixIcon,
      this.validator,
      this.suffix,
      this.value = false});

  final VoidCallback? onTap;
  final VoidCallback? onSuffixTap;
  final Function(String? value)? onChanged;
  final String? Function(String? value)? validator;
  final TextEditingController controller;
  final bool obscureText;
  final TextInputType? keyboardType;
  final bool? filled;
  final String? hint;
  final int? maxLines;
  final List<TextInputFormatter>? inputFormatters;
  final Widget? prefixIcon;
  final bool value;
  final Widget? suffix;

  final AutovalidateMode? autovalidateMode;
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      readOnly: value,
      controller: controller,
      onTap: onTap ?? () {},
      onChanged: onChanged ?? (v) {},
      validator: validator,
      keyboardType: keyboardType,
      autovalidateMode: autovalidateMode,
      inputFormatters: inputFormatters,
      maxLines: obscureText == null ? maxLines : 1,
      obscureText: obscureText,
      decoration: InputDecoration(
        suffixIcon: suffix != null
            ? IconButton(onPressed: onSuffixTap, icon: suffix ?? Icon(Icons.check_circle_outline_outlined))
            : null,
        hintText: hint,
        prefixIcon: prefixIcon,
        contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        border: const OutlineInputBorder(),
        fillColor: AppColors.primaryColor.withOpacity(0.1),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(
            color: AppColors.primaryColor,
          ),
        ),
        errorStyle: const TextStyle(
          fontStyle: FontStyle.italic,
          fontSize: 15,
          fontWeight: FontWeight.w400,
        ),
      ),
      style: const TextStyle(
        fontWeight: FontWeight.w400,
        fontSize: 15,
      ),
      obscuringCharacter: "•",
    );
  }
}
