import 'package:bbf_app/backend/services/calendar_service.dart';
import 'package:bbf_app/components/text_button.dart';
import 'package:bbf_app/utils/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:numberpicker/numberpicker.dart';

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

  TimeOfDay? selectedBeginTime; // beginning of the event
  TimeOfDay? selectedEndTime; // end of the event
  int? frequency; // how often the event repeats (e.g., every 2 weeks)
  String? repeat; // how the event repeats (e.g., daily, weekly, monthly) used for backend
  String? repeatLabel; // how the event repeats (e.g., daily, weekly, monthly) used for frontend

  DateTime? selectedDate; // date of the event
  int selectedNumber = 1; // number of times the event repeats

  // Function to pick beginning and end time for the event
  void pickTime(String type) {
    DatePicker.showTimePicker(
      context,
      showSecondsColumn: false,
      locale: LocaleType.de,
      onConfirm: (time) {
        setState(() {
          final selected = TimeOfDay(hour: time.hour, minute: time.minute);

          if (type == 'begin') {
            selectedBeginTime = selected;
          } else if (type == 'end') {
            selectedEndTime = selected;
          }
        });
      },
    );
  }

  // Function to pick date for the event
  void pickDate() {
    DatePicker.showDatePicker(
      context,
      showTitleActions: true,
      minTime: DateTime(2020, 1, 1),
      maxTime: DateTime(2030, 12, 31),
      onConfirm: (date) {
        setState(() {
          selectedDate = date;
        });
      },
      currentTime: DateTime.now(),
      locale: LocaleType.de,
    );
  }

  // Function to show a modal bottom sheet for selecting the repeat option
  Future<Map<String, String>?> showRepeatPicker(BuildContext context) async {
    return await showModalBottomSheet<Map<String, String>>(
      context: context,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.block),
              title: Text("Nicht wiederholen"),
              onTap: () {
                Navigator.pop(context, {
                  "value": "none",
                  "label": "Nicht wiederholen",
                });
              },
            ),

            ListTile(
              leading: const Icon(Icons.today),
              title: Text("Täglich"),
              onTap: () {
                Navigator.pop(context, {"value": "daily", "label": "Täglich"});
              },
            ),

            ListTile(
              leading: const Icon(Icons.calendar_view_week),
              title: Text("Wöchentlich"),
              onTap: () {
                Navigator.pop(context, {
                  "value": "weekly",
                  "label": "Wöchentlich",
                });
              },
            ),
          ],
        );
      },
    );
  }

  // Function to show a modal bottom sheet for selecting the frequency of the event
  Future<int?> showFrequencyPicker(
    BuildContext context,
    int currentValue,
  ) async {
    int selectedValue = currentValue;

    return await showModalBottomSheet<int>(
      context: context,

      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Frequenz auswählen",
                    style: Theme.of(context).textTheme.titleLarge,
                  ),

                  const SizedBox(height: 20),

                  NumberPicker(
                    value: selectedValue,
                    minValue: 1,
                    maxValue: 52,
                    onChanged: (value) {
                      setModalState(() {
                        selectedValue = value;
                      });
                    },
                  ),

                  const SizedBox(height: 20),

                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context, selectedValue);
                    },
                    child: const Text("Bestätigen"),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(height: 5),
                  Text(
                    'Event hinzufügen',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  SizedBox(height: 10),
                  // Buttons to pick (beginning and end) time and date
                  BTextButton(
                    onPressed: () => pickTime('begin'),
                    text: selectedBeginTime == null
                        ? 'Uhrzeit Beginn auswählen'
                        : 'Uhrzeit Beginn: ${selectedBeginTime!.hour.toString().padLeft(2, '0')}:${selectedBeginTime!.minute.toString().padLeft(2, '0')} Uhr',
                  ),
                  BTextButton(
                    onPressed: () => pickTime('end'),
                    text: selectedEndTime == null
                        ? 'Uhrzeit Ende auswählen'
                        : 'Uhrzeit Ende: ${selectedEndTime!.hour.toString().padLeft(2, '0')}:${selectedEndTime!.minute.toString().padLeft(2, '0')} Uhr',
                  ),
                  BTextButton(
                    onPressed: () => pickDate(),
                    text: selectedDate == null
                        ? 'Datum auswählen'
                        : 'Datum: ${selectedDate!.day.toString().padLeft(2, '0')}.${selectedDate!.month.toString().padLeft(2, '0')}.${selectedDate!.year}',
                  ),
                  // Buttons to pick repeat option and frequency
                  BTextButton(
                    onPressed: () async {
                      final result = await showRepeatPicker(context);
          
                      if (result != null) {
                        setState(() {
                          repeat = result['value'];
                          repeatLabel = result['label'];
                        });
                      }
                    },
                    text: repeatLabel == null
                        ? "Wiederholen"
                        : "Wiederholen: $repeatLabel",
                  ),
                  BTextButton(
                    onPressed: () async {
                      final result = await showFrequencyPicker(
                        context,
                        frequency ?? 1,
                      );
          
                      if (result != null) {
                        setState(() {
                          frequency = result;
                        });
                      }
                    },
                    text: frequency == null
                        ? "Frequenz auswählen"
                        : "Frequenz: $frequency",
                  ),
                  // TextFields to input title, content, location, and sign-up link
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
                      labelText: 'Beschreibung',
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
                          int beginTimeInMinutes = selectedBeginTime != null
                              ? selectedBeginTime!.hour * 60 +
                                    selectedBeginTime!.minute
                              : 0;
                          int endTimeInMinutes = selectedEndTime != null
                              ? selectedEndTime!.hour * 60 +
                                    selectedEndTime!.minute
                              : 0;
                          await calendarService.addEventToBackEnd(
                            titleTextController.text,
                            contentTextController.text,
                            locationTextController.text,
                            selectedDate!.year,
                            selectedDate!.month,
                            selectedDate!.day,
                            beginTimeInMinutes,
                            endTimeInMinutes,
                            repeat!,
                            frequency!,
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
    );
  }
}
