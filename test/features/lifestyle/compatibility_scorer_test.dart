import 'package:flutter_test/flutter_test.dart';
import 'package:houslice/features/lifestyle/domain/entities/compatibility.dart';
import 'package:houslice/features/lifestyle/domain/entities/lifestyle_profile.dart';
import 'package:houslice/features/lifestyle/domain/services/compatibility_scorer.dart';

/// Unit tests for the housemate compatibility model.
void main() {
  group('identical profiles', () {
    test('score 100 and every dimension agrees fully', () {
      const profile = LifestyleProfile(
        bedtime: Bedtime.tenToMidnight,
        cleanliness: Cleanliness.tidy,
        social: SocialStyle.occasional,
        study: StudyStyle.musicInRoom,
        guests: GuestFrequency.rarely,
        smoking: SmokingStance.nonSmokerTolerant,
        budget: BudgetBand.from100To150,
        gender: Gender.woman,
        genderPreference: GenderPreference.noPreference,
        sharing: SharingStyle.shareBasics,
        pets: PetStance.fineWithThem,
      );

      final result = CompatibilityScorer.compare(profile, profile);

      expect(result.score, 100);
      expect(result.blocked, isFalse);
      expect(result.factors.every((f) => f.score == 100), isTrue);
      expect(result.headline, 'Excellent match');
    });

    test('covers every dimension exactly once', () {
      final result = CompatibilityScorer.compare(
        LifestyleProfile.empty,
        LifestyleProfile.empty,
      );

      expect(
        result.factors.map((f) => f.dimension).toSet(),
        CompatibilityDimension.values.toSet(),
      );
      expect(result.factors.length, CompatibilityDimension.values.length);
    });
  });

  group('opposite profiles', () {
    test('score poorly and surface friction', () {
      const earlyBirdNeatFreak = LifestyleProfile(
        bedtime: Bedtime.beforeTen,
        cleanliness: Cleanliness.spotless,
        social: SocialStyle.homebody,
        study: StudyStyle.silentRoom,
        guests: GuestFrequency.never,
        smoking: SmokingStance.nonSmokerPrefersNone,
        budget: BudgetBand.under100,
        gender: Gender.man,
        genderPreference: GenderPreference.noPreference,
        sharing: SharingStyle.keepSeparate,
        pets: PetStance.allergic,
      );
      const nightOwlPartier = LifestyleProfile(
        bedtime: Bedtime.afterTwo,
        cleanliness: Cleanliness.relaxed,
        social: SocialStyle.verySocial,
        study: StudyStyle.anywhere,
        guests: GuestFrequency.often,
        smoking: SmokingStance.smoker,
        budget: BudgetBand.over250,
        gender: Gender.man,
        genderPreference: GenderPreference.noPreference,
        sharing: SharingStyle.shareEverything,
        pets: PetStance.loveThem,
      );

      final result = CompatibilityScorer.compare(
        earlyBirdNeatFreak,
        nightOwlPartier,
      );

      expect(result.score, lessThan(20));
      expect(result.frictions, isNotEmpty);
      expect(result.strengths, isEmpty);
    });
  });

  group('factor ordering', () {
    test('strongest agreement is listed first', () {
      const a = LifestyleProfile(
        cleanliness: Cleanliness.spotless,
        social: SocialStyle.homebody,
      );
      const b = LifestyleProfile(
        cleanliness: Cleanliness.spotless,
        social: SocialStyle.verySocial,
      );

      final result = CompatibilityScorer.compare(a, b);
      final scores = result.factors.map((f) => f.score).toList();

      expect(
        scores,
        orderedEquals([...scores]..sort((x, y) => y.compareTo(x))),
      );
    });
  });

  group('smoking', () {
    test(
      'a smoker and a smoke-free household score zero on that dimension',
      () {
        const wantsSmokeFree = LifestyleProfile(
          smoking: SmokingStance.nonSmokerPrefersNone,
        );
        const smokes = LifestyleProfile(smoking: SmokingStance.smoker);

        final factor = CompatibilityScorer.compare(wantsSmokeFree, smokes)
            .factors
            .firstWhere((f) => f.dimension == CompatibilityDimension.smoking);

        expect(factor.score, 0);
        expect(factor.note, contains('smoke-free'));
      },
    );

    test('the clash is symmetric', () {
      const wantsSmokeFree = LifestyleProfile(
        smoking: SmokingStance.nonSmokerPrefersNone,
      );
      const smokes = LifestyleProfile(smoking: SmokingStance.occasional);

      int smokingScore(LifestyleProfile a, LifestyleProfile b) =>
          CompatibilityScorer.compare(a, b).factors
              .firstWhere((f) => f.dimension == CompatibilityDimension.smoking)
              .score;

      expect(smokingScore(wantsSmokeFree, smokes), 0);
      expect(smokingScore(smokes, wantsSmokeFree), 0);
    });

    test('two tolerant non-smokers agree completely', () {
      const tolerant = LifestyleProfile(
        smoking: SmokingStance.nonSmokerTolerant,
      );

      final factor = CompatibilityScorer.compare(tolerant, tolerant).factors
          .firstWhere((f) => f.dimension == CompatibilityDimension.smoking);

      expect(factor.score, 100);
      expect(factor.note, 'Neither of you smokes.');
    });
  });

  group('pets', () {
    test('an allergy against a pet lover scores zero', () {
      const allergic = LifestyleProfile(pets: PetStance.allergic);
      const lovesPets = LifestyleProfile(pets: PetStance.loveThem);

      final factor = CompatibilityScorer.compare(
        allergic,
        lovesPets,
      ).factors.firstWhere((f) => f.dimension == CompatibilityDimension.pets);

      expect(factor.score, 0);
      expect(factor.note, contains('allergic'));
    });
  });

  group('gender preference', () {
    test('same-gender-only blocks a different-gender match', () {
      const womanOnly = LifestyleProfile(
        gender: Gender.woman,
        genderPreference: GenderPreference.sameGenderOnly,
      );
      const man = LifestyleProfile(gender: Gender.man);

      final result = CompatibilityScorer.compare(womanOnly, man);

      expect(result.blocked, isTrue);
      expect(result.score, 0);
      expect(result.headline, 'Not a match');
      expect(result.blockedReason, contains('same gender'));
    });

    test('the block applies when the host is the one asking', () {
      const woman = LifestyleProfile(gender: Gender.woman);
      const manOnly = LifestyleProfile(
        gender: Gender.man,
        genderPreference: GenderPreference.sameGenderOnly,
      );

      final result = CompatibilityScorer.compare(woman, manOnly);

      expect(result.blocked, isTrue);
      expect(result.blockedReason, contains('This student'));
    });

    test('same gender with the same requirement is not blocked', () {
      const womanOnly = LifestyleProfile(
        gender: Gender.woman,
        genderPreference: GenderPreference.sameGenderOnly,
      );

      expect(
        CompatibilityScorer.compare(womanOnly, womanOnly).blocked,
        isFalse,
      );
    });

    test(
      'an undisclosed gender cannot be checked, so it is allowed through',
      () {
        const womanOnly = LifestyleProfile(
          gender: Gender.woman,
          genderPreference: GenderPreference.sameGenderOnly,
        );
        const undisclosed = LifestyleProfile(gender: Gender.preferNotToSay);

        final result = CompatibilityScorer.compare(womanOnly, undisclosed);

        expect(result.blocked, isFalse);
        expect(result.score, greaterThan(0));
      },
    );
  });

  group('headline bands', () {
    test('describe the score in plain language', () {
      String headlineFor(LifestyleProfile a, LifestyleProfile b) =>
          CompatibilityScorer.compare(a, b).headline;

      expect(
        headlineFor(LifestyleProfile.empty, LifestyleProfile.empty),
        'Excellent match',
      );
      expect(
        headlineFor(
          const LifestyleProfile(cleanliness: Cleanliness.spotless),
          const LifestyleProfile(cleanliness: Cleanliness.relaxed),
        ),
        anyOf('Strong match', 'Decent match'),
      );
    });
  });

  group('scoreOnly', () {
    test('matches the full comparison', () {
      const a = LifestyleProfile(social: SocialStyle.homebody);
      const b = LifestyleProfile(social: SocialStyle.mostWeekends);

      expect(
        CompatibilityScorer.scoreOnly(a, b),
        CompatibilityScorer.compare(a, b).score,
      );
    });
  });

  group('BudgetBand', () {
    test('forPrice maps rent onto the right band', () {
      expect(BudgetBandX.forPrice(80), BudgetBand.under100);
      expect(BudgetBandX.forPrice(120), BudgetBand.from100To150);
      expect(BudgetBandX.forPrice(200), BudgetBand.from150To250);
      expect(BudgetBandX.forPrice(400), BudgetBand.over250);
    });

    test('band boundaries are half-open', () {
      expect(BudgetBand.from100To150.covers(100), isTrue);
      expect(BudgetBand.from100To150.covers(150), isFalse);
      expect(BudgetBand.from150To250.covers(150), isTrue);
    });
  });
}
