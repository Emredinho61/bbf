import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:bbf_app/utils/constants/colors.dart';
import 'project_card.dart';

class Projects extends StatelessWidget {
  Projects({super.key});

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
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('projects')
                .orderBy('date', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(child: Text("Keine Projekte verfügbar"));
              }

              final projects = snapshot.data!.docs;

              return Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text('Projekte',
                      style: Theme.of(context).textTheme.headlineLarge),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.6,
                    child: PageView.builder(
                      controller: _controller,
                      itemCount: projects.length,
                      itemBuilder: (context, index) {
                        return Project(docId: projects[index].id);
                      },
                    ),
                  ),
                  SmoothPageIndicator(
                    controller: _controller,
                    count: projects.length,
                    effect: ScrollingDotsEffect(
                      activeDotColor: BColors.primary,
                      dotColor: Colors.green.shade300,
                      spacing: 10,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
