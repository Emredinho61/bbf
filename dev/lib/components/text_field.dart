import 'package:flutter/material.dart';

class BTextField extends StatelessWidget {
  final String label;
  final IconData icon;
  const BTextField({super.key, required this.label, required this.icon,});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      cursorColor: Colors.black,
      decoration: InputDecoration(
        prefixIcon: Icon(icon),
        labelText: label,
      ),
    );
  }
}
