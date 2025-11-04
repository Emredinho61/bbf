import 'dart:convert';

import 'package:bbf_app/backend/services/shared_preferences_service.dart';

class ProjectsPageHelper {
  final prefs = SharedPreferencesService.instance.prefsWithCache;

  List<Map<String, dynamic>> getPastProjects() {
    final jsonString = prefs.getString('pastProjects');

    if (jsonString == null) return [];

    final List<dynamic> decoded = jsonDecode(jsonString);

    return decoded.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  List<Map<String, dynamic>> getFutureProjects() {
    final jsonString = prefs.getString('futureProjects');

    if (jsonString == null) return [];

    final List<dynamic> decoded = jsonDecode(jsonString);

    return decoded.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  Future<void> setPastProjects(List<Map<String, dynamic>> products) async {
    final jsonString = jsonEncode(products);
    await prefs.setString('pastProjects', jsonString);
  }

  Future<void> setFutureProjects(List<Map<String, dynamic>> products) async {
    final jsonString = jsonEncode(products);
    await prefs.setString('futureProjects', jsonString);
  }

  String? getCertainProject(String id) {
    return prefs.getString('project_$id');
  }

  Future<void> setCertainProject(String id, String jsonData) async {
    await prefs.setString(id, jsonData);
  }
}
