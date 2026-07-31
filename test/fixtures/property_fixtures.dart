import 'package:houslice/features/property/domain/entities/property.dart';

/// Builds a listing with sensible defaults so tests only state what matters.
Property buildProperty({
  String id = 'p1',
  String name = 'Sekimondo Apartments',
  String address = 'KG 11 Ave, Gasabo',
  String description = 'A bright room close to campus.',
  num pricePerMonth = 120,
  double rating = 4.6,
  int compatibility = 88,
  List<String>? images,
  int bedrooms = 2,
  int bathrooms = 1,
  String agentName = 'Jane Simmons',
  String agentPhone = '+250780000000',
  bool isFavorite = false,
}) {
  return Property(
    id: id,
    name: name,
    address: address,
    description: description,
    pricePerMonth: pricePerMonth,
    rating: rating,
    compatibility: compatibility,
    images: images ?? const ['https://example.com/a.jpg'],
    bedrooms: bedrooms,
    bathrooms: bathrooms,
    agentName: agentName,
    agentPhone: agentPhone,
    isFavorite: isFavorite,
  );
}
