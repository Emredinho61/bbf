import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:http/http.dart' as http;
import 'package:bbf_app/utils/constants/colors.dart';

class Project extends StatefulWidget {
  final String docId; // Firestore document ID

  const Project({super.key, required this.docId});

  @override
  State<Project> createState() => _ProjectState();
}

class _ProjectState extends State<Project> {
  Future<Map<String, String>> loadMarkdownParts() async {
    // Fetch document
    final doc = await FirebaseFirestore.instance
        .collection('projects')
        .doc(widget.docId)
        .get();

    if (!doc.exists) throw Exception("Projekt nicht gefunden.");

    final data = doc.data()!;
    final title = data['title'] ?? '';
    final markdownUrl = data['markdownUrl'] ?? '';
    final imageUrl = data['imageUrl'] ?? '';

    // Download markdown text
    final response = await http.get(Uri.parse(markdownUrl));
    if (response.statusCode != 200) {
      throw Exception("Fehler beim Laden der Markdown-Datei");
    }

    final markdown = utf8.decode(response.bodyBytes);

    return {
      'title': title,
      'body': markdown,
      'imageUrl': imageUrl,
    };
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
                      data['title']!,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 10),
                    data['imageUrl']!.isNotEmpty
                        ? Image.network(
                            data['imageUrl']!,
                            height: 100,
                            width: 100,
                            fit: BoxFit.cover,
                          )
                        : Image.asset(
                            'assets/images/bbf-logo.png',
                            height: 100,
                            width: 50,
                          ),
                    const SizedBox(height: 15),
                    Expanded(
                      child: MarkdownBody(
                        data: shortenMarkdown(data['body']!, 3),
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
      BuildContext context, Map<String, String> data) {
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
              padding:
                  const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
              child: Column(
                children: [
                  Text(
                    data['title']!,
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                  const SizedBox(height: 10),
                  data['imageUrl']!.isNotEmpty
                      ? Image.network(
                          data['imageUrl']!,
                          height: 100,
                          width: 100,
                          fit: BoxFit.cover,
                        )
                      : Image.asset(
                          'assets/images/bbf-logo.png',
                          height: 100,
                          width: 50,
                        ),
                  const SizedBox(height: 10),
                  MarkdownBody(data: data['body']!),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
