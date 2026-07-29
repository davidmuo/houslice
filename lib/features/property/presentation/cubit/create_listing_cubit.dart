import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../lifestyle/domain/entities/lifestyle_profile.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/services/photo_service.dart';
import '../../domain/entities/property.dart';
import '../../domain/usecases/create_listing.dart';

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
  final PhotoService photoService;

  CreateListingCubit({required this.createListing, required this.photoService})
    : super(const CreateListingState());

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
      // Replaced by the backend-assigned id on save.
      id: '',
      name: name,
      address: address,
      description: description,
      pricePerMonth: pricePerMonth,
      // A brand-new listing has no reviews yet.
      rating: 0,
      compatibility: 0,
      images: uploaded,
      bedrooms: state.bedrooms,
      bathrooms: state.bathrooms,
      agentName: contactName,
      agentPhone: contactPhone,
      hostType: state.hostType,
      listingKind: state.listingKind,
      hostLifestyle: state.attachesLifestyle ? hostLifestyle : null,
    );

    final result = await createListing(CreateListingParams(listing));
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
