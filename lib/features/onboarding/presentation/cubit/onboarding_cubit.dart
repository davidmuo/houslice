import 'package:flutter_bloc/flutter_bloc.dart';

/// Tracks the current onboarding slide index.
class OnboardingCubit extends Cubit<int> {
  OnboardingCubit() : super(0);

  void pageChanged(int index) => emit(index);
}
