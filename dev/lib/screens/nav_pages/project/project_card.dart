import 'dart:convert';
import 'package:bbf_app/backend/services/auth_services.dart';
import 'package:bbf_app/backend/services/projects_service.dart';
import 'package:bbf_app/backend/services/user_service.dart';
import 'package:bbf_app/screens/nav_pages/project/projects_page.dart';
import 'package:bbf_app/utils/helper/check_user_helper.dart';
import 'package:bbf_app/utils/helper/projects_page_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
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
  final double height;
  final Color color;

  const Project({
    super.key,
    required this.title,
    required this.docId,
    required this.year,
    required this.month,
    required this.day,
    required this.height,
    required this.color,
  });

  @override
  State<Project> createState() => _ProjectState();
}

class _ProjectState extends State<Project> {
  final projectsPageHelper = ProjectsPageHelper();
  final projectsService = ProjectsService();
  final CheckUserHelper checkUserHelper = CheckUserHelper();
  final AuthService authService = AuthService();
  final UserService userService = UserService();

  bool _loading = true;
  late bool isUserAdmin;

  @override
  void initState() {
    super.initState();
    isUserAdmin = checkUserHelper.getUsersPrefs();
    checkUser();
  }

  // check if user is admin
  void checkUser() async {
    if (authService.currentUser == null) {
      return;
    }
    final value = await userService.checkIfUserIsAdmin();
    setState(() {
      if (value != isUserAdmin) {
        checkUserHelper.setCheckUsersPrefs(value);
        isUserAdmin = value;
      }
    });
  }

  Future<Map<String, dynamic>> loadMarkdownParts() async {
    final cachedData = projectsPageHelper.getCertainProjectFromCache(
      widget.docId,
    );

    if (cachedData != null) {
      final decoded = jsonDecode(cachedData) as Map<String, dynamic>;
      setState(() => _loading = false);
      return {
        'title': decoded['title'] ?? '',
        'body': decoded['body'] ?? '',
        'imageUrl': decoded['imageUrl'] ?? '',
        'orientation': decoded['orientation'] ?? '',
      };
    }

    final doc = await projectsService.getCertainProjectFromBackend(
      widget.docId,
    );

    if (!doc.exists) throw Exception("Projekt nicht gefunden.");

    final data = doc.data()!;
    final title = data['title'] ?? '';
    final markdownUrl = data['markdownUrl'] ?? '';
    final imageUrl = data['imageUrl'] ?? '';
    final orientation = data['orientation'] ?? 'Nicht vorhanden';

    final response = await http.get(Uri.parse(markdownUrl));
    if (response.statusCode != 200) {
      throw Exception("Fehler beim Laden der Markdown-Datei");
    }

    final markdown = utf8.decode(response.bodyBytes);

    final projectData = {
      'title': title,
      'body': markdown,
      'imageUrl': imageUrl,
      'orientation': orientation,
    };

    await projectsPageHelper.setCertainProjectInCache(
      'project_${widget.docId}',
      jsonEncode(projectData),
    );

    setState(() => _loading = false);
    return projectData;
  }

  String shortenMarkdown(String body, int maxLines) {
    final lines = body.split('\n');
    if (lines.length <= maxLines) return body;
    return '${lines.take(maxLines).join('\n')}\n...';
  }

