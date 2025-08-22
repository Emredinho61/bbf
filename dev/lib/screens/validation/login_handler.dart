import 'package:bbf_app/backend/services/auth_services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:bbf_app/components/draggable_scrollable_sheet.dart';
import 'package:bbf_app/components/text_field.dart';
import 'package:bbf_app/screens/validation/registration_handler.dart';
import 'package:bbf_app/components/text_button.dart';

Future<dynamic> loginButtomSheet(BuildContext context) {
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
  final AuthService authService = AuthService();

  bool obscureText = true;

  static TextEditingController emailControllerForLogin =
      TextEditingController();
  static TextEditingController passwordControllerForLogin =
      TextEditingController();
  static String errorMessageLogin = '';

  void _handleLogin() async {
  final email = emailControllerForLogin.text;
  final password = passwordControllerForLogin.text;

  if (email.isEmpty && password.isEmpty) {
    setState(() {
      errorMessageLogin = 'Bitte E-Mail und Passwort eingeben.';
    });
    return;
  } else if (email.isEmpty) {
    setState(() {
      errorMessageLogin = 'Bitte E-Mail eingeben.';
    });
    return;
  } else if (password.isEmpty) {
    setState(() {
      errorMessageLogin = 'Bitte Passwort eingeben.';
    });
    return;
  }

  try {
    final UserCredential userCredential = await authService.signIn(
      email: email,
      password: password,
    );

    final user = userCredential.user;
    if (user != null) {
      Navigator.pushNamed(context, '/homepage');
    } else {
      setState(() {
        errorMessageLogin = "Login fehlgeschlagen. Kein Nutzer zurückgegeben.";
      });
    }
  } on FirebaseAuthException catch (e) {
    String message;
  switch (e.code) {
    case 'invalid-email':
      message = "Bitte eine gültige E-Mail-Adresse eingeben.";
    default:
      message = "E-Mail oder Passwort ist falsch.";
  }
  setState(() {
    errorMessageLogin = message;
  });
  }
}


  void toggleObscureText() {
    setState(() {
      obscureText = !obscureText;
    });
  }

  void showForgetPasswordDialog(context) {
    final TextEditingController emailForResetController =
        TextEditingController();

    String message = '';
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(
                'Passwort vergessen',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  BTextField(
                    label: 'Email',
                    icon: Icons.email,
                    controller: emailForResetController,
                    obscureText: false,
                    obligatory: false
                  ),
                  SizedBox(height: 5,),
                  Text(message)
                ],
              ),
              actions: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    BTextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      text: 'Zurück',
                    ),
                    ElevatedButton(
                      onPressed: () {
                        if(emailForResetController.text.isEmpty)
                        {
                         setState(() {
                           message = 'Bitte eine E-Mail-Adresse eingeben.';
                         },);
                         return;
                        }
                        else{
                          authService.resetPassword(
                          email: emailForResetController.text,
                        );
                        message = 'Email versendet!';
                        }
                          
                        
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4.0,
                          vertical: 2.0,
                        ),
                        child: Text(
                          'Passwort zurücksetzen',
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
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
            obligatory: false
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
            obligatory: false
          ),

          SizedBox(height: 5),
          Text(errorMessageLogin, style: TextStyle(color: Colors.redAccent)),

          // Forgot Password Text
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () {
                  showForgetPasswordDialog(context);
                },
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
