import 'package:flutter_bloc/flutter_bloc.dart';

/// Selected bottom-navigation tab of the main shell.
class NavCubit extends Cubit<int> {
  NavCubit() : super(0);

  void select(int index) => emit(index);
}
