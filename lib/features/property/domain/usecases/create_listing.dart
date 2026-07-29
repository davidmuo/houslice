import 'package:equatable/equatable.dart';

import '../../../../core/error/result.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/property.dart';
import '../repositories/property_repository.dart';

/// Publishes a room or property listing on behalf of the signed-in user.
class CreateListing extends UseCase<Property, CreateListingParams> {
  final PropertyRepository repository;

  CreateListing(this.repository);

  @override
  Future<Result<Property>> call(CreateListingParams params) =>
      repository.createListing(params.listing);
}

class CreateListingParams extends Equatable {
  final Property listing;

  const CreateListingParams(this.listing);

  @override
  List<Object?> get props => [listing];
}
