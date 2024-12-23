import 'package:flutter/material.dart';

import 'custom_text_field.dart';

class AuthEmailField extends StatelessWidget {
  final TextEditingController controller;
  final String? errorText;

  const AuthEmailField({
    super.key,
    required this.controller,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      controller: controller,
      label: 'Email',
      hint: 'Enter your email here',
      keyboardType: TextInputType.emailAddress,
      errorText: errorText,
      validatorType: 'email',
    );
  }
}
