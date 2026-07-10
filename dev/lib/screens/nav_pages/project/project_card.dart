import 'dart:convert';
import 'package:bbf_app/backend/services/auth_services.dart';
import 'package:bbf_app/backend/services/projects_service.dart';
import 'package:bbf_app/backend/services/user_service.dart';
import 'package:bbf_app/screens/homepage.dart';
import 'package:bbf_app/utils/helper/check_user_helper.dart';
import 'package:bbf_app/utils/helper/projects_page_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:bbf_app/utils/constants/colors.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:skeletonizer/skeletonizer.dart';

class Project extends StatefulWidget {
  final String title;
  final String docId;
  final int year;
  final int month;
  final int day;

  const Project({
    super.key,
    required this.title,
    required this.docId,
    required this.year,
    required this.month,
    required this.day,
  });

  @override
  State<Project> createState() => _ProjectState();
}

class _ProjectState extends State<Project> {
  final _helper = ProjectsPageHelper();
  final _service = ProjectsService();
  final _checkUser = CheckUserHelper();
  final _auth = AuthService();
  final _userService = UserService();

  late final Future<Map<String, dynamic>> _future;
  bool _loading = true;
  bool _isUserAdmin = false;

  @override
  void initState() {
    super.initState();
    _isUserAdmin = _checkUser.getUsersPrefs();
    _future = _loadData();
    _checkAdmin();
  }

  void _checkAdmin() async {
    if (_auth.currentUser == null) return;
    final isAdmin = await _userService.checkIfUserIsAdmin();
    if (!mounted) return;
    setState(() {
      if (isAdmin != _isUserAdmin) {
        _checkUser.setCheckUsersPrefs(isAdmin);
        _isUserAdmin = isAdmin;
      }
    });
  }

  Future<Map<String, dynamic>> _loadData() async {
    final cached = _helper.getCertainProjectFromCache(widget.docId);
    if (cached != null) {
      final decoded = jsonDecode(cached) as Map<String, dynamic>;
      if (mounted) setState(() => _loading = false);
      return {
        'title': decoded['title'] ?? '',
        'body': decoded['body'] ?? '',
        'imageUrl': decoded['imageUrl'] ?? '',
        'orientation': decoded['orientation'] ?? 'horizontal',
      };
    }

    final doc = await _service.getCertainProjectFromBackend(widget.docId);
    if (!doc.exists) throw Exception('Projekt nicht gefunden.');

    final data = doc.data()!;
    final title = data['title'] ?? '';
    final imageUrl = data['imageUrl'] ?? '';
    final orientation = data['orientation'] ?? 'horizontal';
    final markdownUrl = data['markdownUrl'] ?? '';

    final response = await http.get(Uri.parse(markdownUrl));
    if (response.statusCode != 200) {
      throw Exception('Fehler beim Laden der Markdown-Datei');
    }
    final body = utf8.decode(response.bodyBytes);

    final projectData = {
      'title': title,
      'body': body,
      'imageUrl': imageUrl,
      'orientation': orientation,
    };

    await _helper.setCertainProjectInCache(
      'project_${widget.docId}',
      jsonEncode(projectData),
    );

    if (mounted) setState(() => _loading = false);
    return projectData;
  }

