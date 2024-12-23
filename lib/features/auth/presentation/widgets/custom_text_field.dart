import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final TextInputType keyboardType;
  final bool obscureText;
  final FocusNode? focusNode;
  final Widget? suffixIcon;
  final String? errorText;
  final String? validatorType;
  final void Function(String)? onChanged;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.focusNode,
    this.suffixIcon,
    this.errorText,
    this.onChanged,
    this.validatorType,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        focusNode: focusNode,
        style: const TextStyle(fontSize: 16, color: Colors.black),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          suffixIcon: suffixIcon,
          errorText: errorText,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 17, horizontal: 15),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Colors.grey[500]!, width: 2.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: Colors.blueAccent, width: 2.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: Colors.red, width: 2.0),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: Colors.redAccent, width: 2.5),
          ),
        ),
        onChanged: onChanged,
        validator: (value) {
          if (value == null || value.isEmpty) {
            if (validatorType == 'email') {
              return 'Email cannot be empty';
            } else if (validatorType == 'username') {
              return 'Username cannot be empty';
            } else if (validatorType == 'password') {
              return 'Password cannot be empty';
            }
          }
          if (value != null &&
              validatorType == 'email' &&
              !RegExp(r'^[a-zA-Z0-9._%+-]+@gmail\.com$').hasMatch(value)) {
            return 'Please enter a valid email';
          }
          if (value != null &&
              validatorType == 'password' &&
              value.length < 6) {
            return 'Password must be at least 6 characters';
          }

          return null;
        },
      ),
    );
  }
}
