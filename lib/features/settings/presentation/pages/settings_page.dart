import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../lifestyle/presentation/cubit/lifestyle_cubit.dart';
import '../../domain/entities/app_preferences.dart';
import '../cubit/preferences_cubit.dart';

/// Lets the student change the four preferences that survive an app restart:
/// colour theme, notification opt-in, preferred district, and a reset for the
/// onboarding slides.
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PreferencesCubit, PreferencesState>(
      listenWhen: (previous, current) =>
          current.errorMessage != null &&
          previous.errorMessage != current.errorMessage,
      listener: (context, state) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(state.errorMessage!)));
      },
      builder: (context, state) {
        final cubit = context.read<PreferencesCubit>();
        final preferences = state.preferences;

        return Scaffold(
          appBar: AppBar(title: const Text('Settings')),
          body: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            children: [
              const _SectionLabel('Appearance'),
              _ThemeSelector(
                selected: preferences.themeMode,
                onChanged: cubit.setThemeMode,
              ),
              const SizedBox(height: 8),
              const Divider(),
              const _SectionLabel('Lifestyle & matching'),
              BlocBuilder<LifestyleCubit, LifestyleState>(
                builder: (context, lifestyle) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(
                    Icons.tune_rounded,
                    color: AppColors.primary,
                  ),
                  title: const Text('Your lifestyle answers'),
                  subtitle: Text(
                    lifestyle.hasProfile
                        ? 'Edit your answers to update every match score'
                        : 'Not answered yet — take it to see match scores',
                  ),
                  trailing: const Icon(
                    Icons.chevron_right,
                    color: AppColors.grey,
                  ),
                  onTap: () => Navigator.of(context).pushNamed(AppRoutes.quiz),
                ),
              ),
              const Divider(),
              const _SectionLabel('Notifications'),
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                value: preferences.notificationsEnabled,
                onChanged: cubit.setNotificationsEnabled,
                title: const Text('Booking and message alerts'),
                subtitle: const Text(
                  'Get notified when a host replies or a booking changes',
                ),
                activeThumbColor: AppColors.primary,
              ),
              const Divider(),
              const _SectionLabel('Preferred district'),
              Text(
                'Listings in this district are shown first on your home feed.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                children: [
                  for (final city in AppPreferences.cities)
                    ChoiceChip(
                      label: Text(city),
                      selected: preferences.preferredCity == city,
                      onSelected: (_) => cubit.setPreferredCity(city),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(),
              const _SectionLabel('Onboarding'),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(
                  Icons.restart_alt,
                  color: AppColors.primary,
                ),
                title: const Text('Replay the intro slides'),
                subtitle: Text(
                  preferences.onboardingComplete
                      ? 'Currently skipped on launch'
                      : 'Currently shown on launch',
                ),
                trailing: Switch.adaptive(
                  value: !preferences.onboardingComplete,
                  onChanged: (showAgain) => showAgain
                      ? cubit.replayOnboarding()
                      : cubit.completeOnboarding(),
                  activeThumbColor: AppColors.primary,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Your settings are saved on this device and restored the next '
                'time you open Houseslice.',
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;

  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 6),
      child: Text(
        text.toUpperCase(),
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          fontWeight: FontWeight.w800,
          letterSpacing: 0.8,
          color: AppColors.primary,
        ),
      ),
    );
  }
}

/// Three-way theme switch. [SegmentedButton] keeps the whole control on one
/// row at small widths while still meeting the 48dp tap target.
class _ThemeSelector extends StatelessWidget {
  final AppThemeMode selected;
  final ValueChanged<AppThemeMode> onChanged;

  const _ThemeSelector({required this.selected, required this.onChanged});

  static const _labels = {
    AppThemeMode.system: ('System', Icons.brightness_auto_outlined),
    AppThemeMode.light: ('Light', Icons.light_mode_outlined),
    AppThemeMode.dark: ('Dark', Icons.dark_mode_outlined),
  };

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: SegmentedButton<AppThemeMode>(
        segments: [
          for (final entry in _labels.entries)
            ButtonSegment(
              value: entry.key,
              label: Text(entry.value.$1),
              icon: Icon(entry.value.$2),
            ),
        ],
        selected: {selected},
        showSelectedIcon: false,
        onSelectionChanged: (selection) => onChanged(selection.first),
      ),
    );
  }
}
