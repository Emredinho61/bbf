import 'package:flutter/material.dart';
import 'package:namer_app/components/draggable_scrollable_sheet.dart';
import 'package:namer_app/components/text_field.dart';
import 'package:namer_app/utils/constants/colors.dart';

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
                      'Bereits registriert ?',
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
                      showModalBottomSheet(
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
                                LoginFormular(),

                                // 'No Account ?' Text
                                NoAccountTextButton(),
                              ],
                            ),
                          );
                        },
                      );
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
                      showModalBottomSheet(
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
                                    "Registrierung",
                                    style: Theme.of(
                                      context,
                                    ).textTheme.headlineLarge,
                                  ),
                                ),

                                // Registration Formular
                                RegisterForm(),

                                // 'Already an Account ?' Text
                                AlreadyRegistered()
                              ],
                            ),
                          );
                        },
                      );


                    },
                    child: Text('Registrieren'),
                  ),
                ),

                // "Als Gast fortfahren" - button Text
                SizedBox(height: 3),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () {},
                      child: Text(
                        'Als Gast fortfahren',
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
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

class AlreadyRegistered extends StatelessWidget {
  const AlreadyRegistered({
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
        TextButton(
          onPressed: () {},
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Colors.black,
                  width: 1.0,
                ),
              ),
            ),
            child: Text(
              'Jetzt einloggen',
              style: Theme.of(
                context,
              ).textTheme.labelLarge,
            ),
          ),
        ),
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
                style: Theme.of(
                  context,
                ).textTheme.headlineMedium,
              ),
            ),
          ),
    
        ]
    
      )
    );
  }
}

class NoAccountTextButton extends StatelessWidget {
  const NoAccountTextButton({
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
        TextButton(
          onPressed: () {},
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Colors.black,
                  width: 1.0,
                ),
              ),
            ),
            child: Text(
              'Jetzt registrieren',
              style: Theme.of(
                context,
              ).textTheme.labelLarge,
            ),
          ),
        ),
      ],
    );
  }
}

class LoginFormular extends StatelessWidget {
  const LoginFormular({
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
                style: Theme.of(
                  context,
                ).textTheme.headlineMedium,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
