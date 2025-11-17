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
  final String docId; // Firestore document ID
  final int year;
  final int month;
  final int day;

  const Project({
    super.key,
    required this.docId,
    required this.year,
    required this.month,
    required this.day,
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
    final cachedData = projectsPageHelper.getCertainProject(widget.docId);

    if (cachedData != null) {
      final decoded = jsonDecode(cachedData) as Map<String, dynamic>;
      setState(() => _loading = false);
      return {
        'title': decoded['title'] ?? '',
        'body': decoded['body'] ?? '',
        'imageUrl': decoded['imageUrl'] ?? '',
      };
    }

    final doc = await projectsService.getCertainProject(widget.docId);
    if (!doc.exists) throw Exception("Projekt nicht gefunden.");

    final data = doc.data()!;
    final title = data['title'] ?? '';
    final markdownUrl = data['markdownUrl'] ?? '';
    final imageUrl = data['imageUrl'] ?? '';

    final response = await http.get(Uri.parse(markdownUrl));
    if (response.statusCode != 200) {
      throw Exception("Fehler beim Laden der Markdown-Datei");
    }

    final markdown = utf8.decode(response.bodyBytes);

    final projectData = {
      'title': title,
      'body': markdown,
      'imageUrl': imageUrl,
    };

    await projectsPageHelper.setCertainProject(
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

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: loadMarkdownParts(),
      builder: (context, snapshot) {
        final data = snapshot.data;
        return Skeletonizer(
          enabled:
              _loading || snapshot.connectionState == ConnectionState.waiting,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text('${widget.day}.${widget.month}.${widget.year}'),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      data != null ? data['title'] ?? '' : 'Titel',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 10),
                    (data != null && (data['imageUrl'] ?? '').isNotEmpty)
                        ? CachedNetworkImage(
                            imageUrl: data['imageUrl'],
                            height: 200,
                            width: 200,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Skeletonizer(
                              enabled: true,
                              child: SizedBox(height: 100, width: 100),
                            ),
                            errorWidget: (context, url, error) =>
                                const Icon(Icons.error),
                          )
                        : Image.asset(
                            'assets/images/bbf-logo.png',
                            height: 100,
                            width: 50,
                          ),
                    const SizedBox(height: 15),
                    Align(
                      alignment: Alignment.center,
                      child: SizedBox(
                        width: 120,
                        child: ElevatedButton(
                          onPressed: data != null
                              ? () => showMoreBottomSheet(context, data)
                              : null,
                          child: Text(
                            'Mehr anzeigen',
                            style: Theme.of(context).textTheme.labelLarge,
                          ),
                        ),
                      ),
                    ),
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
          ),
        );
      },
    );
  }

  Future<dynamic> showMoreBottomSheet(
    BuildContext context,
    Map<String, dynamic> data,
  ) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? Colors.grey.shade600
          : BColors.secondary,
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
              child: Column(
                children: [
                  Text(
                    data['title'] ?? '',
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                  const SizedBox(height: 10),
                  (data['imageUrl'] ?? '').isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: data['imageUrl'],
                          height: 100,
                          width: 100,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Skeletonizer(
                            enabled: true,
                            child: SizedBox(height: 100, width: 100),
                          ),
                          errorWidget: (context, url, error) =>
                              const Icon(Icons.error),
                        )
                      : Image.asset(
                          'assets/images/bbf-logo.png',
                          height: 100,
                          width: 50,
                        ),
                  const SizedBox(height: 10),
                  MarkdownBody(data: data['body'] ?? ''),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
