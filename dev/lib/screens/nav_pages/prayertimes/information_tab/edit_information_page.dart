import 'package:bbf_app/backend/services/information_service.dart';
import 'package:bbf_app/utils/constants/colors.dart';
import 'package:flutter/material.dart';

/*
If Admin want to change any part of the information card, then he can do it here
*/

// ignore: must_be_immutable
class UpdateInformationPage extends StatelessWidget {
  String title;
  String text;
  String expanded;
  UpdateInformationPage({
    super.key,
    required this.title,
    required this.text,
    required this.expanded,
  });

  @override
  Widget build(BuildContext context) {
    InformationService informationService = InformationService();
    final TextEditingController titelController = TextEditingController(
      text: title,
    );
    final TextEditingController textController = TextEditingController(
      text: text,
    );
    final TextEditingController expandedController = TextEditingController(
      text: expanded,
    );
    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
          child: Card(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Title(),
                TitleTextField(titelController: titelController),
                MainTextField(textController: textController),
                ExpandedTextField(expandedController: expandedController),
                ActionsRow(informationService: informationService, titelController: titelController, textController: textController, expandedController: expandedController),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ActionsRow extends StatelessWidget {
  const ActionsRow({
    super.key,
    required this.informationService,
    required this.titelController,
    required this.textController,
    required this.expandedController,
  });

  final InformationService informationService;
  final TextEditingController titelController;
  final TextEditingController textController;
  final TextEditingController expandedController;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Icon(Icons.arrow_back_ios),
        ),
        ElevatedButton(
          onPressed: () async {
            await informationService.updateInformation(
              titelController.text,
              textController.text,
              expandedController.text,
            );
            Navigator.pop(context, true);
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('Ändern'),
          ),
        ),
      ],
    );
  }
}

class ExpandedTextField extends StatelessWidget {
  const ExpandedTextField({
    super.key,
    required this.expandedController,
  });

  final TextEditingController expandedController;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        controller: expandedController,
        cursorColor: BColors.primary,
        minLines: 3,
        maxLines: 5,
        keyboardType: TextInputType.multiline,
        decoration: InputDecoration(
          labelText: 'Erweiterten Text',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: BColors.primary,
              width: 2,
            ),
          ),
        ),
      ),
    );
  }
}

class MainTextField extends StatelessWidget {
  const MainTextField({
    super.key,
    required this.textController,
  });

  final TextEditingController textController;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        controller: textController,
        cursorColor: BColors.primary,
        minLines: 2,
        maxLines: 3,
        keyboardType: TextInputType.multiline,
        decoration: InputDecoration(
          labelText: 'Text',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: BColors.primary,
              width: 2,
            ),
          ),
        ),
      ),
    );
  }
}

class TitleTextField extends StatelessWidget {
  const TitleTextField({
    super.key,
    required this.titelController,
  });

  final TextEditingController titelController;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        controller: titelController,
        cursorColor: BColors.primary,
        decoration: InputDecoration(
          labelText: 'Titel',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: BColors.primary,
              width: 2,
            ),
          ),
        ),
      ),
    );
  }
}

class Title extends StatelessWidget {
  const Title({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      'Information bearbeiten',
      style: Theme.of(context).textTheme.headlineMedium,
    );
  }
}
