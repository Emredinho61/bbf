import 'package:flutter/material.dart';

class UnderlinedText extends StatelessWidget {
  final Widget content;
  const UnderlinedText({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.white,
            width: 1,
          ),
        ),
      ),
      child: content,
    );
  }
}
