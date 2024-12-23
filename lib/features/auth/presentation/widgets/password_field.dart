import 'package:flutter/material.dart';

import 'custom_text_field.dart';

class AuthPasswordField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool obscurePassword;
  final VoidCallback onToggleVisibility;
  final String? errorText;

  const AuthPasswordField({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.obscurePassword,
    required this.onToggleVisibility,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      controller: controller,
      label: 'Password',
      hint: 'Enter your password here',
      obscureText: obscurePassword,
      focusNode: focusNode,
      suffixIcon: focusNode.hasFocus
          ? IconButton(
              icon: Icon(
                obscurePassword ? Icons.visibility_off : Icons.visibility,
              ),
              onPressed: onToggleVisibility,
            )
          : null,
      errorText: errorText,
      validatorType: 'password',
    );
  }
}
