import 'package:flutter/material.dart';

class BTextField extends StatelessWidget {
  final String label;
  final IconData icon;
  final TextEditingController controller;
  final bool obscureText;

  const BTextField({
    super.key,
    required this.label,
    required this.icon,
    required this.controller,
    required this.obscureText,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      cursorColor: Colors.black,
      decoration: InputDecoration(prefixIcon: Icon(icon), labelText: label),
    );
  }
}
