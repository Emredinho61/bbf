import 'package:bbf_app/backend/services/trigger_background_functions_service.dart';
import 'package:bbf_app/utils/constants/colors.dart';
import 'package:flutter/material.dart';

class NotificationSettingsPage extends StatefulWidget {
  final String name;
  final int id;
  final DateTime? prayerTime;
  NotificationSettingsPage({
    super.key,
    required this.name,
    required this.id,
    required this.prayerTime,
  });

  @override
  State<NotificationSettingsPage> createState() =>
      _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage> {
  late bool isNotificationActive;
  List<String> prePrayerTimes = [
    'Keine',
    '5 Minuten',
    '10 Minuten',
    '15 Minuten',
    '20 Minuten',
    '30 Minuten',
    '45 Minuten',
  ];
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    isNotificationActive = prayerTimesHelper.isNotificationEnabled(widget.name);

    _loadCurrentIndex();
  }

  Future<void> _loadCurrentIndex() async {
    final value = await prayerTimesHelper.getCurrentPreTimeAsIndex(widget.name);
    setState(() {
      currentIndex = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          SizedBox(height: 12),
          widget.name == 'Sunrise'
              ? Text(
                  'Shuruq-Benachrichtigung',
                  style: Theme.of(context).textTheme.bodyLarge,
                )
              : Text(
                  'Gebetsbenachrichtigungen',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () {
                  prayerTimesHelper.deactivateNotification(widget.name);
                  setState(() {
                    isNotificationActive = prayerTimesHelper
                        .isNotificationEnabled(widget.name);
                  });
                },
                child: Container(
                  margin: EdgeInsets.all(16),
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isNotificationActive
                        ? Color.fromARGB(255, 185, 185, 185)
                        : BColors.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Container(
                        margin: EdgeInsets.all(16),
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.grey,
                          border: Border.all(
                            color: isNotificationActive
                                ? BColors.primary
                                : Colors.white,
                          ),
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: Icon(
                          Icons.notifications_off,
                          size: 30,
                          color: Colors.white,
                        ),
                      ),
                      Text('Stumm'),
                    ],
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  prayerTimesHelper.activateNotification(widget.name);
                  setState(() {
                    isNotificationActive = prayerTimesHelper
                        .isNotificationEnabled(widget.name);
                  });
                },
                child: Container(
                  margin: EdgeInsets.all(16),
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isNotificationActive
                        ? BColors.primary
                        : Color.fromARGB(255, 185, 185, 185),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Container(
                        margin: EdgeInsets.all(16),
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.grey,
                          border: Border.all(
                            color: isNotificationActive
                                ? Colors.white
                                : BColors.primary,
                          ),
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: Icon(
                          Icons.notifications_on,
                          size: 30,
                          color: Colors.white,
                        ),
                      ),
                      Text('Aktiv'),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          widget.name == 'Sunrise'
              ? Text(
                  'Vor-Shuruq-Benachrichtigung',
                  style: Theme.of(context).textTheme.bodyMedium,
                )
              : Text(
                  'Vor-Gebetsbenachrichtigungen',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
          SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () {
                  if (currentIndex != 0) {
                    int updatedIndex = currentIndex -= 1;
                    setState(() {
                      int minutes = prayerTimesHelper
                          .convertPreTimeStringIntoInt(
                            prePrayerTimes[updatedIndex],
                          );
                      prayerTimesHelper.updatePreNotification(
                        widget.name,
                        widget.prayerTime!,
                        minutes,
                      );
                    });
                  }
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Color.fromARGB(255, 185, 185, 185),
                    borderRadius: BorderRadius.circular(50),
                    border: Border.all(color: BColors.primary),
                  ),
                  child: Icon(Icons.remove, color: Colors.white),
                ),
              ),
              Container(
                padding: EdgeInsets.all(10),
                margin: EdgeInsets.all(5),
                child: Text(prePrayerTimes[currentIndex]),
              ),
              GestureDetector(
                onTap: () {
                  if (currentIndex != prePrayerTimes.length - 1) {
                    int updatedIndex = currentIndex += 1;
                    setState(() {
                      int minutes = prayerTimesHelper
                          .convertPreTimeStringIntoInt(
                            prePrayerTimes[updatedIndex],
                          );
                      prayerTimesHelper.updatePreNotification(
                        widget.name,
                        widget.prayerTime!,
                        minutes,
                      );
                    });
                  }
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Color.fromARGB(255, 185, 185, 185),
                    borderRadius: BorderRadius.circular(50),
                    border: Border.all(color: BColors.primary),
                  ),
                  child: Icon(Icons.add, color: Colors.white),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
