import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/primary_button.dart';
import '../cubit/lifestyle_cubit.dart';
import '../cubit/quiz_cubit.dart';
import '../quiz_questions.dart';

/// The lifestyle questionnaire shown after registration.
///
/// Answers feed the compatibility score on every housemate listing, so the
/// copy explains why each question is being asked rather than just asking it.
class QuizPage extends StatelessWidget {
  const QuizPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          QuizCubit(initial: context.read<LifestyleCubit>().state.profile),
      child: const _QuizView(),
    );
  }
}

class _QuizView extends StatefulWidget {
  const _QuizView();

  @override
  State<_QuizView> createState() => _QuizViewState();
}

/// Stateful only to own the bio text controller.
class _QuizViewState extends State<_QuizView> {
  final _bioController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _bioController.text = context.read<QuizCubit>().state.draft.bio;
  }

  @override
  void dispose() {
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _finish(BuildContext context) async {
    final cubit = context.read<QuizCubit>();
    cubit.setBio(_bioController.text);

    await context.read<LifestyleCubit>().save(cubit.state.draft);
    if (!context.mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text('Your matches are ready')));

    // Retaking the quiz from Settings should return where it came from;
    // finishing it during sign-up continues to the location step.
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      Navigator.of(
        context,
      ).pushNamedAndRemoveUntil(AppRoutes.location, (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return BlocBuilder<QuizCubit, QuizState>(
      builder: (context, state) {
        final cubit = context.read<QuizCubit>();
        final question = state.question;

        return Scaffold(
          appBar: AppBar(
            leading: state.canGoBack
                ? IconButton(
                    onPressed: cubit.back,
                    icon: const Icon(Icons.arrow_back),
                  )
                : null,
            automaticallyImplyLeading: false,
            title: Text(state.counter, style: textTheme.bodyMedium),
            actions: [
              TextButton(
                onPressed: state.isBioStep ? null : cubit.skipToEnd,
                child: const Text('Skip'),
              ),
            ],
          ),
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: state.progress,
                      minHeight: 8,
                      backgroundColor: AppColors.border,
                      valueColor: const AlwaysStoppedAnimation(
                        AppColors.primary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    children: [
                      Text(
                        question?.prompt ?? kQuizBioPrompt,
                        style: textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          height: 1.25,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        question?.helper ?? kQuizBioHelper,
                        style: textTheme.bodyMedium?.copyWith(
                          color: AppColors.grey,
                        ),
                      ),
                      const SizedBox(height: 24),
                      if (question != null)
                        for (var i = 0; i < question.options.length; i++)
                          _OptionTile(
                            label: question.options[i],
                            selected: question.selectedIndex(state.draft) == i,
                            onTap: () => cubit.answer(i),
                          )
                      else
                        _BioField(controller: _bioController),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                  child: PrimaryButton(
                    label: state.isLastStep ? 'Finish' : 'Next',
                    onPressed: () =>
                        state.isLastStep ? _finish(context) : cubit.next(),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _OptionTile extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _OptionTile({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          // 60dp clears the 48dp Material minimum tap target.
          constraints: const BoxConstraints(minHeight: 60),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: selected ? AppColors.primaryFaint : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.border,
              width: selected ? 1.6 : 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                selected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                color: selected ? AppColors.primary : AppColors.grey,
                size: 22,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BioField extends StatelessWidget {
  final TextEditingController controller;

  const _BioField({required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: 6,
      maxLength: kQuizBioMaxLength,
      textCapitalization: TextCapitalization.sentences,
      decoration: const InputDecoration(
        hintText:
            'I am a second-year studying software engineering. '
            'Early riser, tidy, and I cook most evenings…',
      ),
    );
  }
}
