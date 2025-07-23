import 'package:flutter/material.dart';
import 'package:bbf_app/components/draggable_scrollable_sheet.dart';
import 'package:bbf_app/components/text_button.dart';
import 'package:bbf_app/components/text_field.dart';
import 'package:bbf_app/utils/constants/colors.dart';

class Welcome extends StatelessWidget {
  Welcome({super.key});
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
                      text: 'Als Gast fortfahren')
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
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(25.0),
                      ),
                    ),

                    // Bottom Sheet is draggable and scrollable
                    builder: (context) {
                      return BDraggableScrollableSheet(
                        content: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 30,
                              ),

                              // 'Registration' headline
                              child: Text(
                                "Registrierung",
                                style: Theme.of(
                                  context,
                                ).textTheme.headlineLarge,
                              ),
                            ),

                            // Registration Formular
                            RegisterForm(),

                            // 'Already an Account ?' Text
                            AlreadyRegisteredTextButton()
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
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(25.0),
                      ),
                    ),

                    // Bottom Sheet is draggable and scrollable
                    builder: (context) {
                      return BDraggableScrollableSheet(
                        content: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 30,
                              ),

                              // 'Login' headline
                              child: Text(
                                "Login",
                                style: Theme.of(
                                  context,
                                ).textTheme.headlineLarge,
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
  const AlreadyRegisteredTextButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          "Schon registriert?",
          style: Theme.of(
            context,
          ).textTheme.labelLarge,
        ),
    
        // Login Text Button
        BTextButton(
          onPressed: () {
            Navigator.of(context).pop();
            loginButtomSheet(context);
          }, 
          text: 'Jetzt einloggen')
      ],
    );
  }
}

class RegisterForm extends StatelessWidget {
  const RegisterForm({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      child: Column(
        // Username Text Field
        children: [
          BTextField(
            label: 'Benutzername',
            icon: Icons.account_circle,
          ),
    
          SizedBox(height: 10),
    
          BTextField(
            label: 'Email',
            icon: Icons.email,
          ),
    
          SizedBox(height: 10),
    
          // Password Text Field
          BTextField(
            label: 'Password',
            icon: Icons.https,
          ),
    
          SizedBox(height: 10),
          // Mobile Number Text Field
          BTextField(
            label: 'Telefonnummer',
            icon: Icons.call,
          ),
    
          SizedBox(height: 20),
    
          // Registration Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              child: Text(
                "Registrieren",
              ),
            ),
          ),
    
        ]
    
      )
    );
  }
}

class AlreadyLoggedInTextButton extends StatelessWidget {
  const AlreadyLoggedInTextButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          "Noch keinen Account?",
          style: Theme.of(
            context,
          ).textTheme.labelLarge,
        ),
    
        // Register Text Button
        BTextButton(
          onPressed: (){
            Navigator.of(context).pop();
            registrationButtomSheet(context);
          } 
        , text: 'Hier registrieren')
      ],
    );
  }
}

class LoginForm extends StatelessWidget {
  const LoginForm({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      child: Column(
    
        // Email Text Field
        children: [
          BTextField(
            label: 'Email',
            icon: Icons.email,
          ),
    
          SizedBox(height: 10),
    
          // Password Text Field
          BTextField(
            label: 'Password',
            icon: Icons.https,
          ),
    
          SizedBox(height: 5),
    
          // Forgot Password Text
          Row(
            mainAxisAlignment:
                MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () {},
                child: Text(
                  'Passwort vergessen ?',
                  style: Theme.of(
                    context,
                  ).textTheme.labelLarge,
                ),
              ),
            ],
          ),
    
          SizedBox(height: 10),
    
          // Login Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              child: Text(
                "Einloggen",
              ),
            ),
          ),
        ],
      ),
    );
  }
}
