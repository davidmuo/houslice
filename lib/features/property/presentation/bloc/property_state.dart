part of 'property_bloc.dart';

enum PropertyStatus { initial, loading, loaded, failure }

class PropertyState extends Equatable {
  final PropertyStatus status;
  final List<Property> properties;
  final String? message;

  const PropertyState({
    this.status = PropertyStatus.initial,
    this.properties = const [],
    this.message,
  });

  List<Property> get favorites =>
      properties.where((p) => p.isFavorite).toList();

  Property? byId(String id) {
    for (final property in properties) {
      if (property.id == id) return property;
    }
    return null;
  }

  PropertyState copyWith({
    PropertyStatus? status,
    List<Property>? properties,
    String? message,
  }) =>
      PropertyState(
        status: status ?? this.status,
        properties: properties ?? this.properties,
        message: message,
      );

  @override
  List<Object?> get props => [status, properties, message];
}
