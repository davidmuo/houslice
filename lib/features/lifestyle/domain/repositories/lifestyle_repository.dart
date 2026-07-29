import '../../../../core/error/result.dart';
import '../entities/lifestyle_profile.dart';

/// Reads and writes the signed-in student's lifestyle questionnaire answers.
abstract class LifestyleRepository {
  /// Returns null when the student has not taken the questionnaire yet.
  Future<Result<LifestyleProfile?>> load();

  Future<Result<LifestyleProfile>> save(LifestyleProfile profile);

  /// Clears the stored answers so the questionnaire can be retaken.
  Future<Result<void>> clear();
}
