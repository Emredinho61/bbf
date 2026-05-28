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
      backgroundColor: BColors.backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Column(
            children: [
              Expanded(
                child: DefaultTabController(
                  length: 2,
                  child: Column(
                    children: [
                      Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 220, 228, 240),
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(
                            color: const Color.fromARGB(255, 200, 210, 225),
                            width: 1,
                          ),
                        ),
                        child: TabBar(
                          dividerColor: Colors.transparent,
                          indicator: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),

                          labelColor: BColors.primary,

                          unselectedLabelColor: const Color(0xFF5F6368),

                          labelStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),

                          unselectedLabelStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),

                          indicatorSize: TabBarIndicatorSize.tab,

                          tabs: [
                            Tab(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: const [
                                      Icon(
                                        Icons.calendar_today_outlined,
                                        size: 18,
                                      ),
                                      SizedBox(width: 8),
                                      Text("Kommend"),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            Tab(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Icon(Icons.access_time_outlined, size: 18),
                                  SizedBox(width: 8),
                                  Text("Vergangen"),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 12),

                      Expanded(
                        child: TabBarView(
                          children: [
                            ProjectsByTense(tense: 'future'),
                            ProjectsByTense(tense: 'past'),
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
    );
  }
}
