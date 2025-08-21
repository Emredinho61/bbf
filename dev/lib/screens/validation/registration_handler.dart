import 'package:bbf_app/backend/services/auth_services.dart';
import 'package:bbf_app/backend/services/settings_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:bbf_app/components/draggable_scrollable_sheet.dart';
import 'package:bbf_app/components/text_button.dart';
import 'package:bbf_app/components/text_field.dart';
import 'package:bbf_app/screens/validation/login_handler.dart';

class RegisterForm extends StatefulWidget {
  const RegisterForm({super.key});

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  bool obscureText = true;

  void toggleObscureText() {
    setState(() {
      obscureText = !obscureText;
    });
  }

  static String errorMessageRegister = '';
  static TextEditingController usernameController = TextEditingController();

  static TextEditingController emailControllerForRegister =
      TextEditingController();
  static TextEditingController passwordControllerForRegister =
      TextEditingController();

  static TextEditingController numberController = TextEditingController();

  final SettingsService firestoreService = SettingsService();

  void register() async {
    try {
      await authService.value.createAccount(
        email: emailControllerForRegister.text,
        password: passwordControllerForRegister.text,
      );
      firestoreService.addSettings();
      Navigator.pushNamed(context, '/homepage');
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessageRegister =
            e.message ?? "Login failed due to an unknown error.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      child: Column(
        // Username Text Field
        children: [
          BTextField(
            controller: usernameController,
            obscureText: false,
            label: 'Benutzername',
            icon: Icons.account_circle,
          ),

          SizedBox(height: 10),

          BTextField(
            controller: emailControllerForRegister,
            obscureText: false,
            label: 'Email',
            icon: Icons.email,
          ),

          SizedBox(height: 10),

          // Password Text Field
          BTextField(
            controller: passwordControllerForRegister,
            obscureText: obscureText,
            label: 'Password',
            icon: Icons.https,
            suffixIcon: IconButton(
              icon: Icon(obscureText ? Icons.visibility : Icons.visibility_off),
              onPressed: toggleObscureText,
            ),
          ),

          SizedBox(height: 10),
          // Mobile Number Text Field
          BTextField(
            controller: numberController,
            obscureText: false,
            label: 'Telefonnummer',
            icon: Icons.call,
          ),
          const SizedBox(height: 10),
          Text(errorMessageRegister, style: TextStyle(color: Colors.redAccent)),
          const SizedBox(height: 10),

          SizedBox(height: 20),

          // Registration Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                register();
              },
              child: Text("Registrieren"),
            ),
          ),
        ],
      ),
    );
  }
}

Future<dynamic> registrationButtomSheet(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
    ),

    // Bottom Sheet is draggable and scrollable
    builder: (context) {
      return BDraggableScrollableSheet(
        content: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 30),

              // 'Registration' headline
              child: Text(
                "Registrierung",
                style: Theme.of(context).textTheme.headlineLarge,
              ),
            ),

            // Registration Formular
            RegisterForm(),

            // 'Already an Account ?' Text
            AlreadyRegisteredTextButton(),
          ],
        ),
      );
    },
  );
}

class AlreadyRegisteredTextButton extends StatelessWidget {
  const AlreadyRegisteredTextButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          "Schon registriert?",
          style: Theme.of(context).textTheme.labelLarge,
        ),

        // Login Text Button
        BTextButton(
          onPressed: () {
            Navigator.of(context).pop();
            loginButtomSheet(context);
          },
          text: 'Jetzt einloggen',
        ),
      ],
    );
  }
}
