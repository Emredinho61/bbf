import 'package:bbf_app/backend/authentification/auth_services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:bbf_app/components/draggable_scrollable_sheet.dart';
import 'package:bbf_app/components/text_field.dart';
import 'package:bbf_app/utils/constants/colors.dart';
import 'package:bbf_app/screens/validation/registration_handler.dart';
import 'package:bbf_app/components/text_button.dart';

Future<dynamic> loginButtomSheet(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: BColors.secondary,
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

              // 'Login' headline
              child: Text(
                "Login",
                style: Theme.of(context).textTheme.headlineLarge,
              ),
            ),

            // Login Formular
            LoginForm(),

            // 'No Account ?' Text
            AlreadyLoggedInTextButton(),
          ],
        ),
      );
    },
  );
}

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  bool obscureText = true;

  static TextEditingController emailControllerForLogin =
      TextEditingController();
  static TextEditingController passwordControllerForLogin =
      TextEditingController();
  static String errorMessageLogin = '';

  void _handleLogin() async {
    try {
      final UserCredential userCredential = await authService.value.signIn(
        email: emailControllerForLogin.text,
        password: passwordControllerForLogin.text,
      );

      final user = userCredential.user;
      if (user != null) {
        Navigator.pushNamed(context, '/homepage');
      } else {
        setState(() {
          errorMessageLogin = "Login failed. No user returned.";
        });
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessageLogin =
            e.message ?? "Login failed due to an unknown error.";
      });
    } catch (e) {
      setState(() {
        errorMessageLogin = "Unexpected error: $e";
      });
    }
  }

  void toggleObscureText() {
    setState(() {
      obscureText = !obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      child: Column(
        // Email Text Field
        children: [
          BTextField(
            controller: emailControllerForLogin,
            obscureText: false,
            label: 'Email',
            icon: Icons.email,
          ),

          SizedBox(height: 10),

          // Password Text Field
          BTextField(
            controller: passwordControllerForLogin,
            obscureText: obscureText,
            label: 'Password',
            icon: Icons.https,
            suffixIcon: IconButton(
              icon: Icon(obscureText ? Icons.visibility : Icons.visibility_off),
              onPressed: toggleObscureText,
            ),
          ),

          SizedBox(height: 5),
          Text(errorMessageLogin, style: TextStyle(color: Colors.redAccent)),

          // Forgot Password Text
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () {},
                child: Text(
                  'Passwort vergessen ?',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
              ),
            ],
          ),

          SizedBox(height: 10),

          // Login Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _handleLogin,
              child: Text("Einloggen"),
            ),
          ),
        ],
      ),
    );
  }
}

class AlreadyLoggedInTextButton extends StatelessWidget {
  const AlreadyLoggedInTextButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          "Noch keinen Account?",
          style: Theme.of(context).textTheme.labelLarge,
        ),

        // Register Text Button
        BTextButton(
          onPressed: () {
            Navigator.of(context).pop();
            registrationButtomSheet(context);
          },
          text: 'Hier registrieren',
        ),
      ],
    );
  }
}
