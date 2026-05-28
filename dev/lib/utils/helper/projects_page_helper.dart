import 'dart:convert';

import 'package:bbf_app/backend/services/shared_preferences_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProjectsPageHelper {
  SharedPreferencesWithCache get prefs =>
    SharedPreferencesService.instance.prefsWithCache;

  List<Map<String, dynamic>> getPastProjectsFromCache() {
    final jsonString = prefs.getString('pastProjects');

    if (jsonString == null) return [];

    final List<dynamic> decoded = jsonDecode(jsonString);

    return decoded.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  List<Map<String, dynamic>> getFutureProjectsFromCache() {
    final jsonString = prefs.getString('futureProjects');

    if (jsonString == null) return [];

    final List<dynamic> decoded = jsonDecode(jsonString);

    return decoded.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  Future<void> setPastProjectsInCache(List<Map<String, dynamic>> products) async {
    final jsonString = jsonEncode(products);
    await prefs.setString('pastProjects', jsonString);
  }

  Future<void> setFutureProjectsInCache(List<Map<String, dynamic>> products) async {
    final jsonString = jsonEncode(products);
    await prefs.setString('futureProjects', jsonString);
  }

  String? getCertainProjectFromCache(String id) {
    return prefs.getString('project_$id');
  }

  Future<void> setCertainProjectInCache(String id, String jsonData) async {
    await prefs.setString(id, jsonData);
  }
}
