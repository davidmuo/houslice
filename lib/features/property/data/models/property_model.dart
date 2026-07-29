import '../../../lifestyle/data/models/lifestyle_profile_model.dart';
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
    super.hostType,
    super.listingKind,
    super.ownerUid,
    super.hostLifestyle,
  });

  factory PropertyModel.fromEntity(Property property) => PropertyModel(
    id: property.id,
    name: property.name,
    address: property.address,
    description: property.description,
    pricePerMonth: property.pricePerMonth,
    rating: property.rating,
    compatibility: property.compatibility,
    images: property.images,
    bedrooms: property.bedrooms,
    bathrooms: property.bathrooms,
    agentName: property.agentName,
    agentPhone: property.agentPhone,
    isFavorite: property.isFavorite,
    hostType: property.hostType,
    listingKind: property.listingKind,
    ownerUid: property.ownerUid,
    hostLifestyle: property.hostLifestyle,
  );

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
        hostType: _decodeEnum(
          HostType.values,
          map['hostType'],
          HostType.student,
        ),
        listingKind: _decodeEnum(
          ListingKind.values,
          map['listingKind'],
          ListingKind.housemate,
        ),
        ownerUid: (map['ownerUid'] ?? '') as String,
        hostLifestyle: map['hostLifestyle'] is Map
            ? LifestyleProfileModel.fromMap(
                Map<String, dynamic>.from(map['hostLifestyle'] as Map),
              )
            : null,
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
    'hostType': hostType.name,
    'listingKind': listingKind.name,
    'ownerUid': ownerUid,
    if (hostLifestyle != null)
      'hostLifestyle': LifestyleProfileModel.toMap(hostLifestyle!),
  };

  PropertyModel withId(String newId) => _copy(id: newId);

  PropertyModel withFavorite(bool value) => _copy(isFavorite: value);

  PropertyModel withOwner(String uid) => _copy(ownerUid: uid);

  /// Single copy implementation the named helpers delegate to, so adding a
  /// field to [Property] only has to be handled in one place.
  PropertyModel _copy({String? id, bool? isFavorite, String? ownerUid}) =>
      PropertyModel(
        id: id ?? this.id,
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
        hostType: hostType,
        listingKind: listingKind,
        ownerUid: ownerUid ?? this.ownerUid,
        hostLifestyle: hostLifestyle,
      );

  static T _decodeEnum<T extends Enum>(
    List<T> values,
    dynamic name,
    T fallback,
  ) => values.firstWhere((value) => value.name == name, orElse: () => fallback);
}
