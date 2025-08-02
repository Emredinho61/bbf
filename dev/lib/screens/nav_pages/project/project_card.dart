import 'package:bbf_app/utils/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';

class Project extends StatefulWidget {
  const Project({super.key});

  @override
  State<Project> createState() => _ProjectState();
}

class _ProjectState extends State<Project> {
  Future<Map<String, String>> loadMarkdownParts() async {
    final data = await rootBundle.loadString('assets/files/project.md');
    final lines = data.split('\n');

    String title = '';
    String body = '';

    // Nimm die erste Zeile als Titel (falls es mit '#' beginnt)
    if (lines.isNotEmpty && lines.first.startsWith('#')) {
      title = lines.first.replaceFirst('#', '').trim();
      body = lines.skip(1).join('\n').trim(); // Rest als Body
    } else {
      body = data; // Kein Titel gefunden → alles Body
    }

    return {'title': title, 'body': body};
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
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Fehler beim Laden der Datei.'));
        } else {
          final markdownParts = snapshot.data!;
          return Padding(
            padding: EdgeInsetsGeometry.all(8.0),
            child: Card(
              child: Padding(
                padding: EdgeInsetsGeometry.all(8.0),
                child: Column(
                  children: [
                    SizedBox(height: 10),
                    Text(
                      markdownParts['title']!,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    SizedBox(height: 10),
                    Image.asset(
                      'assets/images/bbf-logo.png',
                      height: 100,
                      width: 50,
                    ),
                    SizedBox(height: 15),

                    Expanded(
                      child: MarkdownBody(
                        data: shortenMarkdown(markdownParts['body']!, 3),
                      ),
                    ),
                    SizedBox(height: 5),

                    // Centering the button
                    Align(
                      alignment: Alignment.center,
                      child: SizedBox(
                        width: 100,
                        child: ElevatedButton(
                          onPressed: () {
                            showMoreBottomSheet(context);
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

  Future<dynamic> showMoreBottomSheet(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? Colors.grey.shade600
          : BColors.secondary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return FutureBuilder(
          future: loadMarkdownParts(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Fehler beim Laden der Datei.'));
        } else {
          final markdownParts = snapshot.data!;
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
                        markdownParts['title']!,
                        style: Theme.of(context).textTheme.headlineLarge,
                      ),
                      SizedBox(height: 10),
                      Image.asset(
                        'assets/images/bbf-logo.png',
                        height: 100,
                        width: 50,
                      ),
                      SizedBox(height: 10),
                      MarkdownBody(data: markdownParts['body']!),
                    ],
                  ),
                ),
              ),
            );
          }
          }
        );
      },
    );
  }
}
