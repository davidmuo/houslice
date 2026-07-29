import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/lifestyle_profile.dart';
import '../../domain/usecases/get_lifestyle_profile.dart';
import '../../domain/usecases/save_lifestyle_profile.dart';

class LifestyleState extends Equatable {
  /// Null until the student completes the questionnaire.
  final LifestyleProfile? profile;
  final String? errorMessage;

  const LifestyleState({this.profile, this.errorMessage});

  bool get hasProfile => profile != null;

  /// Neutral answers stand in before the quiz is taken, so compatibility can
  /// still be rendered rather than the UI having to special-case null.
  LifestyleProfile get effective => profile ?? LifestyleProfile.empty;

  @override
  List<Object?> get props => [profile, errorMessage];
}

/// Holds the signed-in student's questionnaire answers for the whole session.
/// Registered as a singleton so every listing screen scores against the same
/// profile.
class LifestyleCubit extends Cubit<LifestyleState> {
  final GetLifestyleProfile getLifestyleProfile;
  final SaveLifestyleProfile saveLifestyleProfile;

  LifestyleCubit({
    required this.getLifestyleProfile,
    required this.saveLifestyleProfile,
  }) : super(const LifestyleState());

  Future<void> load() async {
    final result = await getLifestyleProfile(const NoParams());
    result.fold(
      (failure) => emit(LifestyleState(errorMessage: failure.message)),
      (profile) => emit(LifestyleState(profile: profile)),
    );
  }

  Future<void> save(LifestyleProfile profile) async {
    final previous = state.profile;
    emit(LifestyleState(profile: profile));

    final result = await saveLifestyleProfile(SaveLifestyleParams(profile));
    result.fold(
      (failure) => emit(
        LifestyleState(profile: previous, errorMessage: failure.message),
      ),
      (saved) => emit(LifestyleState(profile: saved)),
    );
  }
}
