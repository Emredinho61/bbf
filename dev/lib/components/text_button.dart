import 'package:flutter/material.dart';

class BTextButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String text;
  const BTextButton({super.key, required this.onPressed, required this.text});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : Colors.black,
              width: 1.0,
            ),
          ),
        ),
        child: Text(text, style: Theme.of(context).textTheme.labelLarge),
      ),
    );
  }
}
