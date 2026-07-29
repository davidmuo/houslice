import 'package:equatable/equatable.dart';

/// The lifestyle questionnaire a student answers at sign-up.
///
/// Every enum is declared in a meaningful order (most reserved → most
/// outgoing, tidiest → most relaxed, and so on) because the compatibility
/// scorer measures the *distance* between two students' answers. Reordering a
/// value silently changes matching, so the order is part of the contract.

// ---------------------------------------------------------------------------
// Answer scales
// ---------------------------------------------------------------------------

enum Bedtime { beforeTen, tenToMidnight, midnightToTwo, afterTwo }

enum Cleanliness { spotless, tidy, cleanWhenNeeded, relaxed }

/// How often the student hosts or goes out — the "are you a party person"
/// dimension students raised most often in interviews.
enum SocialStyle { homebody, occasional, mostWeekends, verySocial }

enum StudyStyle { silentRoom, musicInRoom, campusOrLibrary, anywhere }

enum GuestFrequency { never, rarely, sometimes, often }

enum SmokingStance {
  nonSmokerPrefersNone,
  nonSmokerTolerant,
  occasional,
  smoker,
}

/// Monthly budget in USD, matching the price bands in the Kigali catalogue.
enum BudgetBand { under100, from100To150, from150To250, over250 }

enum Gender { woman, man, nonBinary, preferNotToSay }

enum GenderPreference { sameGenderOnly, noPreference }

enum SharingStyle { shareEverything, shareBasics, keepSeparate }

enum PetStance { loveThem, fineWithThem, preferNone, allergic }

// ---------------------------------------------------------------------------
// Labels
// ---------------------------------------------------------------------------

extension BedtimeX on Bedtime {
  String get label => switch (this) {
    Bedtime.beforeTen => 'Before 10pm',
    Bedtime.tenToMidnight => '10pm – midnight',
    Bedtime.midnightToTwo => 'Midnight – 2am',
    Bedtime.afterTwo => 'After 2am',
  };
}

extension CleanlinessX on Cleanliness {
  String get label => switch (this) {
    Cleanliness.spotless => 'Spotless, always',
    Cleanliness.tidy => 'Tidy most days',
    Cleanliness.cleanWhenNeeded => 'I clean when it needs it',
    Cleanliness.relaxed => 'Relaxed about mess',
  };
}

extension SocialStyleX on SocialStyle {
  String get label => switch (this) {
    SocialStyle.homebody => 'Homebody, quiet evenings',
    SocialStyle.occasional => 'Out occasionally',
    SocialStyle.mostWeekends => 'Out most weekends',
    SocialStyle.verySocial => 'Very social, people over often',
  };
}

extension StudyStyleX on StudyStyle {
  String get label => switch (this) {
    StudyStyle.silentRoom => 'In my room, in silence',
    StudyStyle.musicInRoom => 'In my room, with music',
    StudyStyle.campusOrLibrary => 'On campus or at the library',
    StudyStyle.anywhere => 'Anywhere, noise is fine',
  };
}

extension GuestFrequencyX on GuestFrequency {
  String get label => switch (this) {
    GuestFrequency.never => 'Never',
    GuestFrequency.rarely => 'Rarely',
    GuestFrequency.sometimes => 'Sometimes',
    GuestFrequency.often => 'Often',
  };
}

extension SmokingStanceX on SmokingStance {
  String get label => switch (this) {
    SmokingStance.nonSmokerPrefersNone => "I don't, and prefer non-smokers",
    SmokingStance.nonSmokerTolerant => "I don't, but I don't mind",
    SmokingStance.occasional => 'Occasionally',
    SmokingStance.smoker => 'Yes, I smoke',
  };

  bool get smokes =>
      this == SmokingStance.occasional || this == SmokingStance.smoker;
}

extension BudgetBandX on BudgetBand {
  String get label => switch (this) {
    BudgetBand.under100 => 'Under \$100',
    BudgetBand.from100To150 => '\$100 – \$150',
    BudgetBand.from150To250 => '\$150 – \$250',
    BudgetBand.over250 => 'Over \$250',
  };

  /// Inclusive lower bound in USD per month.
  int get min => switch (this) {
    BudgetBand.under100 => 0,
    BudgetBand.from100To150 => 100,
    BudgetBand.from150To250 => 150,
    BudgetBand.over250 => 250,
  };

