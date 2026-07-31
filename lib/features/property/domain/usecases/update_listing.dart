import 'package:equatable/equatable.dart';

import '../../../../core/error/result.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/property.dart';
import '../repositories/property_repository.dart';

/// Saves edits to a listing the signed-in user published.
class UpdateListing extends UseCase<Property, UpdateListingParams> {
  final PropertyRepository repository;

  UpdateListing(this.repository);

  @override
  Future<Result<Property>> call(UpdateListingParams params) =>
      repository.updateListing(params.listing);
}

class UpdateListingParams extends Equatable {
  final Property listing;

  const UpdateListingParams(this.listing);

  @override
  List<Object?> get props => [listing];
}
