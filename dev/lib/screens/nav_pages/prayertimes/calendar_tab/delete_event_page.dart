import 'package:bbf_app/backend/services/trigger_background_functions_service.dart';
import 'package:bbf_app/utils/constants/colors.dart';
import 'package:flutter/material.dart';

class DeleteEventPage extends StatefulWidget {
  const DeleteEventPage({super.key});

  @override
  State<DeleteEventPage> createState() => _DeleteEventPageState();
}

class _DeleteEventPageState extends State<DeleteEventPage> {
  TextEditingController idTextController = TextEditingController();
  TextEditingController idSingleTextController = TextEditingController();
  TextEditingController yearTextController = TextEditingController();
  TextEditingController monthTextController = TextEditingController();
  TextEditingController dayTextController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  SizedBox(height: 8),
                  Text('Alle Events einer bestimmten ID löschen'),
                  SizedBox(height: 8),
                  TextField(
                    controller: idTextController,
                    cursorColor: BColors.primary,
                    minLines: 1,
                    maxLines: 5,
                    keyboardType: TextInputType.multiline,
                    decoration: InputDecoration(
                      labelText: 'ID - zB. 05',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: BColors.primary,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Icon(Icons.arrow_back_ios),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          await calendarService.deleteEventsWithId(
                            idTextController.text,
                          );
                          Navigator.pop(context, true);
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text('Bestätigen'),
                        ),
                      ),
                    ],
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
