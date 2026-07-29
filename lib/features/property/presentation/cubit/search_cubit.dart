import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/property.dart';
import '../../domain/usecases/search_properties.dart';

enum SearchStatus { idle, loading, results, empty, failure }

class SearchState extends Equatable {
  final SearchStatus status;
  final String query;
  final List<Property> results;

  /// Properties the student opened from search results ("Recent" section).
  final List<Property> recent;

  const SearchState({
    this.status = SearchStatus.idle,
    this.query = '',
    this.results = const [],
    this.recent = const [],
  });

  SearchState copyWith({
    SearchStatus? status,
    String? query,
    List<Property>? results,
    List<Property>? recent,
  }) => SearchState(
    status: status ?? this.status,
    query: query ?? this.query,
    results: results ?? this.results,
    recent: recent ?? this.recent,
  );

  @override
  List<Object?> get props => [status, query, results, recent];
}

class SearchCubit extends Cubit<SearchState> {
  final SearchProperties searchProperties;

  SearchCubit({required this.searchProperties}) : super(const SearchState());

  Future<void> search(String query) async {
    final q = query.trim();
    if (q.isEmpty) {
      emit(state.copyWith(status: SearchStatus.idle, query: '', results: []));
      return;
    }
    emit(state.copyWith(status: SearchStatus.loading, query: q));
    final result = await searchProperties(q);
    // Ignore stale responses if the query changed while awaiting.
    if (state.query != q) return;
    result.fold(
      (failure) => emit(state.copyWith(status: SearchStatus.failure)),
      (properties) => emit(
        state.copyWith(
          status: properties.isEmpty
              ? SearchStatus.empty
              : SearchStatus.results,
          results: properties,
        ),
      ),
    );
  }

  /// Remember a result the student opened, newest first, capped at five.
  void select(Property property) {
    final recent = [
      property,
      ...state.recent.where((p) => p.id != property.id),
    ].take(5).toList();
    emit(state.copyWith(recent: recent));
  }

  void clear() =>
      emit(state.copyWith(status: SearchStatus.idle, query: '', results: []));
}
