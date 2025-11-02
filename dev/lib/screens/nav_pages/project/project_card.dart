import 'dart:convert';
import 'package:bbf_app/backend/services/projects_service.dart';
import 'package:bbf_app/utils/helper/projects_page_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:http/http.dart' as http;
import 'package:bbf_app/utils/constants/colors.dart';
import 'package:cached_network_image/cached_network_image.dart';

class Project extends StatefulWidget {
  final String docId; // Firestore document ID

  const Project({super.key, required this.docId});

  @override
  State<Project> createState() => _ProjectState();
}

class _ProjectState extends State<Project> {
  Future<Map<String, dynamic>> loadMarkdownParts() async {
    final ProjectsPageHelper projectsPageHelper = ProjectsPageHelper();
    final ProjectsService projectsService = ProjectsService();

    // check, if there is already a project saved in prefs
    final cachedData = projectsPageHelper.getCertainProject(widget.docId);
    // if so, return the data
    if (cachedData != null) {
      final decoded = jsonDecode(cachedData) as Map<String, dynamic>;
      return {
        'title': decoded['title'] ?? '',
        'body': decoded['body'] ?? '',
        'imageUrl': decoded['imageUrl'] ?? '',
      };
    }

    // if there is new project, then fetch from backend
    final doc = await projectsService.getCertainProject(widget.docId);

    if (!doc.exists) throw Exception("Projekt nicht gefunden.");

    final data = doc.data()!;
    final title = data['title'] ?? '';
    final markdownUrl = data['markdownUrl'] ?? '';
    final imageUrl = data['imageUrl'] ?? '';

    // fetch md data
    final response = await http.get(Uri.parse(markdownUrl));
    if (response.statusCode != 200) {
      throw Exception("Fehler beim Laden der Markdown-Datei");
    }

    final markdown = utf8.decode(response.bodyBytes);

    // save new project in prefs
    final projectData = {
      'title': title,
      'body': markdown,
      'imageUrl': imageUrl,
    };
    await projectsPageHelper.setCertainProject(
      'project_${widget.docId}',
      jsonEncode(projectData),
    );

    return projectData;
  }

  String shortenMarkdown(String body, int maxLines) {
    final lines = body.split('\n');
    if (lines.length <= maxLines) {
      return body;
    } else {
      return '${lines.take(maxLines).join('\n')}\n...';
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: loadMarkdownParts(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Center(child: Text('Fehler beim Laden der Datei.'));
        } else {
          final data = snapshot.data!;
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    Text(
                      data['title'] ?? '',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 10),
                    (data['imageUrl'] ?? '').isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: data['imageUrl'],
                            height: 100,
                            width: 100,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => const Center(
                              child: CircularProgressIndicator(),
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
                    Expanded(
                      child: MarkdownBody(
                        data: shortenMarkdown(data['body'] ?? '', 3),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Align(
                      alignment: Alignment.center,
                      child: SizedBox(
                        width: 120,
                        child: ElevatedButton(
                          onPressed: () {
                            showMoreBottomSheet(context, data);
                          },
                          child: Text(
                            'Mehr anzeigen',
                            style: Theme.of(context).textTheme.labelLarge,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
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
                          placeholder: (context, url) =>
                              const CircularProgressIndicator(),
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
