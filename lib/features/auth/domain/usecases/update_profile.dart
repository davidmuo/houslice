import 'package:equatable/equatable.dart';

import '../../../../core/error/result.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/app_user.dart';
import '../repositories/auth_repository.dart';

/// Saves the editable parts of a student's profile.
class UpdateProfile extends UseCase<AppUser, UpdateProfileParams> {
  final AuthRepository repository;

  UpdateProfile(this.repository);

  @override
  Future<Result<AppUser>> call(UpdateProfileParams params) =>
      repository.updateProfile(
        username: params.username,
        photoUrl: params.photoUrl,
        dateOfBirth: params.dateOfBirth,
      );
}

class UpdateProfileParams extends Equatable {
  final String username;
  final String? photoUrl;
  final String? dateOfBirth;

  const UpdateProfileParams({
    required this.username,
    this.photoUrl,
    this.dateOfBirth,
  });

  @override
  List<Object?> get props => [username, photoUrl, dateOfBirth];
}
