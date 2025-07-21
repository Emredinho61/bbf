import 'package:flutter/material.dart';

class Welcome extends StatelessWidget {
  const Welcome({super.key});

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
                Image.asset('assets/images/bbf-logo.png', width: 200, height: 100), 
                SizedBox(height: 30),
                // Welcome Text
                Text('Willkommen', style: Theme.of(context).textTheme.headlineLarge),
                // "Bereits registriert ?" - Text
                SizedBox(height: 30),

                Row(
                  children: [
                    Text('Bereits registriert ?', style: Theme.of(context).textTheme.labelLarge)
                  ]
                  ), 
                // Login Button
                SizedBox(height: 5),

                // "Account erstellen." - Text
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed:() {},
                    child: Text('Login'),
                    ),
                ), 

                // Register Button
                SizedBox(height: 10),

                Row(
                  children: [
                    Text('Erstelle einen Account', style: Theme.of(context).textTheme.labelLarge)
                  ]
                  ), 
                // Login Button
                SizedBox(height: 5),

                // todo: restructure to avoid duplicate Code
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed:() {},
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
                      child: Text('Als Gast fortfahren', style: Theme.of(context).textTheme.labelLarge)
                      ),
                  ],
                )
              ],
              
            
            ),
          ),
        )
      )
    );
  }
}