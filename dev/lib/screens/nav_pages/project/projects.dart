import 'package:bbf_app/screens/nav_pages/project/project_card.dart';
import 'package:bbf_app/utils/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

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
              ? [
                Colors.green.shade900,
                  Colors.grey.shade700,
                ]
              : [Colors.grey.shade300, Colors.green.shade200],
        ),
      ), 
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text(
                'Projekte',
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.6,
                child: PageView(
                  controller: _controller,
                  children: [Project(), Project(), Project()],
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
      ),
    );
  }
}
