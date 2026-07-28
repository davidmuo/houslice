import '../../domain/entities/property.dart';

class PropertyModel extends Property {
  const PropertyModel({
    required super.id,
    required super.name,
    required super.address,
    required super.description,
    required super.pricePerMonth,
    required super.rating,
    required super.compatibility,
    required super.images,
    required super.bedrooms,
    required super.bathrooms,
    required super.agentName,
    required super.agentPhone,
    super.isFavorite,
  });

  factory PropertyModel.fromMap(String id, Map<String, dynamic> map) =>
      PropertyModel(
        id: id,
        name: (map['name'] ?? '') as String,
        address: (map['address'] ?? '') as String,
        description: (map['description'] ?? '') as String,
        pricePerMonth: (map['pricePerMonth'] ?? 0) as num,
        rating: ((map['rating'] ?? 0) as num).toDouble(),
        compatibility: ((map['compatibility'] ?? 0) as num).toInt(),
        images: List<String>.from((map['images'] ?? const []) as List),
        bedrooms: ((map['bedrooms'] ?? 1) as num).toInt(),
        bathrooms: ((map['bathrooms'] ?? 1) as num).toInt(),
        agentName: (map['agentName'] ?? '') as String,
        agentPhone: (map['agentPhone'] ?? '') as String,
      );

  Map<String, dynamic> toMap() => {
        'name': name,
        'address': address,
        'description': description,
        'pricePerMonth': pricePerMonth,
        'rating': rating,
        'compatibility': compatibility,
        'images': images,
        'bedrooms': bedrooms,
        'bathrooms': bathrooms,
        'agentName': agentName,
        'agentPhone': agentPhone,
      };

  PropertyModel withFavorite(bool value) => PropertyModel(
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
        isFavorite: value,
      );
}
