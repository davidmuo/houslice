import '../domain/entities/lifestyle_profile.dart';

/// One step of the lifestyle questionnaire.
///
/// Each question knows how to read its current answer out of the draft profile
/// and how to write a new one back, so the quiz cubit stays a plain
/// index-and-draft state machine that never needs to know what it is asking.
class QuizQuestion {
  final String prompt;
  final String helper;
  final List<String> options;

  /// Index of the currently selected option for [draft].
  final int Function(LifestyleProfile draft) selectedIndex;

  /// Returns a copy of [draft] with option [index] applied.
  final LifestyleProfile Function(LifestyleProfile draft, int index) apply;

  const QuizQuestion({
    required this.prompt,
    required this.helper,
    required this.options,
    required this.selectedIndex,
    required this.apply,
  });
}

/// Builds a question from any answer scale, so adding a dimension is one entry
/// in [kQuizQuestions] rather than a new hand-written widget.
QuizQuestion _scale<T extends Enum>({
  required String prompt,
  required String helper,
  required List<T> values,
  required String Function(T value) label,
  required T Function(LifestyleProfile draft) read,
  required LifestyleProfile Function(LifestyleProfile draft, T value) write,
}) {
  return QuizQuestion(
    prompt: prompt,
    helper: helper,
    options: [for (final value in values) label(value)],
    selectedIndex: (draft) => values.indexOf(read(draft)),
    apply: (draft, index) => write(draft, values[index]),
  );
}

/// The questionnaire, in the order students answer it. Identity and budget
/// come first because they are the hard filters; habit questions follow.
final kQuizQuestions = <QuizQuestion>[
  _scale<Gender>(
    prompt: 'Which best describes you?',
    helper: 'Used only for housemate matching, never shown on your listings.',
    values: Gender.values,
    label: (v) => v.label,
    read: (d) => d.gender,
    write: (d, v) => d.copyWith(gender: v),
  ),
  _scale<GenderPreference>(
    prompt: 'Who would you share a home with?',
    helper: 'We will only suggest housemates who match this.',
    values: GenderPreference.values,
    label: (v) => v.label,
    read: (d) => d.genderPreference,
    write: (d, v) => d.copyWith(genderPreference: v),
  ),
  _scale<BudgetBand>(
    prompt: 'What can you spend per month?',
    helper: 'Listings near your budget are ranked higher.',
    values: BudgetBand.values,
    label: (v) => v.label,
    read: (d) => d.budget,
    write: (d, v) => d.copyWith(budget: v),
  ),
  _scale<Bedtime>(
    prompt: 'When do you usually go to bed?',
    helper:
        'Mismatched sleep schedules are the most common housemate friction.',
    values: Bedtime.values,
    label: (v) => v.label,
    read: (d) => d.bedtime,
    write: (d, v) => d.copyWith(bedtime: v),
  ),
  _scale<Cleanliness>(
    prompt: 'How tidy do you keep shared spaces?',
    helper: 'Be honest — matching on this matters more than matching on rent.',
    values: Cleanliness.values,
    label: (v) => v.label,
    read: (d) => d.cleanliness,
    write: (d, v) => d.copyWith(cleanliness: v),
  ),
  _scale<SocialStyle>(
    prompt: 'How would you describe your social life?',
    helper: 'There is no right answer — we match similar energies.',
    values: SocialStyle.values,
    label: (v) => v.label,
    read: (d) => d.social,
    write: (d, v) => d.copyWith(social: v),
  ),
  _scale<GuestFrequency>(
    prompt: 'How often do you have overnight guests?',
    helper: 'Housemates like to know what to expect.',
    values: GuestFrequency.values,
    label: (v) => v.label,
    read: (d) => d.guests,
    write: (d, v) => d.copyWith(guests: v),
  ),
  _scale<StudyStyle>(
    prompt: 'Where do you get your best work done?',
    helper: 'This tells us how quiet the home needs to be.',
    values: StudyStyle.values,
    label: (v) => v.label,
    read: (d) => d.study,
    write: (d, v) => d.copyWith(study: v),
  ),
  _scale<SmokingStance>(
    prompt: 'Do you smoke?',
    helper: 'We never match a smoker with someone who wants a smoke-free home.',
    values: SmokingStance.values,
    label: (v) => v.label,
    read: (d) => d.smoking,
    write: (d, v) => d.copyWith(smoking: v),
  ),
  _scale<SharingStyle>(
    prompt: 'Food and household items?',
    helper: 'Groceries and cleaning supplies are a classic flashpoint.',
    values: SharingStyle.values,
    label: (v) => v.label,
    read: (d) => d.sharing,
    write: (d, v) => d.copyWith(sharing: v),
  ),
  _scale<PetStance>(
    prompt: 'How do you feel about pets?',
    helper: 'Allergies are treated as a hard limit.',
    values: PetStance.values,
    label: (v) => v.label,
    read: (d) => d.pets,
    write: (d, v) => d.copyWith(pets: v),
  ),
];

/// The free-text step shown after the scales, matching the "Tell us about
/// yourself" screen in the prototype.
const kQuizBioPrompt = 'Tell us how you about yourself';
const kQuizBioHelper =
    'A couple of lines your future housemates will see — what you study, '
    'what your week looks like, anything you want them to know.';
const kQuizBioMaxLength = 300;
