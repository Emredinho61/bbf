import 'package:flutter/material.dart';

class AuthDialogButton extends StatelessWidget {
  final String buttonText;
  final List<String> fieldLabels;
  final int passwordFieldIndex;
  final Future<void> Function(Map<String, String> values, BuildContext context) onSubmit;
  final Color? confirmButtonColor;
  final String confirmButtonText;

  const AuthDialogButton({
    super.key,
    required this.buttonText,
    required this.fieldLabels,
    required this.passwordFieldIndex,
    required this.onSubmit,
    this.confirmButtonColor,
    this.confirmButtonText = "Submit",
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => _openDialog(context),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Text(buttonText),
      ),
    );
  }

  void _openDialog(BuildContext context) {
    final controllers =
        List.generate(fieldLabels.length, (_) => TextEditingController());

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(buttonText),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(fieldLabels.length, (index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6.0),
                  child: TextField(
                    controller: controllers[index],
                    obscureText: index == passwordFieldIndex,
                    decoration: InputDecoration(
                      labelText: fieldLabels[index],
                      border: const OutlineInputBorder(),
                    ),
                  ),
                );
              }),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Abbrechen"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: confirmButtonColor,
              ),
              onPressed: () async {
                final values = <String, String>{};
                for (int i = 0; i < fieldLabels.length; i++) {
                  values[fieldLabels[i]] = controllers[i].text.trim();
                }

                Navigator.pop(ctx);

                await onSubmit(values, context);
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(confirmButtonText),
              ),
            ),
          ],
        );
      },
    ); 
  }
}
