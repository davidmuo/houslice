import 'dart:convert';

import '../../domain/entities/lifestyle_profile.dart';

/// Serialises [LifestyleProfile] to and from JSON, for both SharedPreferences
/// and the `users/{uid}.lifestyle` Firestore field.
///
/// Answers are stored by enum *name*, never index, so reordering a scale in
/// the domain cannot silently reinterpret data already written to a device.
/// Anything unrecognised falls back to the questionnaire's neutral default.
abstract final class LifestyleProfileModel {
  static Map<String, dynamic> toMap(LifestyleProfile profile) => {
    'bedtime': profile.bedtime.name,
    'cleanliness': profile.cleanliness.name,
    'social': profile.social.name,
    'study': profile.study.name,
    'guests': profile.guests.name,
    'smoking': profile.smoking.name,
    'budget': profile.budget.name,
    'gender': profile.gender.name,
    'genderPreference': profile.genderPreference.name,
    'sharing': profile.sharing.name,
    'pets': profile.pets.name,
    'bio': profile.bio,
  };

  static LifestyleProfile fromMap(Map<String, dynamic> map) {
    const fallback = LifestyleProfile.empty;
    return LifestyleProfile(
      bedtime: _decode(Bedtime.values, map['bedtime'], fallback.bedtime),
      cleanliness: _decode(
        Cleanliness.values,
        map['cleanliness'],
        fallback.cleanliness,
      ),
      social: _decode(SocialStyle.values, map['social'], fallback.social),
      study: _decode(StudyStyle.values, map['study'], fallback.study),
      guests: _decode(GuestFrequency.values, map['guests'], fallback.guests),
      smoking: _decode(SmokingStance.values, map['smoking'], fallback.smoking),
      budget: _decode(BudgetBand.values, map['budget'], fallback.budget),
      gender: _decode(Gender.values, map['gender'], fallback.gender),
      genderPreference: _decode(
        GenderPreference.values,
        map['genderPreference'],
        fallback.genderPreference,
      ),
      sharing: _decode(SharingStyle.values, map['sharing'], fallback.sharing),
      pets: _decode(PetStance.values, map['pets'], fallback.pets),
      bio: (map['bio'] ?? '') as String,
    );
  }

  static String encode(LifestyleProfile profile) => jsonEncode(toMap(profile));

  /// Returns null when [raw] is absent or unparseable, so callers can tell
  /// "never took the quiz" apart from "took it and chose the defaults".
  static LifestyleProfile? decode(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return null;
      return fromMap(Map<String, dynamic>.from(decoded));
    } on FormatException {
      return null;
    }
  }

  static T _decode<T extends Enum>(List<T> values, dynamic name, T fallback) =>
      values.firstWhere((value) => value.name == name, orElse: () => fallback);
}
