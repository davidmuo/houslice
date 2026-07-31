import 'package:flutter_test/flutter_test.dart';
import 'package:houslice/features/lifestyle/data/datasources/lifestyle_local_data_source.dart';
import 'package:houslice/features/lifestyle/data/models/lifestyle_profile_model.dart';
import 'package:houslice/features/lifestyle/domain/entities/lifestyle_profile.dart';
import 'package:houslice/features/lifestyle/presentation/cubit/quiz_cubit.dart';
import 'package:houslice/features/lifestyle/presentation/quiz_questions.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Tests for questionnaire serialisation, on-device persistence, and the quiz
/// step machine.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const filled = LifestyleProfile(
    bedtime: Bedtime.afterTwo,
    cleanliness: Cleanliness.spotless,
    social: SocialStyle.verySocial,
    study: StudyStyle.campusOrLibrary,
    guests: GuestFrequency.often,
    smoking: SmokingStance.smoker,
    budget: BudgetBand.over250,
    gender: Gender.nonBinary,
    genderPreference: GenderPreference.sameGenderOnly,
    sharing: SharingStyle.keepSeparate,
    pets: PetStance.allergic,
    bio: 'Night owl, very tidy.',
  );

  group('LifestyleProfileModel', () {
    test('round-trips every answer through JSON', () {
      final restored = LifestyleProfileModel.decode(
        LifestyleProfileModel.encode(filled),
      );

      expect(restored, filled);
    });

    test('stores answers by enum name, not index', () {
      final map = LifestyleProfileModel.toMap(filled);

      expect(map['bedtime'], 'afterTwo');
      expect(map['cleanliness'], 'spotless');
      expect(map['budget'], 'over250');
    });

    test('unknown values fall back to the questionnaire defaults', () {
      final restored = LifestyleProfileModel.fromMap({
        'bedtime': 'sometime-next-week',
        'cleanliness': null,
      });

      expect(restored.bedtime, LifestyleProfile.empty.bedtime);
      expect(restored.cleanliness, LifestyleProfile.empty.cleanliness);
    });

    test('decode returns null for absent or malformed data', () {
      expect(LifestyleProfileModel.decode(null), isNull);
      expect(LifestyleProfileModel.decode(''), isNull);
      expect(LifestyleProfileModel.decode('not json'), isNull);
      expect(LifestyleProfileModel.decode('[1,2,3]'), isNull);
    });
  });

  group('SharedPrefsLifestyleDataSource', () {
    setUp(() => SharedPreferences.setMockInitialValues({}));

    Future<SharedPrefsLifestyleDataSource> dataSource() async =>
        SharedPrefsLifestyleDataSource(await SharedPreferences.getInstance());

    test('returns null before the quiz is taken', () async {
      expect(await (await dataSource()).load(), isNull);
    });

    test('answers survive a simulated relaunch', () async {
      await (await dataSource()).save(filled);

      expect(await (await dataSource()).load(), filled);
    });

    test('clear removes the stored answers', () async {
      final source = await dataSource();
      await source.save(filled);
      await source.clear();

      expect(await source.load(), isNull);
    });
  });

  group('QuizCubit', () {
    test('starts on the first question with neutral answers', () {
      final cubit = QuizCubit();

      expect(cubit.state.step, 0);
      expect(cubit.state.canGoBack, isFalse);
      expect(cubit.state.isBioStep, isFalse);
      expect(cubit.state.draft, LifestyleProfile.empty);
      expect(cubit.state.counter, '1/${QuizState.totalSteps}');
      cubit.close();
    });

    test('total steps is every scale question plus the free-text step', () {
      expect(QuizState.totalSteps, kQuizQuestions.length + 1);
    });

    test('answering records the choice without advancing', () {
      final cubit = QuizCubit();
      final question = cubit.state.question!;

      cubit.answer(2);

      expect(cubit.state.step, 0);
      expect(question.selectedIndex(cubit.state.draft), 2);
      cubit.close();
    });

    test('next and back walk the questionnaire', () {
      final cubit = QuizCubit();

      cubit.next();
      expect(cubit.state.step, 1);
      expect(cubit.state.canGoBack, isTrue);

      cubit.back();
      expect(cubit.state.step, 0);

      // Cannot step behind the first question.
      cubit.back();
      expect(cubit.state.step, 0);
      cubit.close();
    });

    test('skipToEnd jumps to the free-text step', () {
      final cubit = QuizCubit();

      cubit.skipToEnd();

      expect(cubit.state.isBioStep, isTrue);
      expect(cubit.state.isLastStep, isTrue);
      expect(cubit.state.question, isNull);
      expect(cubit.state.progress, 1.0);
      cubit.close();
    });

    test('next does nothing on the last step', () {
      final cubit = QuizCubit();

      cubit.skipToEnd();
      final atEnd = cubit.state.step;
      cubit.next();

      expect(cubit.state.step, atEnd);
      cubit.close();
    });

    test('setBio trims whitespace', () {
      final cubit = QuizCubit();

      cubit.setBio('   I cook on Sundays.  ');

      expect(cubit.state.draft.bio, 'I cook on Sundays.');
      cubit.close();
    });

    test('resumes from an existing profile', () {
      final cubit = QuizCubit(initial: filled);

      expect(cubit.state.draft, filled);
      cubit.close();
    });

    test('every question can read and write its own answer', () {
      final cubit = QuizCubit();

      for (var i = 0; i < kQuizQuestions.length; i++) {
        final question = kQuizQuestions[i];
        for (var option = 0; option < question.options.length; option++) {
          final updated = question.apply(cubit.state.draft, option);
          expect(
            question.selectedIndex(updated),
            option,
            reason: 'question $i option $option should round-trip',
          );
        }
      }
      cubit.close();
    });
  });
}
