import 'package:bbf_app/screens/nav_pages/prayertimes/calendar_tab/events.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class Eventspage extends StatefulWidget {
  final List<Event> events;
  final DateTime focusedDay;
  final bool isUserAdmin;
  Eventspage({
    super.key,
    required this.events,
    required this.focusedDay,
    required this.isUserAdmin,
  });

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
                              if (widget.isUserAdmin)
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text('id: ${event.id}'),
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
                              if (event.link.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: RichText(
                                    text: TextSpan(
                                      text: 'Anmeldelink: ',
                                      style: const TextStyle(
                                        color: Colors.black,
                                      ),
                                      children: [
                                        TextSpan(
                                          text: 'Hier klicken',
                                          style: const TextStyle(
                                            color: Colors.blue,
                                            decoration:
                                                TextDecoration.underline,
                                          ),
                                          recognizer: TapGestureRecognizer()
                                            ..onTap = () async {
                                              final Uri url = Uri.parse(
                                                event.link,
                                              );
                                              if (!await launchUrl(
                                                url,
                                                mode: LaunchMode
                                                    .externalApplication,
                                              )) {
                                                debugPrint(
                                                  'Konnte $url nicht öffnen',
                                                );
                                              }
                                            },
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      ActionsRow(),
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
