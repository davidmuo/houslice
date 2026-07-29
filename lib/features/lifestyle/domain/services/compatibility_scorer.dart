import '../entities/compatibility.dart';
import '../entities/lifestyle_profile.dart';

/// Scores how well two students would live together, from their answers to
/// the lifestyle questionnaire.
///
/// The model is deliberately simple and explainable: each dimension produces a
/// 0–100 agreement, those are combined with fixed weights, and every dimension
/// carries a sentence explaining itself. A student can always see *why* a
/// number is what it is — which is the point of the "Why compatible?" sheet.
abstract final class CompatibilityScorer {
  /// Weights sum to 1.0. Cleanliness and social style lead because interviews
  /// named them the most common causes of housemate conflict.
  static const _weights = <CompatibilityDimension, double>{
    CompatibilityDimension.cleanliness: 0.18,
    CompatibilityDimension.social: 0.16,
    CompatibilityDimension.sleep: 0.14,
    CompatibilityDimension.guests: 0.12,
    CompatibilityDimension.smoking: 0.12,
    CompatibilityDimension.budget: 0.10,
    CompatibilityDimension.study: 0.08,
    CompatibilityDimension.sharing: 0.06,
    CompatibilityDimension.pets: 0.04,
  };

  static CompatibilityBreakdown compare(
    LifestyleProfile viewer,
    LifestyleProfile host,
  ) {
    final factors = <CompatibilityFactor>[
      _cleanliness(viewer, host),
      _social(viewer, host),
      _sleep(viewer, host),
      _guests(viewer, host),
      _smoking(viewer, host),
      _budget(viewer, host),
      _study(viewer, host),
      _sharing(viewer, host),
      _pets(viewer, host),
    ];

    var total = 0.0;
    for (final factor in factors) {
      total += factor.score * _weights[factor.dimension]!;
    }

    final blockedReason = _genderBlock(viewer, host);
    factors.sort((a, b) => b.score.compareTo(a.score));

    return CompatibilityBreakdown(
      score: blockedReason == null ? total.round() : 0,
      factors: factors,
      blocked: blockedReason != null,
      blockedReason: blockedReason,
    );
  }

  /// Convenience for list views that only need the headline number.
  static int scoreOnly(LifestyleProfile viewer, LifestyleProfile host) =>
      compare(viewer, host).score;

  // -------------------------------------------------------------------------
  // Hard filter
  // -------------------------------------------------------------------------

  /// A same-gender-only requirement on either side rules the match out. When
  /// either student declined to state a gender we cannot verify the rule, so
  /// the match is allowed through rather than silently hidden.
  static String? _genderBlock(LifestyleProfile viewer, LifestyleProfile host) {
    const undisclosed = Gender.preferNotToSay;
    if (viewer.gender == undisclosed || host.gender == undisclosed) return null;
    if (viewer.gender == host.gender) return null;

    if (viewer.genderPreference == GenderPreference.sameGenderOnly) {
      return 'You asked to live with people of the same gender.';
    }
    if (host.genderPreference == GenderPreference.sameGenderOnly) {
      return 'This student is only looking for housemates of the same gender.';
    }
    return null;
  }

  // -------------------------------------------------------------------------
  // Dimensions
  // -------------------------------------------------------------------------

  /// Agreement from the distance between two positions on an ordered scale.
  static int _ordinal(int a, int b, int length) {
    final distance = (a - b).abs();
    return (100 * (1 - distance / (length - 1))).round();
  }

  static CompatibilityFactor _cleanliness(
    LifestyleProfile viewer,
    LifestyleProfile host,
  ) {
    final score = _ordinal(
      viewer.cleanliness.index,
      host.cleanliness.index,
      Cleanliness.values.length,
    );
    final note = switch (score) {
      >= 90 => 'You both keep shared space ${_lower(host.cleanliness.label)}.',
      >= 60 =>
        'Similar standards — you say '
            '"${_lower(viewer.cleanliness.label)}", they say '
            '"${_lower(host.cleanliness.label)}".',
      _ =>
        'You keep things ${_lower(viewer.cleanliness.label)}; they are '
            '${_lower(host.cleanliness.label)}. Worth agreeing a cleaning rota.',
    };
    return CompatibilityFactor(
      dimension: CompatibilityDimension.cleanliness,
      score: score,
      note: note,
    );
  }

  static CompatibilityFactor _social(
    LifestyleProfile viewer,
    LifestyleProfile host,
  ) {
    final score = _ordinal(
      viewer.social.index,
      host.social.index,
      SocialStyle.values.length,
    );
    final note = switch (score) {
      >= 90 =>
        'You have a similar social rhythm — ${_lower(host.social.label)}.',
      >= 60 =>
        'Fairly close: you are ${_lower(viewer.social.label)}, they are '
            '${_lower(host.social.label)}.',
      _ =>
        'Different energies — you are ${_lower(viewer.social.label)} while '
            'they are ${_lower(host.social.label)}.',
    };
    return CompatibilityFactor(
      dimension: CompatibilityDimension.social,
      score: score,
      note: note,
    );
  }

