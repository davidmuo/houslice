import 'package:equatable/equatable.dart';

/// A room / apartment listing on the Houseslice marketplace.
class Property extends Equatable {
  final String id;
  final String name;
  final String address;
  final String description;
  final num pricePerMonth;
  final double rating;

  /// Lifestyle compatibility score (0-100) between the current student and
  /// the listing's housemates, computed from the lifestyle quiz.
  final int compatibility;
  final List<String> images;
  final int bedrooms;
  final int bathrooms;
  final String agentName;
  final String agentPhone;
  final bool isFavorite;

  const Property({
    required this.id,
    required this.name,
    required this.address,
    required this.description,
    required this.pricePerMonth,
    required this.rating,
    required this.compatibility,
    required this.images,
    required this.bedrooms,
    required this.bathrooms,
    required this.agentName,
    required this.agentPhone,
    this.isFavorite = false,
  });

  String get coverImage => images.isEmpty ? '' : images.first;

  Property copyWith({bool? isFavorite}) => Property(
        id: id,
        name: name,
        address: address,
        description: description,
        pricePerMonth: pricePerMonth,
        rating: rating,
        compatibility: compatibility,
        images: images,
        bedrooms: bedrooms,
        bathrooms: bathrooms,
        agentName: agentName,
        agentPhone: agentPhone,
        isFavorite: isFavorite ?? this.isFavorite,
      );

  @override
  List<Object?> get props => [
        id,
        name,
        address,
        description,
        pricePerMonth,
        rating,
        compatibility,
        images,
        bedrooms,
        bathrooms,
        agentName,
        agentPhone,
        isFavorite,
      ];
}
