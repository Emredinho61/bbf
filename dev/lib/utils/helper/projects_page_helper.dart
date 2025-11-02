import 'dart:convert';

import 'package:bbf_app/backend/services/shared_preferences_service.dart';

class ProjectsPageHelper {
  final prefs = SharedPreferencesService.instance.prefsWithCache;

  List<Map<String, dynamic>> getAllProjects() {
    final jsonString = prefs.getString('allProjects');

    if (jsonString == null) return [];

    final List<dynamic> decoded = jsonDecode(jsonString);

    return decoded.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  Future<void> setallProjects(List<Map<String, dynamic>> products) async {
    final jsonString = jsonEncode(products);
    await prefs.setString('allProjects', jsonString);
  }

  String? getCertainProject(String id) {
    return prefs.getString('project_$id');
  }

  Future<void> setCertainProject(String id, String jsonData) async {
    await prefs.setString(id, jsonData);
  }
}
