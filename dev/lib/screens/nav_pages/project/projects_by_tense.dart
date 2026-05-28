import 'package:bbf_app/backend/services/projects_service.dart';
import 'package:bbf_app/utils/helper/projects_page_helper.dart';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:bbf_app/utils/constants/colors.dart';
import 'project_card.dart';
import 'package:skeletonizer/skeletonizer.dart';

class ProjectsByTense extends StatefulWidget {
  final String tense;
  ProjectsByTense({super.key, required this.tense});

  @override
  State<ProjectsByTense> createState() => _ProjectsByTenseState();
}

class _ProjectsByTenseState extends State<ProjectsByTense> {
  late List<Map<String, dynamic>> allProjectsOfACertainTenseFromCache;
  final ProjectsPageHelper projectsPageHelper = ProjectsPageHelper();
  final ProjectsService projectsService = ProjectsService();
  bool _isLoading = true;
  @override
  void initState() {
    super.initState();
    // First initialize projects saved in cache
    allProjectsOfACertainTenseFromCache = getEitherPastOrFutureProjectsFromCache(widget.tense);
    // Then check, if the projects in cache are up to date with the projects in backend. 
    // If not up to date, then update the cache content  
    _initPage(widget.tense);
  }

  List<Map<String, dynamic>> getEitherPastOrFutureProjectsFromCache(String tense) {
    if (tense == 'past') {
      return projectsPageHelper.getPastProjectsFromCache();
    } else {
      return projectsPageHelper.getFutureProjectsFromCache();
    }
  }

  Future<void> _initPage(String tense) async {
    if (tense == 'past') {
      final loadedPastProjectsFromBackend = await projectsService.getPastProjectsFromBackend();
      if (loadedPastProjectsFromBackend != allProjectsOfACertainTenseFromCache) {
        projectsPageHelper.setPastProjectsInCache(loadedPastProjectsFromBackend);
        setState(() {
          allProjectsOfACertainTenseFromCache = loadedPastProjectsFromBackend;
        });
        setState(() => _isLoading = false);
      }
    } else {
      final loadedFutureProjects = await projectsService.getFutureProjectsFromBackend();
      if (loadedFutureProjects != allProjectsOfACertainTenseFromCache) {
        projectsPageHelper.setFutureProjectsInCache(loadedFutureProjects);
        setState(() {
          allProjectsOfACertainTenseFromCache = loadedFutureProjects;
        });
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // Setting up the layout for the projects
    return Scaffold(
      backgroundColor: BColors.backgroundColor,
      body: LayoutBuilder(
        builder: (context, constraints) {
          const crossAxisCount = 2;
          const spacing = 8.0;
          final itemWidth =
              (constraints.maxWidth - spacing * (crossAxisCount + 1)) /
              crossAxisCount;
          final columns = List.generate(crossAxisCount, (_) => <double>[]);

          for (var i = 0; i < allProjectsOfACertainTenseFromCache.length; i++) {
            final h = (200.0) + 48;
            final col = i % crossAxisCount;
            final top = columns[col].isEmpty
                ? 0.0
                : columns[col].last + spacing;
            columns[col].add(top + h);
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(spacing),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(crossAxisCount, (col) {
                return Padding(
                  padding: EdgeInsets.only(
                    right: col != crossAxisCount - 1 ? spacing : 0,
                  ),
                  child: SizedBox(
                    width: itemWidth,
                    child: Column(
                      children: [
                        for (
                          var i = col;
                          i < allProjectsOfACertainTenseFromCache.length;
                          i += crossAxisCount
                        )
                          Padding(
                            padding: const EdgeInsets.only(bottom: spacing),
                            child: Project(
                              title: allProjectsOfACertainTenseFromCache[i]['title'],
                              docId: allProjectsOfACertainTenseFromCache[i]['id'],
                              year: allProjectsOfACertainTenseFromCache[i]['year'],
                              month: allProjectsOfACertainTenseFromCache[i]['month'],
                              day: allProjectsOfACertainTenseFromCache[i]['day'],
                              height: 100,
                              color: Colors.blue,
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          );
        },
      ),
    );
  }
}