  String _monthName(int month) {
    const months = [
      "Januar",
      "Februar",
      "März",
      "April",
      "Mai",
      "Juni",
      "Juli",
      "August",
      "September",
      "Oktober",
      "November",
      "Dezember",
    ];
    return months[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: loadMarkdownParts(),
      builder: (context, snapshot) {
        final data = snapshot.data;
        final isHorizontal =
            (data?['orientation'] ?? 'horizontal') == 'horizontal';
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Skeletonizer(
          enabled:
              _loading || snapshot.connectionState == ConnectionState.waiting,
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: BColors.primary, width: 1),
              color: BColors.backgroundColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  // picture
                  (data != null && (data['imageUrl'] ?? '').isNotEmpty)
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: AspectRatio(
                            aspectRatio: isHorizontal ? 16 / 9 : 9 / 16,
                            child: CachedNetworkImage(
                              imageUrl: data['imageUrl'],
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Center(
                                child: Skeletonizer(
                                  enabled: true,
                                  child: SizedBox(height: 200, width: 200),
                                ),
                              ),
                              errorWidget: (context, url, error) =>
                                  const Icon(Icons.error),
                            ),
                          ),
                        )
                      : Image.asset(
                          'assets/images/bbf-logo.png',
                          height: 100,
                          width: 50,
                        ),
                  const SizedBox(height: 8),
                  // Title
                  Text(
                    widget.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Small text introduction
                  Text(
                    'Dies ist eine kleine Beschreibung für das Projekt',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).hintColor,
                    ),
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  // Date Container
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: BColors.primary.withAlpha(50),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.calendar_month_outlined,
                              size: 14,
                              color: const Color.fromARGB(255, 0, 0, 0),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${widget.day}. ${_monthName(widget.month)} ${widget.year}',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: const Color.fromARGB(255, 0, 0, 0),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Right Arrow for complete Version of Project Card
                      GestureDetector(
                        onTap: data != null
                            ? () => showMoreBottomSheet(context, data)
                            : null,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: BColors.primary.withAlpha(50),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.arrow_forward,
                            size: 14,
                            color: const Color.fromARGB(255, 0, 0, 0),
                          ),
                        ),
                      ),
                    ],
                  ),
                  // Delete Icon for Admin
                  if (isUserAdmin)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Center(
                        child: GestureDetector(
                          onTap: () async {
                            await projectsService.deleteProjectFromBackend(
                              widget.docId,
                            );
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => (AllProjects()),
                              ),
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: BColors.secondary,
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(color: Colors.red),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Icon(
                                Icons.delete,
                                size: 20,
                                color: Colors.red,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<dynamic> showMoreBottomSheet(
    BuildContext context,
    Map<String, dynamic> data,
  ) {
    final isHorizontal = (data['orientation'] ?? 'horizontal') == 'horizontal';
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: BColors.backgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return SizedBox(
          height: MediaQuery.of(context).size.height * 0.9,
          width: double.infinity,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 8.0,
                vertical: 16.0,
              ),
              child: ShowMoreContent(
                isHorizontal: isHorizontal,
                data: data,
                year: widget.year,
                month: widget.month,
                day: widget.day,
              ),
            ),
          ),
        );
      },
    );
  }
}

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

  String _monthName(int month) {
    const months = [
      'Januar',
      'Februar',
      'März',
      'April',
      'Mai',
      'Juni',
      'Juli',
      'August',
      'September',
      'Oktober',
      'November',
      'Dezember',
    ];
    return months[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    final double aspectRatio = isHorizontal ? 16 / 9 : 4/3;
    const double cardOverlap = 52.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(36)),
              child: AspectRatio(
                aspectRatio: aspectRatio,
                child: CachedNetworkImage(
                  imageUrl: data['imageUrl'],
                  fit: BoxFit.cover,
                  width: double.infinity,
                  placeholder: (context, url) => Skeletonizer(
                    enabled: true,
                    child: Container(color: Colors.grey[300]),
                  ),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                ),
              ),
            ),

            Positioned.fill(
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(36),
                  bottomRight: Radius.circular(36),
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

            Positioned(
              bottom: -cardOverlap,
              left: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
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
                          const SizedBox(height: 8),
                          Container(
                            height: 3,
                            width: 38,
                            decoration: BoxDecoration(
                              color: BColors.primary,
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: BColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.calendar_month_outlined,
                            size: 13,
                            color: BColors.primary,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            '$day. ${_monthName(month)} $year',
                            style: TextStyle(
                              color: BColors.primary,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
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
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F4),
              borderRadius: BorderRadius.circular(24),
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
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: BColors.primary.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.description_outlined,
                        color: BColors.primary,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Beschreibung',
                      style: TextStyle(
                        color: BColors.primary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Divider(color: Colors.grey.withOpacity(0.18), height: 1),
                const SizedBox(height: 16),
                MarkdownBody(data: data['body'] ?? ''),
              ],
            ),
          ),
        ),

        const SizedBox(height: 24),
      ],
    );
  }
}
