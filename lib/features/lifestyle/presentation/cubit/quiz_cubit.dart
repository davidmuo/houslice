import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/lifestyle_profile.dart';
import '../quiz_questions.dart';

class QuizState extends Equatable {
  /// 0-based step. Indices below [kQuizQuestions].length are scale questions;
  /// the final index is the free-text step.
  final int step;
  final LifestyleProfile draft;

  const QuizState({this.step = 0, this.draft = LifestyleProfile.empty});

  static int get totalSteps => kQuizQuestions.length + 1;

  bool get isBioStep => step == kQuizQuestions.length;

  bool get isLastStep => step == totalSteps - 1;

  bool get canGoBack => step > 0;

  double get progress => (step + 1) / totalSteps;

  /// Human-readable position, e.g. "3/12".
  String get counter => '${step + 1}/$totalSteps';

  QuizQuestion? get question => isBioStep ? null : kQuizQuestions[step];

  QuizState copyWith({int? step, LifestyleProfile? draft}) =>
      QuizState(step: step ?? this.step, draft: draft ?? this.draft);

  @override
  List<Object?> get props => [step, draft];
}

/// Drives the sign-up questionnaire: which step is showing and the answers
/// gathered so far. Nothing is persisted until the final step is submitted.
class QuizCubit extends Cubit<QuizState> {
  QuizCubit({LifestyleProfile? initial})
    : super(QuizState(draft: initial ?? LifestyleProfile.empty));

  /// Records an answer for the current scale question and advances.
  void answer(int optionIndex) {
    final question = state.question;
    if (question == null) return;
    emit(state.copyWith(draft: question.apply(state.draft, optionIndex)));
  }

  void setBio(String bio) =>
      emit(state.copyWith(draft: state.draft.copyWith(bio: bio.trim())));

  void next() {
    if (state.isLastStep) return;
    emit(state.copyWith(step: state.step + 1));
  }

  void back() {
    if (!state.canGoBack) return;
    emit(state.copyWith(step: state.step - 1));
  }

  /// Jumps straight to the free-text step, used by "Skip".
  void skipToEnd() => emit(state.copyWith(step: QuizState.totalSteps - 1));
}
