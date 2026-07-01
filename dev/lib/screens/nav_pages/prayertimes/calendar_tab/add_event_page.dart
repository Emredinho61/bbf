import 'package:bbf_app/backend/services/calendar_service.dart';
import 'package:bbf_app/components/events/event_pickers.dart';
import 'package:bbf_app/components/text_button.dart';
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

  TimeOfDay? selectedBeginTime; // beginning of the event
  TimeOfDay? selectedEndTime; // end of the event
  int? frequency; // how often the event repeats (e.g., every 2 weeks)
  String? repeat; // how the event repeats (e.g., daily, weekly, monthly) used for backend
  String? repeatLabel; // how the event repeats (e.g., daily, weekly, monthly) used for frontend

  bool _usePrayerTimes = false; // whether prayer names are used instead of fixed times
  String? _startPrayer; // CSV key of the selected start prayer (e.g. "Maghrib")
  String? _startPrayerLabel; // display name of the selected start prayer
  String? _endPrayer;
  String? _endPrayerLabel;

  DateTime? selectedDate; // date of the event
  int selectedNumber = 1; // number of times the event repeats

  bool _displayErrorText = false; // shows the "Pflichtfelder" hint on submit

  // Every field is required except the sign-up link. Frequency is only
  // required when a repeat option other than "none" was chosen.
  bool get _isFormValid {
    final repeatSelected = repeat != null;
    final frequencyValid = repeat == 'none' || frequency != null;
    final timesValid = _usePrayerTimes
        ? (_startPrayer != null && _endPrayer != null)
        : (selectedBeginTime != null && selectedEndTime != null);

    return timesValid &&
        selectedDate != null &&
        repeatSelected &&
        frequencyValid &&
        titleTextController.text.trim().isNotEmpty &&
        contentTextController.text.trim().isNotEmpty &&
        locationTextController.text.trim().isNotEmpty;
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
                  // Toggle: fixed time vs. prayer-based time
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Gebetszeiten verwenden'),
                      Switch(
                        value: _usePrayerTimes,
                        onChanged: (value) {
                          setState(() {
                            _usePrayerTimes = value;
                            if (value) {
                              selectedBeginTime = null;
                              selectedEndTime = null;
                            } else {
                              _startPrayer = null;
                              _startPrayerLabel = null;
                              _endPrayer = null;
                              _endPrayerLabel = null;
                            }
                          });
                        },
                      ),
                    ],
                  ),
                  // Time pickers: prayer-based or fixed
                  if (_usePrayerTimes) ...[
                    BTextButton(
                      onPressed: () async {
                        final result = await EventPickers.showPrayerPicker(
                          context,
                        );
                        if (result != null) {
                          setState(() {
                            _startPrayer = result['value'];
                            _startPrayerLabel = result['label'];
                          });
                        }
                      },
                      text: _startPrayerLabel == null
                          ? 'Startgebet auswählen *'
                          : 'Beginn: $_startPrayerLabel',
                    ),
                    BTextButton(
                      onPressed: () async {
                        final result = await EventPickers.showPrayerPicker(
                          context,
                        );
                        if (result != null) {
                          setState(() {
                            _endPrayer = result['value'];
                            _endPrayerLabel = result['label'];
                          });
                        }
                      },
                      text: _endPrayerLabel == null
                          ? 'Endgebet auswählen *'
                          : 'Ende: $_endPrayerLabel',
                    ),
                  ] else ...[
                    BTextButton(
                      onPressed: () => EventPickers.pickTime(
                        context,
                        onConfirm: (selected) {
                          setState(() => selectedBeginTime = selected);
                        },
                      ),
                      text: selectedBeginTime == null
                          ? 'Uhrzeit Beginn auswählen *'
                          : 'Uhrzeit Beginn: ${selectedBeginTime!.hour.toString().padLeft(2, '0')}:${selectedBeginTime!.minute.toString().padLeft(2, '0')} Uhr',
                    ),
                    BTextButton(
                      onPressed: () => EventPickers.pickTime(
                        context,
                        onConfirm: (selected) {
                          setState(() => selectedEndTime = selected);
                        },
                      ),
                      text: selectedEndTime == null
                          ? 'Uhrzeit Ende auswählen *'
                          : 'Uhrzeit Ende: ${selectedEndTime!.hour.toString().padLeft(2, '0')}:${selectedEndTime!.minute.toString().padLeft(2, '0')} Uhr',
                    ),
                  ],
                  BTextButton(
                    onPressed: () => EventPickers.pickDate(
                      context,
                      onConfirm: (date) {
                        setState(() => selectedDate = date);
                      },
                    ),
                    text: selectedDate == null
                        ? 'Datum auswählen *'
                        : 'Datum: ${selectedDate!.day.toString().padLeft(2, '0')}.${selectedDate!.month.toString().padLeft(2, '0')}.${selectedDate!.year}',
                  ),
                  // Buttons to pick repeat option and frequency
                  BTextButton(
                    onPressed: () async {
                      final result = await EventPickers.showRepeatPicker(
                        context,
                      );

                      if (result != null) {
                        setState(() {
                          repeat = result['value'];
                          repeatLabel = result['label'];
                          // frequency only applies to repeating events
                          if (repeat == 'none') frequency = null;
                        });
                      }
                    },
                    text: repeatLabel == null
                        ? "Wiederholen *"
                        : "Wiederholen: $repeatLabel",
                  ),
                  if (repeat != null && repeat != 'none')
                    BTextButton(
                      onPressed: () async {
                        final result = await EventPickers.showFrequencyPicker(
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
                          ? "Frequenz auswählen *"
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
                      labelText: 'Titel *',
                      errorText:
                          _displayErrorText &&
                              titleTextController.text.trim().isEmpty
                          ? 'Pflichtfeld'
                          : null,
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
                      labelText: 'Beschreibung *',
                      errorText:
                          _displayErrorText &&
                              contentTextController.text.trim().isEmpty
                          ? 'Pflichtfeld'
                          : null,
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
                      labelText: 'Ort - zB. Großer Gebetsraum *',
                      errorText:
                          _displayErrorText &&
                              locationTextController.text.trim().isEmpty
                          ? 'Pflichtfeld'
                          : null,
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
                  if (_displayErrorText)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 5),
                      child: Text(
                        'Bitte alle Pflichtfelder ausfüllen!',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
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
                          if (!_isFormValid) {
                            setState(() => _displayErrorText = true);
                            return;
                          }
                          final navigator = Navigator.of(context);

                          final beginTimeInMinutes = _usePrayerTimes
                              ? 0
                              : (selectedBeginTime != null
                                    ? selectedBeginTime!.hour * 60 +
                                          selectedBeginTime!.minute
                                    : 0);
                          final endTimeInMinutes = _usePrayerTimes
                              ? 0
                              : (selectedEndTime != null
                                    ? selectedEndTime!.hour * 60 +
                                          selectedEndTime!.minute
                                    : 0);
                          // frequency only applies to repeating events, none -> 0
                          final eventFrequency =
                              (repeat == null || repeat == 'none')
                              ? 0
                              : (frequency ?? 1);
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
                            eventFrequency,
                            signUpTextController.text,
                            startPrayer: _usePrayerTimes ? _startPrayer : null,
                            endPrayer: _usePrayerTimes ? _endPrayer : null,
                          );
                          navigator.pop(true);
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
