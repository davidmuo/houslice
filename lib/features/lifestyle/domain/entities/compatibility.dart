import 'package:equatable/equatable.dart';

/// The lifestyle dimensions the compatibility score is built from. The
/// presentation layer maps these to icons; the domain stays Flutter-free.
enum CompatibilityDimension {
  cleanliness,
  social,
  sleep,
  guests,
  smoking,
  budget,
  study,
  sharing,
  pets,
}

extension CompatibilityDimensionX on CompatibilityDimension {
  String get label => switch (this) {
    CompatibilityDimension.cleanliness => 'Cleanliness',
    CompatibilityDimension.social => 'Social life',
    CompatibilityDimension.sleep => 'Sleep schedule',
    CompatibilityDimension.guests => 'Guests',
    CompatibilityDimension.smoking => 'Smoking',
    CompatibilityDimension.budget => 'Budget',
    CompatibilityDimension.study => 'Study habits',
    CompatibilityDimension.sharing => 'Sharing',
    CompatibilityDimension.pets => 'Pets',
  };
}

/// One line of the "Why are we compatible?" breakdown.
class CompatibilityFactor extends Equatable {
  final CompatibilityDimension dimension;

  /// 0–100 agreement on this dimension alone.
  final int score;

  /// Plain-language explanation shown to the student.
  final String note;

  const CompatibilityFactor({
    required this.dimension,
    required this.score,
    required this.note,
  });

  bool get isStrength => score >= 70;

  bool get isFriction => score < 40;

  @override
  List<Object?> get props => [dimension, score, note];
}

/// The full result of comparing two lifestyle profiles.
class CompatibilityBreakdown extends Equatable {
  /// Overall 0–100 score shown on the listing card.
  final int score;

  /// Per-dimension detail, strongest agreement first.
  final List<CompatibilityFactor> factors;

  /// True when a hard preference rules the match out entirely — currently
  /// only a same-gender-only requirement that the other student does not meet.
  final bool blocked;

  final String? blockedReason;

  const CompatibilityBreakdown({
    required this.score,
    required this.factors,
    this.blocked = false,
    this.blockedReason,
  });

  List<CompatibilityFactor> get strengths =>
      factors.where((f) => f.isStrength).toList();

  List<CompatibilityFactor> get frictions =>
      factors.where((f) => f.isFriction).toList();

  /// Short headline for the compatibility sheet.
  String get headline {
    if (blocked) return 'Not a match';
    if (score >= 85) return 'Excellent match';
    if (score >= 70) return 'Strong match';
    if (score >= 55) return 'Decent match';
    if (score >= 40) return 'Some differences';
    return 'Probably not a fit';
  }

  @override
  List<Object?> get props => [score, factors, blocked, blockedReason];
}
