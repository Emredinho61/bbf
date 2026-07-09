import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ExpanedInformationPage extends StatelessWidget {
  final Map<String, dynamic> information;
  ExpanedInformationPage({super.key, required this.information});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: SingleChildScrollView(
            child: Card(
              child: Padding(
                padding: EdgeInsets.all(8.w),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ListTile(
                      title: TitleText(information: information),
                      subtitle: MainText(information: information),
                    ),
                    ExpandedText(information: information),
                    ActionsRow(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ActionsRow extends StatelessWidget {
  const ActionsRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Icon(Icons.arrow_back_ios),
          ),
        ],
      ),
    );
  }
}

class ExpandedText extends StatelessWidget {
  const ExpandedText({super.key, required this.information});

  final dynamic information;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Text(
        information['Expanded'],
        style: Theme.of(context).textTheme.bodyMedium,
      ),
    );
  }
}

class MainText extends StatelessWidget {
  const MainText({super.key, required this.information});

  final dynamic information;

  @override
  Widget build(BuildContext context) {
    return Text(
      information['Text'],
      style: Theme.of(context).textTheme.bodyLarge,
    );
  }
}

class TitleText extends StatelessWidget {
  const TitleText({super.key, required this.information});

  final dynamic information;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 20.h),
      child: Text(
        information['Titel'],
        style: Theme.of(context).textTheme.headlineMedium,
      ),
    );
  }
}
