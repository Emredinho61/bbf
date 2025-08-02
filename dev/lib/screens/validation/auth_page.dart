import 'package:bbf_app/backend/services/auth_services.dart';
import 'package:bbf_app/screens/homepage.dart';
import 'package:flutter/material.dart';
import 'package:bbf_app/components/text_button.dart';
import 'package:bbf_app/screens/validation/registration_handler.dart';
import 'package:bbf_app/screens/validation/login_handler.dart';

class AuthPage extends StatefulWidget {
  AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final ScrollController scrollController = ScrollController();
  final AuthService authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: authService.authStateChanges,
        builder: (context, asyncSnapshot) {
          if(asyncSnapshot.hasData)
          {
            return NavBarShell();
          }
          else
          {
            return WelcomePage();
          }
          
        }
      ),
    );
  }
}

class WelcomePage extends StatelessWidget {
  const WelcomePage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
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
    );
  }
}
