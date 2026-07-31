import 'package:equatable/equatable.dart';

import '../../../../core/error/result.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/property_repository.dart';

/// Removes a listing the signed-in user published.
class DeleteListing extends UseCase<void, DeleteListingParams> {
  final PropertyRepository repository;

  DeleteListing(this.repository);

  @override
  Future<Result<void>> call(DeleteListingParams params) =>
      repository.deleteListing(params.propertyId);
}

class DeleteListingParams extends Equatable {
  final String propertyId;

  const DeleteListingParams(this.propertyId);

  @override
  List<Object?> get props => [propertyId];
}
