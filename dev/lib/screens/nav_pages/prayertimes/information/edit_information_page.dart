import 'package:bbf_app/backend/services/information_service.dart';
import 'package:bbf_app/utils/constants/colors.dart';
import 'package:flutter/material.dart';

class UpdateInformaionPage extends StatelessWidget {
  String title;
  String text;
  String expanded;
  UpdateInformaionPage({
    super.key,
    required this.title,
    required this.text,
    required this.expanded,
  });

  @override
  Widget build(BuildContext context) {
    InformationService informationService = InformationService();
    final TextEditingController titelController = TextEditingController(text: title);
    final TextEditingController textController = TextEditingController(text: text);
    final TextEditingController expandedController = TextEditingController(text: expanded);
    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
          child: Card(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text(
                  'Information bearbeiten',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                Padding(
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
                ),
                Padding(
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
                ),
                Padding(
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
                ),
                Row(
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
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
