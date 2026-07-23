part of 'property_bloc.dart';

sealed class PropertyEvent extends Equatable {
  const PropertyEvent();

  @override
  List<Object?> get props => [];
}

class PropertiesRequested extends PropertyEvent {
  const PropertiesRequested();
}

class PropertyFavoriteToggled extends PropertyEvent {
  final String propertyId;

  const PropertyFavoriteToggled(this.propertyId);

  @override
  List<Object?> get props => [propertyId];
}
