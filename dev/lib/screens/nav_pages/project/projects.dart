import 'package:bbf_app/backend/services/projects_service.dart';
import 'package:bbf_app/utils/helper/projects_page_helper.dart';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:bbf_app/utils/constants/colors.dart';
import 'project_card.dart';
import 'package:skeletonizer/skeletonizer.dart';

class Projects extends StatefulWidget {
  Projects({super.key});

  @override
  State<Projects> createState() => _ProjectsState();
}

class _ProjectsState extends State<Projects> {
  late List<Map<String, dynamic>> allProjects;
  final ProjectsPageHelper projectsPageHelper = ProjectsPageHelper();
  final ProjectsService projectsService = ProjectsService();
  bool _isLoading = true;

  final PageController _controller = PageController(viewportFraction: 0.8);

  @override
  void initState() {
    super.initState();
    allProjects = projectsPageHelper.getAllProjects();
    _initPage();
  }

  Future<void> _initPage() async {
    final loadedProjects = await projectsService.getAllProjects();
    if (loadedProjects != allProjects) {
      projectsPageHelper.setallProjects(loadedProjects);
      setState(() {
        allProjects = loadedProjects;
      });
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [Colors.green.shade900, Colors.grey.shade700]
                : [Colors.grey.shade300, Colors.green.shade200],
          ),
        ),
        child: SafeArea(
          child: _isLoading
              ? Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Skeletonizer(
                    enabled: true,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Container(
                          height: 40,
                          width: 200,
                          color: Colors.white,
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.6,
                          child: PageView.builder(
                            controller: _controller,
                            itemCount: 3, // z.B. 3 Skeleton-Karten
                            itemBuilder: (context, index) {
                              return Card(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    children: [
                                      Container(
                                        height: 24,
                                        width: double.infinity,
                                        color: Colors.white,
                                      ),
                                      const SizedBox(height: 10),
                                      Container(
                                        height: 100,
                                        width: 100,
                                        color: Colors.white,
                                      ),
                                      const SizedBox(height: 15),
                                      Container(
                                        height: 60,
                                        width: double.infinity,
                                        color: Colors.white,
                                      ),
                                      const SizedBox(height: 5),
                                      Container(
                                        height: 40,
                                        width: 120,
                                        color: Colors.white,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        SmoothPageIndicator(
                          controller: _controller,
                          count: 3,
                          effect: ScrollingDotsEffect(
                            activeDotColor: BColors.primary,
                            dotColor: Colors.green.shade300,
                            spacing: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : allProjects.isEmpty
                  ? const Center(child: Text("Keine Projekte verfügbar"))
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text(
                          'Projekte',
                          style: Theme.of(context).textTheme.headlineLarge,
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.6,
                          child: PageView.builder(
                            controller: _controller,
                            itemCount: allProjects.length,
                            itemBuilder: (context, index) {
                              final project = allProjects[index];
                              return Project(docId: project['id']);
                            },
                          ),
                        ),
                        SmoothPageIndicator(
                          controller: _controller,
                          count: allProjects.length,
                          effect: ScrollingDotsEffect(
                            activeDotColor: BColors.primary,
                            dotColor: Colors.green.shade300,
                            spacing: 10,
                          ),
                        ),
                      ],
                    ),
        ),
      ),
    );
  }
}
