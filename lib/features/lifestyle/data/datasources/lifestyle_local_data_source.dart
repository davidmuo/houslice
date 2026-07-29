import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/error/exceptions.dart';
import '../../domain/entities/lifestyle_profile.dart';
import '../models/lifestyle_profile_model.dart';

/// Contract for on-device storage of the questionnaire answers.
abstract class LifestyleLocalDataSource {
  Future<LifestyleProfile?> load();

  Future<LifestyleProfile> save(LifestyleProfile profile);

  Future<void> clear();
}

class SharedPrefsLifestyleDataSource implements LifestyleLocalDataSource {
  final SharedPreferences prefs;

  SharedPrefsLifestyleDataSource(this.prefs);

  static const key = 'houslice.lifestyle_profile';

  @override
  Future<LifestyleProfile?> load() async {
    try {
      return LifestyleProfileModel.decode(prefs.getString(key));
    } catch (_) {
      throw const CacheException('Could not read your lifestyle answers.');
    }
  }

  @override
  Future<LifestyleProfile> save(LifestyleProfile profile) async {
    try {
      await prefs.setString(key, LifestyleProfileModel.encode(profile));
      return profile;
    } catch (_) {
      throw const CacheException('Could not save your lifestyle answers.');
    }
  }

  @override
  Future<void> clear() async {
    try {
      await prefs.remove(key);
    } catch (_) {
      throw const CacheException('Could not reset your lifestyle answers.');
    }
  }
}
