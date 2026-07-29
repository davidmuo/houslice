import 'package:equatable/equatable.dart';

import '../../../../core/error/result.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/lifestyle_profile.dart';
import '../repositories/lifestyle_repository.dart';

class SaveLifestyleProfile
    extends UseCase<LifestyleProfile, SaveLifestyleParams> {
  final LifestyleRepository repository;

  SaveLifestyleProfile(this.repository);

  @override
  Future<Result<LifestyleProfile>> call(SaveLifestyleParams params) =>
      repository.save(params.profile);
}

class SaveLifestyleParams extends Equatable {
  final LifestyleProfile profile;

  const SaveLifestyleParams(this.profile);

  @override
  List<Object?> get props => [profile];
}