  /// Exclusive upper bound; [over250] is open-ended.
  int get max => switch (this) {
    BudgetBand.under100 => 100,
    BudgetBand.from100To150 => 150,
    BudgetBand.from150To250 => 250,
    BudgetBand.over250 => 1 << 30,
  };

  bool covers(num monthlyPrice) => monthlyPrice >= min && monthlyPrice < max;

  /// The band a given rent falls into.
  static BudgetBand forPrice(num monthlyPrice) => BudgetBand.values.firstWhere(
    (band) => band.covers(monthlyPrice),
    orElse: () => BudgetBand.over250,
  );
}

extension GenderX on Gender {
  String get label => switch (this) {
    Gender.woman => 'Woman',
    Gender.man => 'Man',
    Gender.nonBinary => 'Non-binary',
    Gender.preferNotToSay => 'Prefer not to say',
  };
}

extension GenderPreferenceX on GenderPreference {
  String get label => switch (this) {
    GenderPreference.sameGenderOnly => 'Same gender only',
    GenderPreference.noPreference => 'No preference',
  };
}

extension SharingStyleX on SharingStyle {
  String get label => switch (this) {
    SharingStyle.shareEverything => 'Share everything',
    SharingStyle.shareBasics => 'Share the basics',
    SharingStyle.keepSeparate => 'Keep things separate',
  };
}

extension PetStanceX on PetStance {
  String get label => switch (this) {
    PetStance.loveThem => 'Love them',
    PetStance.fineWithThem => 'Fine with them',
    PetStance.preferNone => 'Prefer none',
    PetStance.allergic => 'Allergic',
  };
}

// ---------------------------------------------------------------------------
// Profile
// ---------------------------------------------------------------------------

/// A student's answers to the lifestyle questionnaire. Used both as the
/// viewer's own profile and as the profile attached to a housemate listing.
class LifestyleProfile extends Equatable {
  final Bedtime bedtime;
  final Cleanliness cleanliness;
  final SocialStyle social;
  final StudyStyle study;
  final GuestFrequency guests;
  final SmokingStance smoking;
  final BudgetBand budget;
  final Gender gender;
  final GenderPreference genderPreference;
  final SharingStyle sharing;
  final PetStance pets;

  /// Free-text answer from the final "Tell us about yourself" step.
  final String bio;

  const LifestyleProfile({
    this.bedtime = Bedtime.tenToMidnight,
    this.cleanliness = Cleanliness.tidy,
    this.social = SocialStyle.occasional,
    this.study = StudyStyle.musicInRoom,
    this.guests = GuestFrequency.rarely,
    this.smoking = SmokingStance.nonSmokerPrefersNone,
    this.budget = BudgetBand.from100To150,
    this.gender = Gender.preferNotToSay,
    this.genderPreference = GenderPreference.noPreference,
    this.sharing = SharingStyle.shareBasics,
    this.pets = PetStance.fineWithThem,
    this.bio = '',
  });

  /// Neutral middle-of-the-road answers, used before the quiz is taken.
  static const empty = LifestyleProfile();

  LifestyleProfile copyWith({
    Bedtime? bedtime,
    Cleanliness? cleanliness,
    SocialStyle? social,
    StudyStyle? study,
    GuestFrequency? guests,
    SmokingStance? smoking,
    BudgetBand? budget,
    Gender? gender,
    GenderPreference? genderPreference,
    SharingStyle? sharing,
    PetStance? pets,
    String? bio,
  }) {
    return LifestyleProfile(
      bedtime: bedtime ?? this.bedtime,
      cleanliness: cleanliness ?? this.cleanliness,
      social: social ?? this.social,
      study: study ?? this.study,
      guests: guests ?? this.guests,
      smoking: smoking ?? this.smoking,
      budget: budget ?? this.budget,
      gender: gender ?? this.gender,
      genderPreference: genderPreference ?? this.genderPreference,
      sharing: sharing ?? this.sharing,
      pets: pets ?? this.pets,
      bio: bio ?? this.bio,
    );
  }

  @override
  List<Object?> get props => [
    bedtime,
    cleanliness,
    social,
    study,
    guests,
    smoking,
    budget,
    gender,
    genderPreference,
    sharing,
    pets,
    bio,
  ];
}
