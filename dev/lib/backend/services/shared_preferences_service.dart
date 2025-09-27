import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesService {
  SharedPreferencesService._privateConstructor();

  static final SharedPreferencesService instance =
      SharedPreferencesService._privateConstructor();
  late final SharedPreferencesWithCache prefsWithCache;

  // function to initialize shared Preferences
  Future<void> initPrefs() async {
    prefsWithCache = await SharedPreferencesWithCache.create(
      cacheOptions: const SharedPreferencesWithCacheOptions(),
    );
  }
}
