import 'package:equatable/equatable.dart';

import '../../../lifestyle/domain/entities/lifestyle_profile.dart';

/// Who published the listing. Shown as a badge so students can tell a peer
/// sublet apart from an agency listing at a glance.
enum HostType { student, realtor }

extension HostTypeX on HostType {
  String get label => switch (this) {
    HostType.student => 'Student',
    HostType.realtor => 'Realtor',
  };

  String get blurb => switch (this) {
    HostType.student => 'Listed by a verified student',
    HostType.realtor => 'Listed by a verified letting agent',
  };
}

/// What is on offer: a room in a shared home, or a whole property.
///
/// Compatibility only applies to [housemate] listings — there is nobody to be
/// compatible *with* when the whole place is empty.
enum ListingKind { housemate, entirePlace }

extension ListingKindX on ListingKind {
  String get label => switch (this) {
    ListingKind.housemate => 'Room in a shared home',
    ListingKind.entirePlace => 'Entire place',
  };
}

/// A room / apartment listing on the Houseslice marketplace.
class Property extends Equatable {
  final String id;
  final String name;
  final String address;
  final String description;
  final num pricePerMonth;
  final double rating;

  /// Baseline lifestyle compatibility (0-100) advertised on the listing.
  ///
  /// This is the fallback shown before a student takes the questionnaire. Once
  /// they have, the live score computed against [hostLifestyle] takes over.
  final int compatibility;
  final List<String> images;
  final int bedrooms;
  final int bathrooms;
  final String agentName;
  final String agentPhone;
  final bool isFavorite;

  final HostType hostType;
  final ListingKind listingKind;

  /// Firebase uid of whoever published the listing. Empty for the seeded
  /// catalogue. The Firestore rules use this to scope edits and deletes to the
  /// owner.
  final String ownerUid;

  /// The current housemate's questionnaire answers. Null for [entirePlace]
  /// listings and for rooms whose host has not taken the quiz.
  final LifestyleProfile? hostLifestyle;

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
    this.hostType = HostType.student,
    this.listingKind = ListingKind.housemate,
    this.ownerUid = '',
    this.hostLifestyle,
  });

  String get coverImage => images.isEmpty ? '' : images.first;

  bool get isHousemateListing => listingKind == ListingKind.housemate;

  /// True when a personalised score can be computed and explained.
  bool get supportsCompatibility => isHousemateListing && hostLifestyle != null;

  Property copyWith({
    bool? isFavorite,
    HostType? hostType,
    ListingKind? listingKind,
    LifestyleProfile? hostLifestyle,
  }) => Property(
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
    hostType: hostType ?? this.hostType,
    listingKind: listingKind ?? this.listingKind,
    ownerUid: ownerUid,
    hostLifestyle: hostLifestyle ?? this.hostLifestyle,
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
    hostType,
    listingKind,
    ownerUid,
    hostLifestyle,
  ];
}