  static CompatibilityFactor _sleep(
    LifestyleProfile viewer,
    LifestyleProfile host,
  ) {
    final score = _ordinal(
      viewer.bedtime.index,
      host.bedtime.index,
      Bedtime.values.length,
    );
    final note = switch (score) {
      >= 90 => 'You both turn in ${_lower(host.bedtime.label)}.',
      >= 60 =>
        'Close enough — you sleep ${_lower(viewer.bedtime.label)}, they '
            'sleep ${_lower(host.bedtime.label)}.',
      _ =>
        'You sleep ${_lower(viewer.bedtime.label)} and they are up '
            '${_lower(host.bedtime.label)}. Expect some overlap friction.',
    };
    return CompatibilityFactor(
      dimension: CompatibilityDimension.sleep,
      score: score,
      note: note,
    );
  }

  static CompatibilityFactor _guests(
    LifestyleProfile viewer,
    LifestyleProfile host,
  ) {
    final score = _ordinal(
      viewer.guests.index,
      host.guests.index,
      GuestFrequency.values.length,
    );
    final note = score >= 60
        ? 'You have similar expectations about overnight guests.'
        : 'You host guests ${_lower(viewer.guests.label)}; they do '
              '${_lower(host.guests.label)}.';
    return CompatibilityFactor(
      dimension: CompatibilityDimension.guests,
      score: score,
      note: note,
    );
  }

  /// Not a plain ordinal: a non-smoker who explicitly wants a smoke-free home
  /// paired with a smoker is a zero, however close the enum indices are.
  static CompatibilityFactor _smoking(
    LifestyleProfile viewer,
    LifestyleProfile host,
  ) {
    final clash =
        (viewer.smoking == SmokingStance.nonSmokerPrefersNone &&
            host.smoking.smokes) ||
        (host.smoking == SmokingStance.nonSmokerPrefersNone &&
            viewer.smoking.smokes);

    if (clash) {
      return const CompatibilityFactor(
        dimension: CompatibilityDimension.smoking,
        score: 0,
        note: 'One of you wants a smoke-free home and the other smokes.',
      );
    }

    final score = _ordinal(
      viewer.smoking.index,
      host.smoking.index,
      SmokingStance.values.length,
    );
    return CompatibilityFactor(
      dimension: CompatibilityDimension.smoking,
      score: score,
      note: !viewer.smoking.smokes && !host.smoking.smokes
          ? 'Neither of you smokes.'
          : 'Your smoking preferences line up.',
    );
  }

  static CompatibilityFactor _budget(
    LifestyleProfile viewer,
    LifestyleProfile host,
  ) {
    final score = _ordinal(
      viewer.budget.index,
      host.budget.index,
      BudgetBand.values.length,
    );
    final note = score >= 90
        ? 'You are both looking around ${host.budget.label}.'
        : score >= 60
        ? 'Budgets are close — ${viewer.budget.label} vs ${host.budget.label}.'
        : 'Your budget is ${viewer.budget.label} and theirs is '
              '${host.budget.label}.';
    return CompatibilityFactor(
      dimension: CompatibilityDimension.budget,
      score: score,
      note: note,
    );
  }

  static CompatibilityFactor _study(
    LifestyleProfile viewer,
    LifestyleProfile host,
  ) {
    final score = _ordinal(
      viewer.study.index,
      host.study.index,
      StudyStyle.values.length,
    );
    return CompatibilityFactor(
      dimension: CompatibilityDimension.study,
      score: score,
      note: score >= 60
          ? 'You study in similar conditions.'
          : 'You study ${_lower(viewer.study.label)}; they study '
                '${_lower(host.study.label)}.',
    );
  }

  static CompatibilityFactor _sharing(
    LifestyleProfile viewer,
    LifestyleProfile host,
  ) {
    final score = _ordinal(
      viewer.sharing.index,
      host.sharing.index,
      SharingStyle.values.length,
    );
    return CompatibilityFactor(
      dimension: CompatibilityDimension.sharing,
      score: score,
      note: score >= 60
          ? 'You agree on sharing food and household items.'
          : 'You prefer to ${_lower(viewer.sharing.label)}; they prefer to '
                '${_lower(host.sharing.label)}.',
    );
  }

  /// Allergy beats preference: an allergic student cannot live with pets
  /// regardless of how much the other person loves them.
  static CompatibilityFactor _pets(
    LifestyleProfile viewer,
    LifestyleProfile host,
  ) {
    final allergyClash =
        (viewer.pets == PetStance.allergic &&
            host.pets == PetStance.loveThem) ||
        (host.pets == PetStance.allergic && viewer.pets == PetStance.loveThem);

    if (allergyClash) {
      return const CompatibilityFactor(
        dimension: CompatibilityDimension.pets,
        score: 0,
        note: 'One of you is allergic and the other keeps pets.',
      );
    }

    final score = _ordinal(
      viewer.pets.index,
      host.pets.index,
      PetStance.values.length,
    );
    return CompatibilityFactor(
      dimension: CompatibilityDimension.pets,
      score: score,
      note: score >= 60
          ? 'You feel the same way about pets.'
          : 'Different views on pets — you: ${_lower(viewer.pets.label)}, '
                'them: ${_lower(host.pets.label)}.',
    );
  }

  static String _lower(String label) =>
      label.isEmpty ? label : label[0].toLowerCase() + label.substring(1);
}
