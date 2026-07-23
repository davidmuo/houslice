import 'package:flutter_bloc/flutter_bloc.dart';

/// Tiny reusable cubit for boolean UI state (password visibility,
/// checkboxes, ...) so widgets never need `setState`.
class ToggleCubit extends Cubit<bool> {
  ToggleCubit([super.initial = false]);

  void toggle() => emit(!state);

  void set(bool value) => emit(value);
}

/// Reusable cubit for an integer index (carousels, tab bars, galleries).
class IndexCubit extends Cubit<int> {
  IndexCubit([super.initial = 0]);

  void set(int value) => emit(value);
}
