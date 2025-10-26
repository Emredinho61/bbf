import 'package:flutter/material.dart';

class ExpanedInformationPage extends StatelessWidget {
  final Map<String, dynamic> information;
  ExpanedInformationPage({super.key, required this.information});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
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
      padding: const EdgeInsets.all(16.0),
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
      padding: const EdgeInsets.all(16.0),
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
      padding: const EdgeInsets.only(bottom: 20),
      child: Text(
        information['Titel'],
        style: Theme.of(context).textTheme.headlineMedium,
      ),
    );
  }
}
