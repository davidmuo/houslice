import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../lifestyle/domain/entities/lifestyle_profile.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/services/photo_service.dart';
import '../../domain/entities/property.dart';
import '../../domain/usecases/create_listing.dart';
import '../../domain/usecases/update_listing.dart';

enum CreateListingStatus { editing, submitting, success, failure }

class CreateListingState extends Equatable {
  final CreateListingStatus status;
  final HostType hostType;
  final ListingKind listingKind;
  final int bedrooms;
  final int bathrooms;
  final String? message;
  final Property? published;

  const CreateListingState({
    this.status = CreateListingStatus.editing,
    this.hostType = HostType.student,
    this.listingKind = ListingKind.housemate,
    this.bedrooms = 1,
    this.bathrooms = 1,
    this.message,
    this.published,
  });

  bool get busy => status == CreateListingStatus.submitting;

  /// Only a student offering a room in a shared home attaches their lifestyle
  /// answers — an agency letting a whole flat has nobody to match against.
  bool get attachesLifestyle =>
      hostType == HostType.student && listingKind == ListingKind.housemate;

  CreateListingState copyWith({
    CreateListingStatus? status,
    HostType? hostType,
    ListingKind? listingKind,
    int? bedrooms,
    int? bathrooms,
    String? message,
    Property? published,
  }) => CreateListingState(
    status: status ?? this.status,
    hostType: hostType ?? this.hostType,
    listingKind: listingKind ?? this.listingKind,
    bedrooms: bedrooms ?? this.bedrooms,
    bathrooms: bathrooms ?? this.bathrooms,
    message: message,
    published: published ?? this.published,
  );

  @override
  List<Object?> get props => [
    status,
    hostType,
    listingKind,
    bedrooms,
    bathrooms,
    message,
    published,
  ];
}

class CreateListingCubit extends Cubit<CreateListingState> {
  final CreateListing createListing;
  final UpdateListing updateListing;
  final PhotoService photoService;

  /// The listing being edited, or null when publishing a new one. Editing
  /// reuses this cubit wholesale because the form is identical — only the
  /// call it ends in differs.
  final Property? existing;

  CreateListingCubit({
    required this.createListing,
    required this.updateListing,
    required this.photoService,
    this.existing,
  }) : super(
         // Seed the toggles from the listing so an edit opens on its own
         // values instead of the defaults for a brand-new listing.
         existing == null
             ? const CreateListingState()
             : CreateListingState(
                 hostType: existing.hostType,
                 listingKind: existing.listingKind,
                 bedrooms: existing.bedrooms,
                 bathrooms: existing.bathrooms,
               ),
       );

  bool get isEditing => existing != null;

  void setHostType(HostType type) {
    // A letting agent never lists a housemate room, so keep the pair coherent.
    emit(
      state.copyWith(
        hostType: type,
        listingKind: type == HostType.realtor
            ? ListingKind.entirePlace
            : state.listingKind,
      ),
    );
  }

  void setListingKind(ListingKind kind) =>
      emit(state.copyWith(listingKind: kind));

  void setBedrooms(int value) =>
      emit(state.copyWith(bedrooms: value.clamp(1, 10)));

  void setBathrooms(int value) =>
      emit(state.copyWith(bathrooms: value.clamp(1, 10)));

  Future<void> submit({
    required String name,
    required String address,
    required String description,
    required num pricePerMonth,
    required String contactName,
    required String contactPhone,
    required List<String> images,
    LifestyleProfile? hostLifestyle,
  }) async {
    emit(state.copyWith(status: CreateListingStatus.submitting));

    // Photos are picked as on-device paths; upload them now so the listing
    // stores URLs other students' phones can actually load.
    final uploaded = <String>[];
    for (final path in images) {
      if (!PhotoService.isLocal(path)) {
        uploaded.add(path);
        continue;
      }
      try {
        uploaded.add(await photoService.upload(path, folder: 'listings'));
      } on ServerException catch (e) {
        emit(
          state.copyWith(
            status: CreateListingStatus.failure,
            message: e.message,
          ),
        );
        return;
      }
    }

    final listing = Property(
      // Empty on create — replaced by the backend-assigned id on save. An edit
      // keeps the existing id so the same document is written.
      id: existing?.id ?? '',
      name: name,
      address: address,
      description: description,
      pricePerMonth: pricePerMonth,
      // A brand-new listing has no reviews yet; an edit must not wipe the
      // rating and baseline score the listing has already earned.
      rating: existing?.rating ?? 0,
      compatibility: existing?.compatibility ?? 0,
      images: uploaded,
      bedrooms: state.bedrooms,
      bathrooms: state.bathrooms,
      agentName: contactName,
      agentPhone: contactPhone,
      hostType: state.hostType,
      listingKind: state.listingKind,
      // Preserved so the rules' ownerUid-immutability check passes; on create
      // the data source stamps the caller's uid.
      ownerUid: existing?.ownerUid ?? '',
      hostLifestyle: state.attachesLifestyle ? hostLifestyle : null,
    );

    final result = isEditing
        ? await updateListing(UpdateListingParams(listing))
        : await createListing(CreateListingParams(listing));
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: CreateListingStatus.failure,
          message: failure.message,
        ),
      ),
      (published) => emit(
        state.copyWith(
          status: CreateListingStatus.success,
          published: published,
        ),
      ),
    );
  }
}