  String _monthName(int m) {
    const months = [
      'Januar', 'Februar', 'März', 'April', 'Mai', 'Juni',
      'Juli', 'August', 'September', 'Oktober', 'November', 'Dezember',
    ];
    return months[m - 1];
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return FutureBuilder<Map<String, dynamic>>(
      future: _future,
      builder: (context, snapshot) {
        final data = snapshot.data;
        final isLoading =
            _loading || snapshot.connectionState == ConnectionState.waiting;
        final imageUrl = data?['imageUrl'] ?? '';
        final isHorizontal =
            (data?['orientation'] ?? 'horizontal') == 'horizontal';
        final cardAspectRatio = isHorizontal ? 16 / 9 : 3 / 4;

        return Skeletonizer(
          enabled: isLoading,
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? BColors.prayerRowDark : Colors.white,
              borderRadius: BorderRadius.circular(20.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.07),
                  blurRadius: 18,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- Image section with gradient + title overlay ---
                ClipRRect(
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(20.r)),
                  child: Stack(
                    children: [
                      AspectRatio(
                        aspectRatio: cardAspectRatio,
                        child: imageUrl.isNotEmpty
                            ? CachedNetworkImage(
                                imageUrl: imageUrl,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                placeholder: (_, __) => Container(
                                  color: isDark
                                      ? const Color(0xFF2C2C2C)
                                      : const Color(0xFFE8E8E8),
                                ),
                                errorWidget: (_, __, ___) => Container(
                                  color: isDark
                                      ? const Color(0xFF2C2C2C)
                                      : const Color(0xFFE8E8E8),
                                  child: Icon(
                                    Icons.image_not_supported_outlined,
                                    color: Colors.grey.shade400,
                                    size: 32.sp,
                                  ),
                                ),
                              )
                            : Container(
                                color: isDark
                                    ? const Color(0xFF2C2C2C)
                                    : const Color(0xFFE8E8E8),
                              ),
                      ),

                      // Bottom gradient
                      Positioned.fill(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              stops: const [0.4, 1.0],
                              colors: [
                                Colors.transparent,
                                Colors.black.withOpacity(0.65),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // Title at the bottom of the image
                      Positioned(
                        bottom: 12.h,
                        left: 14.w,
                        right: 48.w,
                        child: Text(
                          widget.title,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 17.sp,
                            fontWeight: FontWeight.w700,
                            height: 1.25,
                            shadows: [
                              Shadow(
                                color: Colors.black.withOpacity(0.4),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),

                      // Admin delete button — top right corner
                      if (_isUserAdmin)
                        Positioned(
                          top: 10.h,
                          right: 10.w,
                          child: GestureDetector(
                            onTap: () async {
                              await _service.deleteProjectFromBackend(
                                widget.docId,
                              );
                              if (!context.mounted) return;
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => NavBarShell(),
                                ),
                              );
                            },
                            child: Container(
                              padding: EdgeInsets.all(7.w),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.55),
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              child: Icon(
                                Icons.delete_outline,
                                color: Colors.red.shade300,
                                size: 18.sp,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                // --- Bottom row: date chip + action button ---
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 14.w,
                    vertical: 12.h,
                  ),
                  child: Row(
                    children: [
                      // Date chip
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.w,
                          vertical: 6.h,
                        ),
                        decoration: BoxDecoration(
                          color: BColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.calendar_today_outlined,
                              size: 12.sp,
                              color: BColors.primary,
                            ),
                            SizedBox(width: 5.w),
                            Text(
                              '${widget.day}. ${_monthName(widget.month)} ${widget.year}',
                              style: TextStyle(
                                color: BColors.primary,
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const Spacer(),

                      // "Mehr lesen" button
                      GestureDetector(
                        onTap: data != null
                            ? () => _showDetail(context, data)
                            : null,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 14.w,
                            vertical: 7.h,
                          ),
                          decoration: BoxDecoration(
                            color: BColors.primary,
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Mehr lesen',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(width: 5.w),
                              Icon(
                                Icons.arrow_forward_ios,
                                color: Colors.white,
                                size: 11.sp,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showDetail(BuildContext context, Map<String, dynamic> data) {
    final isHorizontal = data['orientation'] == 'horizontal';
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor:
          isDark ? BColors.backgroundColorDark : BColors.backgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.r)),
      ),
      builder: (ctx) => SizedBox(
        height: MediaQuery.of(ctx).size.height * 0.9,
        width: double.infinity,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 16.h),
          child: SingleChildScrollView(
            child: ShowMoreContent(
              isHorizontal: isHorizontal,
              data: data,
              year: widget.year,
              month: widget.month,
              day: widget.day,
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Detail bottom-sheet content
// ---------------------------------------------------------------------------

class ShowMoreContent extends StatelessWidget {
  final bool isHorizontal;
  final Map<String, dynamic> data;
  final int year;
  final int month;
  final int day;

  const ShowMoreContent({
    super.key,
    required this.isHorizontal,
    required this.data,
    required this.year,
    required this.month,
    required this.day,
  });

  String _monthName(int m) {
    const months = [
      'Januar', 'Februar', 'März', 'April', 'Mai', 'Juni',
      'Juli', 'August', 'September', 'Oktober', 'November', 'Dezember',
    ];
    return months[m - 1];
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final double aspectRatio = isHorizontal ? 16 / 9 : 3 / 4;
    const double cardOverlap = 52.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(36.r)),
              child: AspectRatio(
                aspectRatio: aspectRatio,
                child: CachedNetworkImage(
                  imageUrl: data['imageUrl'] ?? '',
                  fit: BoxFit.cover,
                  width: double.infinity,
                  placeholder: (_, __) => Skeletonizer(
                    enabled: true,
                    child: Container(color: Colors.grey[300]),
                  ),
                  errorWidget: (_, __, ___) => const Icon(Icons.error),
                ),
              ),
            ),

            // Gradient overlay
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(36.r),
                  bottomRight: Radius.circular(36.r),
                ),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: const [0.45, 1.0],
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.55),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Floating title card
            Positioned(
              bottom: -cardOverlap,
              left: 16,
              right: 16,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 20.w,
                  vertical: 16.h,
                ),
                decoration: BoxDecoration(
                  color: isDark ? BColors.prayerRowDark : Colors.white,
                  borderRadius: BorderRadius.circular(22.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.09),
                      blurRadius: 28,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            data['title'] ?? '',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  height: 1.2,
                                ),
                          ),
                          SizedBox(height: 8.h),
                          Container(
                            height: 3.h,
                            width: 38.w,
                            decoration: BoxDecoration(
                              color: BColors.primary,
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: 7.h,
                      ),
                      decoration: BoxDecoration(
                        color: BColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.calendar_month_outlined,
                            size: 13.sp,
                            color: BColors.primary,
                          ),
                          SizedBox(width: 5.w),
                          Text(
                            '$day. ${_monthName(month)} $year',
                            style: TextStyle(
                              color: BColors.primary,
                              fontWeight: FontWeight.w600,
                              fontSize: 12.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: cardOverlap + 20),

        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: isDark
                  ? BColors.prayerRowDark
                  : const Color(0xFFF5F5F4),
              borderRadius: BorderRadius.circular(24.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(6.w),
                      decoration: BoxDecoration(
                        color: BColors.primary.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Icon(
                        Icons.description_outlined,
                        color: BColors.primary,
                        size: 18.sp,
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Text(
                      'Beschreibung',
                      style: TextStyle(
                        color: BColors.primary,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 14.h),
                Divider(color: Colors.grey.withOpacity(0.18), height: 1),
                SizedBox(height: 16.h),
                MarkdownBody(data: data['body'] ?? ''),
              ],
            ),
          ),
        ),

        SizedBox(height: 24.h),
      ],
    );
  }
}
