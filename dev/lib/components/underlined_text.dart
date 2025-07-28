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
            color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
            width: 1
          )
        )
      ),
      child: content,
    );
  }
}