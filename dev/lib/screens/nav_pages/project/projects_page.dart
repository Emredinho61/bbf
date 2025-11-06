import 'package:bbf_app/backend/services/auth_services.dart';
import 'package:bbf_app/backend/services/user_service.dart';
import 'package:bbf_app/screens/nav_pages/project/projects_by_tense.dart';
import 'package:bbf_app/utils/constants/colors.dart';
import 'package:bbf_app/utils/helper/check_user_helper.dart';
import 'package:flutter/material.dart';

class AllProjects extends StatefulWidget {
  const AllProjects({super.key});

  @override
  State<AllProjects> createState() => _AllProjectsState();
}

class _AllProjectsState extends State<AllProjects> {
  AuthService authService = AuthService();
  UserService userService = UserService();
  CheckUserHelper checkUserHelper = CheckUserHelper();

  late bool isUserAdmin;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [Colors.green.shade900, Colors.grey.shade700]
                : [Colors.grey.shade300, Colors.green.shade200],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Column(
              children: [
                Text(
                  'Projekte',
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                SizedBox(height: 15),
                Expanded(
                  child: DefaultTabController(
                    length: 2,
                    child: Column(
                      children: [
                        TabBar(
                          dividerColor: isDark
                              ? Colors.white54
                              : BColors.secondary,
                          padding: EdgeInsets.symmetric(horizontal: 30),
                          indicatorColor: BColors.primary,
                          labelColor: isDark ? Colors.white : Colors.black,
                          tabs: [
                            Text(
                              'Vergangen',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            Text(
                              'Kommend',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        Expanded(
                          child: TabBarView(
                            children: [
                              ProjectsByTense(tense: 'past'),
                              ProjectsByTense(tense: 'future'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
