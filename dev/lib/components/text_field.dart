import 'package:bbf_app/utils/constants/colors.dart';
import 'package:flutter/material.dart';

class BTextField extends StatelessWidget {
  final String label;
  final IconData icon;
  final TextEditingController controller;
  final bool obscureText;
  final Widget? suffixIcon;
  final bool obligatory;
  final String? errorText;

  const BTextField({
    super.key,
    required this.label,
    required this.icon,
    required this.controller,
    required this.obscureText,
    required this.obligatory,
    this.suffixIcon,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      cursorColor: BColors.primary,
      decoration: InputDecoration(
        prefixIcon: Icon(icon),
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label),
            obligatory
                ? Text(" *", style: TextStyle(color: Colors.red))
                : Text(''),
          ],
        ),
        suffixIcon: suffixIcon,
        errorText: errorText,
        errorStyle: TextStyle(height: 0, fontSize: 0),
      ),
    );
  }
}
