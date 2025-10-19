import 'package:bbf_app/backend/services/trigger_background_functions_service.dart';
import 'package:bbf_app/utils/constants/colors.dart';
import 'package:bbf_app/utils/helper/notification_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class NotificationSettingsPage extends StatefulWidget {
  final String name;
  final DateTime? prayerTime;
  NotificationSettingsPage({
    super.key,
    required this.name,
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
  bool showSubmitButton = false;

  @override
  void initState() {
    super.initState();
    isNotificationActive = prayerTimesHelper.isNotificationEnabled(widget.name);
    _loadCurrentIndex();
  }

  void _loadCurrentIndex() {
    final value = prayerTimesHelper.getCurrentPreTimeAsIndex(widget.name);
    setState(() {
      currentIndex = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<LoadingProvider>().isLoading;
    final loadingProvider = context.read<LoadingProvider>();
    final showCheckmark = loadingProvider.showCheckmark;

    String currentPreTime = prePrayerTimes[currentIndex];
    int tempPreTimeIndex = prayerTimesHelper.getCurrentPreTimeAsIndex(
      widget.name,
    );
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
                    border: Border.all(
                      color: isNotificationActive
                          ? BColors.primary
                          : Colors.white,
                    ),
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
                    border: Border.all(
                      color: isNotificationActive
                          ? Colors.white
                          : BColors.primary,
                    ),
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
                    currentIndex -= 1;
                    setState(() {
                      showSubmitButton = true;
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
                width: 125,
                child: Center(child: Text(currentPreTime)),
              ),
              GestureDetector(
                onTap: () {
                  if (currentIndex != prePrayerTimes.length - 1) {
                    currentIndex += 1;
                    setState(() {
                      showSubmitButton = true;
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
          SizedBox(height: 10),
          if (showSubmitButton)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      showSubmitButton = false;
                      currentIndex = tempPreTimeIndex;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    side: BorderSide(color: Colors.white),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Text('Abbrechen'),
                  ),
                ),

                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      showSubmitButton = false;
                      int minutes = prayerTimesHelper
                          .convertPreTimeStringIntoInt(
                            prePrayerTimes[currentIndex],
                          );
                      prayerTimesHelper.updatePreNotification(
                        widget.name,
                        minutes,
                      );
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Text('Bestätigen'),
                  ),
                ),
              ],
            ),
          SizedBox(height: 20),
          GestureDetector(
            onTap: () async {
              int minutes = prayerTimesHelper.convertPreTimeStringIntoInt(
                prePrayerTimes[currentIndex],
              );

              loadingProvider.startLoading();
              try {
                if (isNotificationActive) {
                  await prayerTimesHelper.activateAllNotifications();
                } else {
                  await prayerTimesHelper.deactivateAllNotifications();
                }

                await prayerTimesHelper.updateAllPreNotifications(minutes);
                loadingProvider.stopLoadingWithCheckmark();
              } catch (e) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('Fehler: $e')));
              }
            },
            child: Center(
              child: isLoading
                  ? CircularProgressIndicator(
                      strokeWidth: 2,
                      color: BColors.primary,
                    )
                  : showCheckmark
                  ? Container(
                      decoration: BoxDecoration(
                        color: BColors.primary,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Icon(Icons.check, color: Colors.white),
                      ),
                    )
                  : Container(
                      decoration: BoxDecoration(
                        color: BColors.primary,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.all_inclusive,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Setze dies für jedes Gebet',
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
