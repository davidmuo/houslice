import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/result.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/property.dart';
import '../../domain/usecases/get_properties.dart';
import '../../domain/usecases/toggle_favorite.dart';

part 'property_event.dart';
part 'property_state.dart';

class PropertyBloc extends Bloc<PropertyEvent, PropertyState> {
  final GetProperties getProperties;
  final ToggleFavorite toggleFavorite;

  PropertyBloc({required this.getProperties, required this.toggleFavorite})
    : super(const PropertyState()) {
    on<PropertiesRequested>(_onPropertiesRequested);
    on<PropertyFavoriteToggled>(_onFavoriteToggled);
  }

  Future<void> _onPropertiesRequested(
    PropertiesRequested event,
    Emitter<PropertyState> emit,
  ) async {
    emit(state.copyWith(status: PropertyStatus.loading));
    final result = await getProperties(const NoParams());
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: PropertyStatus.failure,
          message: failure.message,
        ),
      ),
      (properties) => emit(
        state.copyWith(status: PropertyStatus.loaded, properties: properties),
      ),
    );
  }

  Future<void> _onFavoriteToggled(
    PropertyFavoriteToggled event,
    Emitter<PropertyState> emit,
  ) async {
    List<Property> flip(List<Property> list) => [
      for (final p in list)
        p.id == event.propertyId ? p.copyWith(isFavorite: !p.isFavorite) : p,
    ];

    // Optimistic update so the heart reacts instantly.
    emit(state.copyWith(properties: flip(state.properties)));

    final result = await toggleFavorite(event.propertyId);
    if (result is Err<bool>) {
      // Revert on failure and surface the error.
      emit(
        state.copyWith(
          properties: flip(state.properties),
          message: (result).failure.message,
        ),
      );
    }
  }
}
