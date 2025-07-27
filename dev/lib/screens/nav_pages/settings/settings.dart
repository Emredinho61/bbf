import 'package:bbf_app/utils/constants/colors.dart';
import 'package:bbf_app/utils/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), 
          color: Theme.of(context).brightness == Brightness.dark ? BColors.secondary :Colors.grey.shade500),
          child: IconButton(
            onPressed: () {
              Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
              },
            icon: Theme.of(context).brightness == Brightness.dark ? Image.asset('assets/icons/sun.png', height: 50,) : Image.asset('assets/icons/moon.png', height: 50,)
          ),
        ),
      ),
      

    );
  }
}

