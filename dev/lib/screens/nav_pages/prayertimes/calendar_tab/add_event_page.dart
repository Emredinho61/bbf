import 'package:bbf_app/backend/services/calendar_service.dart';
import 'package:bbf_app/utils/constants/colors.dart';
import 'package:flutter/material.dart';

class AddEventPage extends StatefulWidget {
  const AddEventPage({super.key});

  @override
  State<AddEventPage> createState() => _AddEventPageState();
}

class _AddEventPageState extends State<AddEventPage> {
  CalendarService calendarService = CalendarService();
  final TextEditingController idTextController = TextEditingController();
  final TextEditingController titleTextController = TextEditingController();
  final TextEditingController contentTextController = TextEditingController();
  final TextEditingController timeTextController = TextEditingController();
  final TextEditingController locationTextController = TextEditingController();
  final TextEditingController yearTextController = TextEditingController();
  final TextEditingController monthTextController = TextEditingController();
  final TextEditingController dayTextController = TextEditingController();
  final TextEditingController hourTextController = TextEditingController();
  final TextEditingController minuteTextController = TextEditingController();
  final TextEditingController repeatTextController = TextEditingController();
  final TextEditingController frequencyTextController = TextEditingController();
  final TextEditingController signUpTextController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    SizedBox(height: 5),
                    Text(
                      'Event hinzufügen',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: idTextController,
                      cursorColor: BColors.primary,
                      minLines: 1,
                      maxLines: 5,
                      keyboardType: TextInputType.multiline,
                      decoration: InputDecoration(
                        labelText: 'id - zB. 09',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: BColors.primary,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 5),
                    TextField(
                      controller: titleTextController,
                      cursorColor: BColors.primary,
                      minLines: 1,
                      maxLines: 5,
                      keyboardType: TextInputType.multiline,
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
                    SizedBox(height: 5),
                    TextField(
                      controller: contentTextController,
                      cursorColor: BColors.primary,
                      minLines: 1,
                      maxLines: 5,
                      keyboardType: TextInputType.multiline,
                      decoration: InputDecoration(
                        labelText: 'Inhalt',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: BColors.primary,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 5),
                    TextField(
                      controller: timeTextController,
                      cursorColor: BColors.primary,
                      minLines: 1,
                      maxLines: 5,
                      keyboardType: TextInputType.multiline,
                      decoration: InputDecoration(
                        labelText: 'Uhrzeit - zB. 15:05',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: BColors.primary,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 5),
                    TextField(
                      controller: locationTextController,
                      cursorColor: BColors.primary,
                      minLines: 1,
                      maxLines: 5,
                      keyboardType: TextInputType.multiline,
                      decoration: InputDecoration(
                        labelText: 'Ort - zB. Großer Gebetsraum',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: BColors.primary,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 5),
                    TextField(
                      controller: yearTextController,
                      cursorColor: BColors.primary,
                      minLines: 1,
                      maxLines: 5,
                      keyboardType: TextInputType.multiline,
                      decoration: InputDecoration(
                        labelText: 'Jahr - zB. 2025',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: BColors.primary,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 5),
                    TextField(
                      controller: monthTextController,
                      cursorColor: BColors.primary,
                      minLines: 1,
                      maxLines: 5,
                      keyboardType: TextInputType.multiline,
                      decoration: InputDecoration(
                        labelText: 'Monat - zB. 10',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: BColors.primary,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 5),
                    TextField(
                      controller: dayTextController,
                      cursorColor: BColors.primary,
                      minLines: 1,
                      maxLines: 5,
                      keyboardType: TextInputType.multiline,
                      decoration: InputDecoration(
                        labelText: 'Tag - zB. 05',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: BColors.primary,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 5),
                    TextField(
                      controller: hourTextController,
                      cursorColor: BColors.primary,
                      minLines: 1,
                      maxLines: 5,
                      keyboardType: TextInputType.multiline,
                      decoration: InputDecoration(
                        labelText: 'Stunde - zB. 15',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: BColors.primary,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 5),
                    TextField(
                      controller: minuteTextController,
                      cursorColor: BColors.primary,
                      minLines: 1,
                      maxLines: 5,
                      keyboardType: TextInputType.multiline,
                      decoration: InputDecoration(
                        labelText: 'Minute - zB. 05',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: BColors.primary,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 5),

                    TextField(
                      controller: repeatTextController,
                      cursorColor: BColors.primary,
                      minLines: 1,
                      maxLines: 5,
                      keyboardType: TextInputType.multiline,
                      decoration: InputDecoration(
                        labelText: 'Wiederholen - daily oder weekly oder none',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: BColors.primary,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 5),

                    TextField(
                      controller: frequencyTextController,
                      cursorColor: BColors.primary,
                      minLines: 1,
                      maxLines: 5,
                      keyboardType: TextInputType.multiline,
                      decoration: InputDecoration(
                        labelText: 'Häufigkeit - zB. 5',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: BColors.primary,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 5),
                    TextField(
                      controller: signUpTextController,
                      cursorColor: BColors.primary,
                      minLines: 1,
                      maxLines: 5,
                      keyboardType: TextInputType.multiline,
                      decoration: InputDecoration(
                        labelText: 'Anmeldelink',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: BColors.primary,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 5),
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
                            await calendarService.addEventToBackEnd(
                              idTextController.text,
                              titleTextController.text,
                              contentTextController.text,
                              locationTextController.text,
                              timeTextController.text,
                              yearTextController.text,
                              monthTextController.text,
                              dayTextController.text,
                              hourTextController.text,
                              minuteTextController.text,
                              repeatTextController.text,
                              frequencyTextController.text,
                              signUpTextController.text,
                            );
                            Navigator.pop(context, true);
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8.0,
                            ),
                            child: Text('Hinzufügen'),
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
      ),
    );
  }
}
