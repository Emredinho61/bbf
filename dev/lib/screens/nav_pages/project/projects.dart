import 'package:bbf_app/backend/services/projects_service.dart';
import 'package:bbf_app/utils/helper/projects_page_helper.dart';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:bbf_app/utils/constants/colors.dart';
import 'project_card.dart';

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
  // init Page Function
  @override
  void initState() {
    super.initState();
    // Function to load projects from prefs instead of backend first
    allProjects = projectsPageHelper.getAllProjects();
    _initPage();
  }

  Future<void> _initPage() async {
    // Function to load projects from backend and then compare them with prefs
    // If there is a difference, then update prefs and show user updated version
    final loadedProjects = await projectsService.getAllProjects();
    if (loadedProjects != allProjects) {
      projectsPageHelper.setallProjects(loadedProjects);
      setState(() {
        allProjects = loadedProjects;
      });
    }
    setState(() {
      _isLoading = false;
    });
  }

  // function which returns the loadMarkdownParts from already loaded docs
  final PageController _controller = PageController(viewportFraction: 0.8);

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
              ? const Center(child: CircularProgressIndicator())
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
