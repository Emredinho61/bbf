import 'package:bbf_app/backend/services/information_service.dart';
import 'package:bbf_app/components/text_field.dart';
import 'package:bbf_app/utils/constants/colors.dart';
import 'package:flutter/material.dart';

/*
If admin chooses to add a new Information, then he will be redirected to this page.
This page allows the admin to a new Information card containing title, the actual information 
and if needed, an extended Text for more details 
*/

class AddInformationPage extends StatelessWidget {
  const AddInformationPage({super.key});

  @override
  Widget build(BuildContext context) {
    InformationService informationService = InformationService();
    final TextEditingController idController = TextEditingController();
    final TextEditingController titelController = TextEditingController();
    final TextEditingController textController = TextEditingController();
    final TextEditingController expandedController = TextEditingController();
    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
          child: SingleChildScrollView(
            child: Card(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Title(),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: BTextField(
                      label: 'id',
                      controller: idController,
                      obscureText: false,
                      obligatory: false,
                    ),
                  ),
                  TitleTextField(titelController: titelController),
                  MainTextField(textController: textController),
                  ExpandedTextField(expandedController: expandedController),
                  ActionsRow(
                    idController: idController,
                    informationService: informationService,
                    titelController: titelController,
                    textController: textController,
                    expandedController: expandedController,
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

class Title extends StatelessWidget {
  const Title({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        'Information hinzufügen',
        style: Theme.of(context).textTheme.headlineMedium,
      ),
    );
  }
}

class ActionsRow extends StatelessWidget {
  const ActionsRow({
    super.key,
    required this.informationService,
    required this.idController,
    required this.titelController,
    required this.textController,
    required this.expandedController,
  });

  final InformationService informationService;
  final TextEditingController idController;
  final TextEditingController titelController;
  final TextEditingController textController;
  final TextEditingController expandedController;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        GoBackIcon(),
        AddInformationButton(
          informationService: informationService,
          idController: idController,
          titelController: titelController,
          textController: textController,
          expandedController: expandedController,
        ),
      ],
    );
  }
}

class AddInformationButton extends StatelessWidget {
  const AddInformationButton({
    super.key,
    required this.informationService,
    required this.idController,
    required this.titelController,
    required this.textController,
    required this.expandedController,
  });

  final InformationService informationService;
  final TextEditingController idController;
  final TextEditingController titelController;
  final TextEditingController textController;
  final TextEditingController expandedController;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        await informationService.addInformation(
          idController.text,
          titelController.text,
          textController.text,
          expandedController.text,
        );
        Navigator.pop(context, true);
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text('Hinzufügen'),
      ),
    );
  }
}

class GoBackIcon extends StatelessWidget {
  const GoBackIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
      },
      child: Icon(Icons.arrow_back_ios),
    );
  }
}

class ExpandedTextField extends StatelessWidget {
  const ExpandedTextField({super.key, required this.expandedController});

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
            borderSide: BorderSide(color: BColors.primary, width: 2),
          ),
        ),
      ),
    );
  }
}

class MainTextField extends StatelessWidget {
  const MainTextField({super.key, required this.textController});

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
            borderSide: BorderSide(color: BColors.primary, width: 2),
          ),
        ),
      ),
    );
  }
}

class TitleTextField extends StatelessWidget {
  const TitleTextField({super.key, required this.titelController});

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
            borderSide: BorderSide(color: BColors.primary, width: 2),
          ),
        ),
      ),
    );
  }
}
