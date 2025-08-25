import 'package:bbf_app/backend/services/auth_services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PrayertimesService 
{
  final AuthService authService = AuthService();
  final CollectionReference prayerTimes = FirebaseFirestore.instance.collection('prayertimes');

  Future<void> updateFridayPrayerTimes(String fridayprayer1, String fridayprayer2) async{
    final docReference = prayerTimes.doc('lT2DJFLHlCfSkqFYAf5e');

    await docReference.update(
      {
        'fridayprayer1' : fridayprayer1,
        'fridayprayer2' : fridayprayer2
      }
    );
  }

  Future<void> updateIqamaTimes(String fajrIqama, String dhurIqama, String asrIqama, String maghribIqama, ishaIqama) async{
    final docReference = prayerTimes.doc('lT2DJFLHlCfSkqFYAf5e');

    await docReference.update(
      {
        'fajrIqama' : fajrIqama,
        'dhurIqama' : dhurIqama,
        'asrIqama' : asrIqama,
        'maghribIqama' : maghribIqama,
        'ishaIqama' : ishaIqama,
      }
    );
  }

  Future<String> getFridayPrayer1() async {
  final docSnapshot = await prayerTimes.doc('lT2DJFLHlCfSkqFYAf5e').get();
  if(docSnapshot.exists)
  {
    return docSnapshot['fridayprayer1'] as String;
  }
  return '';
}

Future<String> getFridayPrayer2() async {
  final docSnapshot = await prayerTimes.doc('lT2DJFLHlCfSkqFYAf5e').get();
  if(docSnapshot.exists)
  {
    return docSnapshot['fridayprayer2'] as String;
  }
  return '';
}

Future<String> getFajrIqama() async {
  final docSnapshot = await prayerTimes.doc('lT2DJFLHlCfSkqFYAf5e').get();
  if(docSnapshot.exists)
  {
    return docSnapshot['fajrIqama'] as String;
  }
  return '';
}
Future<String> getDhurIqama() async {
  final docSnapshot = await prayerTimes.doc('lT2DJFLHlCfSkqFYAf5e').get();
  if(docSnapshot.exists)
  {
    return docSnapshot['dhurIqama'] as String;
  }
  return '';
}
Future<String> getAsrIqama() async {
  final docSnapshot = await prayerTimes.doc('lT2DJFLHlCfSkqFYAf5e').get();
  if(docSnapshot.exists)
  {
    return docSnapshot['asrIqama'] as String;
  }
  return '';
}
Future<String> getMaghribIqama() async {
  final docSnapshot = await prayerTimes.doc('lT2DJFLHlCfSkqFYAf5e').get();
  if(docSnapshot.exists)
  {
    return docSnapshot['maghribIqama'] as String;
  }
  return '';
}
Future<String> getIshaIqama() async {
  final docSnapshot = await prayerTimes.doc('lT2DJFLHlCfSkqFYAf5e').get();
  if(docSnapshot.exists)
  {
    return docSnapshot['ishaIqama'] as String;
  }
  return '';
}

  
}