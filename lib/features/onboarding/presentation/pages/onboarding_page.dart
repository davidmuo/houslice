import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../settings/presentation/cubit/preferences_cubit.dart';
import '../cubit/onboarding_cubit.dart';

class _Slide {
  final List<(String text, bool bold)> title;
  final String subtitle;

  const _Slide({required this.title, required this.subtitle});
}

const _slides = [
  _Slide(
    title: [
      ('Find the ', false),
      ('perfect place', true),
      ('\nfor your future house', false),
    ],
    subtitle:
        'find the best place for your dream house with\nyour family and loved ones',
  ),
  _Slide(
    title: [('Match with ', false), ('compatible\nhousemates', true)],
    subtitle:
        'lifestyle-based matching pairs you with verified\nstudents you can actually live with',
  ),
  _Slide(
    title: [('find your ', false), ('dream home', true), ('\nwith us', false)],
    subtitle:
        'Just search and select your favorite property\nyou want to locate',
  ),
];

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

/// Stateful only to own the PageController; slide index lives in the cubit.
class _OnboardingPageState extends State<OnboardingPage> {
  final _controller = PageController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _goToRegister(BuildContext context) {
    // Remember the intro has been seen so the next launch skips straight to
    // sign-in. Persisted via SharedPreferences.
    context.read<PreferencesCubit>().completeOnboarding();
    Navigator.of(context).pushReplacementNamed(AppRoutes.register);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return BlocProvider(
      create: (_) => OnboardingCubit(),
      child: Scaffold(
        body: SafeArea(
          child: BlocBuilder<OnboardingCubit, int>(
            builder: (context, index) {
              final isLast = index == _slides.length - 1;
              return Column(
                children: [
                  Align(
                    alignment: Alignment.topRight,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          minimumSize: Size.zero,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                          side: const BorderSide(color: AppColors.border),
                          foregroundColor: AppColors.dark,
                          shape: const StadiumBorder(),
                        ),
                        onPressed: () => _goToRegister(context),
                        child: const Text('Skip'),
                      ),
                    ),
                  ),
                  Expanded(
                    child: PageView.builder(
                      controller: _controller,
                      itemCount: _slides.length,
                      onPageChanged: context
                          .read<OnboardingCubit>()
                          .pageChanged,
                      itemBuilder: (context, i) {
                        final slide = _slides[i];
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text.rich(
                                TextSpan(
                                  children: [
                                    for (final (text, bold) in slide.title)
                                      TextSpan(
                                        text: text,
                                        style: TextStyle(
                                          fontWeight: bold
                                              ? FontWeight.w800
                                              : FontWeight.w400,
                                        ),
                                      ),
                                  ],
                                ),
                                textAlign: TextAlign.center,
                                style: textTheme.headlineMedium?.copyWith(
                                  height: 1.3,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                slide.subtitle,
                                textAlign: TextAlign.center,
                                style: textTheme.bodyMedium?.copyWith(
                                  color: AppColors.grey,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (var i = 0; i < _slides.length; i++)
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: i == index ? 28 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: i == index
                                ? AppColors.primary
                                : AppColors.border,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 40, 24, 32),
                    child: PrimaryButton(
                      label: isLast ? 'Get Started' : 'Next',
                      onPressed: () {
                        if (isLast) {
                          _goToRegister(context);
                        } else {
                          _controller.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeOut,
                          );
                        }
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
