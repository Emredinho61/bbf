import 'package:bbf_app/utils/constants/colors.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';

class ProjectDetailsPage extends StatefulWidget {
  final String projectId;
  final Map<String, dynamic> data;

  const ProjectDetailsPage({
    super.key,
    required this.projectId,
    required this.data,
  });

  @override
  State<ProjectDetailsPage> createState() => _ProjectDetailsPageState();
}

class _ProjectDetailsPageState extends State<ProjectDetailsPage> {
  @override
  Widget build(BuildContext context) {
    final data = widget.data;

    return Scaffold(
      backgroundColor: Colors.black.withValues(alpha: 0.4),
      body: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          height: MediaQuery.of(context).size.height * 0.9,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.grey.shade600
                : BColors.secondary,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(25),
            ),
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 8.0,
                vertical: 16.0,
              ),
              child: Column(
                children: [
                  /// TITLE
                  Text(
                    data['title'] ?? '',
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),

                  const SizedBox(height: 10),

                  /// IMAGE (mit Hero ready)
                  (data['imageUrl'] ?? '').isNotEmpty
                      ? Hero(
                          tag: widget.projectId,
                          child: CachedNetworkImage(
                            imageUrl: data['imageUrl'],
                            height: 100,
                            width: 100,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => const SizedBox(
                              height: 100,
                              width: 100,
                              child: Center(
                                child: CircularProgressIndicator(),
                              ),
                            ),
                            errorWidget: (context, url, error) =>
                                const Icon(Icons.error),
                          ),
                        )
                      : Image.asset(
                          'assets/images/bbf-logo.png',
                          height: 100,
                          width: 50,
                        ),

                  const SizedBox(height: 10),

                  /// MARKDOWN
                  MarkdownBody(
                    data: data['body'] ?? '',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}