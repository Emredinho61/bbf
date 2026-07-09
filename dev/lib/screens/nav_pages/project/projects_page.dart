import 'package:bbf_app/backend/services/auth_services.dart';
import 'package:bbf_app/backend/services/user_service.dart';
import 'package:bbf_app/screens/nav_pages/project/projects_by_tense.dart';
import 'package:bbf_app/utils/constants/colors.dart';
import 'package:bbf_app/utils/helper/check_user_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
      backgroundColor: isDark ? BColors.backgroundColorDark : BColors.backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(top: 10.h),
          child: Column(
            children: [
              Expanded(
                child: DefaultTabController(
                  length: 2,
                  child: Column(
                    children: [
                      Container(
                        margin: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 10.h,
                        ),
                        padding: EdgeInsets.all(6.w),
                        decoration: BoxDecoration(
                          color: isDark ? BColors.prayerRowDark : const Color.fromARGB(255, 220, 228, 240),
                          borderRadius: BorderRadius.circular(28.r),
                          border: Border.all(
                            color: isDark ? Colors.white.withOpacity(0.06) : const Color.fromARGB(255, 200, 210, 225),
                            width: 1,
                          ),
                        ),
                        child: TabBar(
                          dividerColor: Colors.transparent,
                          indicator: BoxDecoration(
                            color: isDark ? const Color(0xFF3D4A5C) : Colors.white,
                            borderRadius: BorderRadius.circular(24.r),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),

                          labelColor: BColors.primary,

                          unselectedLabelColor: isDark ? Colors.grey.shade400 : const Color(0xFF5F6368),

                          labelStyle: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                          ),

                          unselectedLabelStyle: TextStyle(
                            fontSize: 16.sp,
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
                                    children: [
                                      Icon(
                                        Icons.calendar_today_outlined,
                                        size: 18.sp,
                                      ),
                                      SizedBox(width: 8.w),
                                      const Text("Kommend"),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            Tab(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.access_time_outlined, size: 18.sp),
                                  SizedBox(width: 8.w),
                                  const Text("Vergangen"),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 12.h),

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
