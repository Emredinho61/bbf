import 'package:flutter/material.dart';

class BTextField extends StatelessWidget {
  final String label;
  final IconData icon;
  final FocusNode? focusNode;
  const BTextField({super.key, required this.label, required this.icon, this.focusNode,});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      cursorColor: Colors.black,
      focusNode: focusNode,
      decoration: InputDecoration(
        prefixIcon: Icon(icon),
        labelText: label,
      ),
    );
  }
}
