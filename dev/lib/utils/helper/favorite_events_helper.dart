import 'package:bbf_app/backend/services/shared_preferences_service.dart';

class FavoriteEventsHelper {
  final _prefs = SharedPreferencesService.instance.prefsWithCache;
  static const _key = 'favorite_event_ids';

  Set<String> getFavorites() {
    final stored = _prefs.getStringList(_key);
    return stored?.toSet() ?? {};
  }

  bool isFavorite(String eventId) => getFavorites().contains(eventId);

  Future<void> toggleFavorite(String eventId) async {
    final favorites = getFavorites();
    if (favorites.contains(eventId)) {
      favorites.remove(eventId);
    } else {
      favorites.add(eventId);
    }
    await _prefs.setStringList(_key, favorites.toList());
  }
}
