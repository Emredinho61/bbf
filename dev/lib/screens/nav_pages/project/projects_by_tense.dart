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
  late List<Map<String, dynamic>> allProjects;
  final ProjectsPageHelper projectsPageHelper = ProjectsPageHelper();
  final ProjectsService projectsService = ProjectsService();
  bool _isLoading = true;
  @override
  void initState() {
    super.initState();
    allProjects = getEitherPastOrFutureProjects(widget.tense);
    _initPage(widget.tense);
  }

  List<Map<String, dynamic>> getEitherPastOrFutureProjects(String tense) {
    if (tense == 'past') {
      return projectsPageHelper.getPastProjects();
    } else {
      return projectsPageHelper.getFutureProjects();
    }
  }

  Future<void> _initPage(String tense) async {
    if (tense == 'past') {
      final loadedPastProjects = await projectsService.getPastProjects();
      if (loadedPastProjects != allProjects) {
        projectsPageHelper.setPastProjects(loadedPastProjects);
        setState(() {
          allProjects = loadedPastProjects;
        });
        setState(() => _isLoading = false);
      }
    } else {
      final loadedFutureProjects = await projectsService.getFutureProjects();
      if (loadedFutureProjects != allProjects) {
        projectsPageHelper.setFutureProjects(loadedFutureProjects);
        setState(() {
          allProjects = loadedFutureProjects;
        });
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
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

          for (var i = 0; i < allProjects.length; i++) {
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
                          i < allProjects.length;
                          i += crossAxisCount
                        )
                          Padding(
                            padding: const EdgeInsets.only(bottom: spacing),
                            child: _MasonryCard(
                              title: allProjects[i]['title'],
                              id: allProjects[i]['id'],
                              height: 100.0,
                              color: Colors.blue,
                              year: allProjects[i]['year'],
                              month: allProjects[i]['month'],
                              day: allProjects[i]['day'],
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

class _MasonryCard extends StatelessWidget {
  final String title;
  final String id;
  final double height;
  final Color color;
  final int year;
  final int month;
  final int day;

  const _MasonryCard({
    required this.title,
    required this.id,
    required this.height,
    required this.color,
    required this.year,
    required this.month,
    required this.day,
  });

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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.3 : 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Project(
              docId: id,
              year: year,
              month: month,
              day: day,
              height: height,
              color: color,
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'Dies ist eine kleine Beschreibung für das Projekt',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).hintColor,
              ),
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.15),
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
                        '$day. ${_monthName(month)} $year',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: const Color.fromARGB(255, 0, 0, 0),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward,
                  size: 14,
                  color: const Color.fromARGB(255, 0, 0, 0),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
