import 'package:bbf_app/backend/authentification/auth_services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:bbf_app/components/draggable_scrollable_sheet.dart';
import 'package:bbf_app/components/text_button.dart';
import 'package:bbf_app/components/text_field.dart';
import 'package:bbf_app/utils/constants/colors.dart';

class Welcome extends StatefulWidget {
  Welcome({super.key});

  @override
  State<Welcome> createState() => _WelcomeState();
}

class _WelcomeState extends State<Welcome> {
  final ScrollController scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Center(
            child: Column(
              children: [
                // BBF - Logo
                Image.asset(
                  'assets/images/bbf-logo.png',
                  width: 200,
                  height: 100,
                ),

                SizedBox(height: 30),

                // Welcome Text
                Text(
                  'Willkommen',
                  style: Theme.of(context).textTheme.headlineLarge,
                ),

                SizedBox(height: 30),

                Row(
                  children: [
                    // "Bereits registriert ?" - Text
                    Text(
                      'Bereits registriert?',
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                  ],
                ),
                SizedBox(height: 5),

                SizedBox(
                  width: double.infinity,

                  // Login Button
                  child: ElevatedButton(
                    // opening Bottom Sheet for Login when Button pressed
                    onPressed: () {
                      loginButtomSheet(context);
                    },

                    child: Text('Login'),
                  ),
                ),

                // Register Button
                SizedBox(height: 10),

                Row(
                  children: [
                    Text(
                      'Erstelle einen Account',
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                  ],
                ),
                SizedBox(height: 5),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      registrationButtomSheet(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 80, 126, 45),
                    ),

                    child: Text('Registrieren'),
                  ),
                ),

                // "Als Gast fortfahren" - button Text
                SizedBox(height: 3),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    BTextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/homepage');
                      },
                      text: 'Als Gast fortfahren',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Future<dynamic> registrationButtomSheet(BuildContext context) {
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

  void register() async {
    try {
      await authService.value.createAccount(
        email: emailControllerForRegister.text,
        password: passwordControllerForRegister.text,
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
          errorMessageRegister = e.message ?? "Login failed due to an unknown error.";
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
          Text(
            errorMessageRegister,
            style: TextStyle(color: Colors.redAccent),
          ),
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
          Text(
            errorMessageLogin,
            style: TextStyle(color: Colors.redAccent),
          ),

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
