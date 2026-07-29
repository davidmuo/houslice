import 'package:equatable/equatable.dart';

/// How the app chooses its colour scheme.
enum AppThemeMode { system, light, dark }

/// User preferences persisted on-device and restored on relaunch.
///
/// Four settings are stored: colour theme, notification opt-in, the preferred
/// Kigali district used to pre-filter listings, and whether onboarding has
/// already been seen (so returning users skip straight to sign-in).
class AppPreferences extends Equatable {
  final AppThemeMode themeMode;
  final bool notificationsEnabled;
  final String preferredCity;
  final bool onboardingComplete;

  const AppPreferences({
    // Light by default, deliberately not `system`. The Figma design is a light
    // theme, so following the device would render the whole app dark for any
    // student whose phone is in dark mode — which is not what the design says.
    // Dark stays available as an explicit opt-in in Settings.
    this.themeMode = AppThemeMode.light,
    this.notificationsEnabled = true,
    this.preferredCity = defaultCity,
    this.onboardingComplete = false,
  });

  /// Districts a student can pick from — matches the Figma location chooser.
  static const cities = <String>['Gasabo', 'Kicukiro', 'Nyarugenge'];
  static const defaultCity = 'Gasabo';

  /// Values used on a first launch, before anything has been written.
  static const defaults = AppPreferences();

  AppPreferences copyWith({
    AppThemeMode? themeMode,
    bool? notificationsEnabled,
    String? preferredCity,
    bool? onboardingComplete,
  }) {
    return AppPreferences(
      themeMode: themeMode ?? this.themeMode,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      preferredCity: preferredCity ?? this.preferredCity,
      onboardingComplete: onboardingComplete ?? this.onboardingComplete,
    );
  }

  @override
  List<Object?> get props => [
    themeMode,
    notificationsEnabled,
    preferredCity,
    onboardingComplete,
  ];
}
