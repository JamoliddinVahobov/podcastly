import 'package:flutter/material.dart';

import 'custom_button.dart';

class AuthButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final List<Color> colors;
  final bool isLoading;

  const AuthButton({
    super.key,
    required this.label,
    required this.onPressed,
    required this.colors,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
        ),
      );
    }

    return CustomButton(
      label: label,
      onPressed: onPressed,
      colors: colors,
    );
  }
}
