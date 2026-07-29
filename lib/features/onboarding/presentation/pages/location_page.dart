import 'package:flutter/material.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/primary_button.dart';

/// "Hi, Nice to meet you!" location chooser shown right after registration.
class LocationPage extends StatelessWidget {
  const LocationPage({super.key});

  void _continue(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
    Navigator.of(
      context,
    ).pushNamedAndRemoveUntil(AppRoutes.main, (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.only(top: 8),
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
                    onPressed: () => Navigator.of(
                      context,
                    ).pushNamedAndRemoveUntil(AppRoutes.main, (route) => false),
                    child: const Text('Skip'),
                  ),
                ),
              ),
              const Spacer(),
              Container(
                width: 220,
                height: 220,
                decoration: const BoxDecoration(
                  color: AppColors.primaryFaint,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.map_outlined,
                  size: 96,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 40),
              Text(
                'Hi, Nice to meet you !',
                style: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Choose your location to find property\naround you',
                textAlign: TextAlign.center,
                style: textTheme.bodyLarge?.copyWith(color: AppColors.grey),
              ),
              const Spacer(),
              PrimaryButton(
                label: 'Use current location',
                onPressed: () =>
                    _continue(context, 'Location set to Kigali, Rwanda'),
              ),
              const SizedBox(height: 14),
              PrimaryButton(
                label: 'Select it manually',
                outlined: true,
                onPressed: () async {
                  // Returns the chosen district, or null if backed out.
                  final district = await Navigator.of(
                    context,
                  ).pushNamed<String>(AppRoutes.locationPicker);
                  if (!context.mounted) return;
                  if (district != null) {
                    _continue(context, 'Showing listings in $district first');
                  }
                },
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
