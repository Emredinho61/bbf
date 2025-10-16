import 'package:bbf_app/screens/nav_pages/prayertimes/calendar_tab/events.dart';
import 'package:flutter/material.dart';

class Eventspage extends StatefulWidget {
  final List<Event> events;
  final DateTime focusedDay;
  Eventspage({super.key, required this.events, required this.focusedDay});

  @override
  State<Eventspage> createState() => _EventspageState();
}

class _EventspageState extends State<Eventspage> {
  String year = '';
  String month = '';
  String day = '';
  @override
  void initState() {
    super.initState();
    year = widget.focusedDay.year.toString();
    month = widget.focusedDay.month.toString();
    day = widget.focusedDay.day.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SingleChildScrollView(
            child: Center(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: Text(
                          'Alle Ereignisse am $day.$month.$year',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                      ),
                      SizedBox(height: 10),
                      ...widget.events.map(
                        (event) => Card(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Center(
                                  child: Text(
                                    event.title,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodyLarge,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text('Beschreibung: ${event.content}'),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text('Uhrzeit: ${event.time} Uhr'),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text('Ort: ${event.location}'),
                              ),
                            ],
                          ),
                        ),
                      ),
                      ActionsRow()
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// this class also exists in information page -> double code
class ActionsRow extends StatelessWidget {
  const ActionsRow({
    super.key,
  });

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