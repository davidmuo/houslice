import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'app.dart';
import 'features/lifestyle/presentation/cubit/lifestyle_cubit.dart';
import 'features/settings/presentation/cubit/preferences_cubit.dart';
import 'firebase_options.dart';
import 'injection_container.dart' as di;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Try to boot Firebase. If firebase_options.dart is still the placeholder
  // (flutterfire configure not run yet), fall back to demo mode with
  // in-memory data so the app stays fully functional.
  var firebaseReady = false;
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    firebaseReady = true;
  } catch (e) {
    debugPrint('Firebase unavailable, starting in demo mode: $e');
  }

  await di.init(useFirebase: firebaseReady);

  // Read saved preferences before the first frame so the app opens directly
  // in the user's chosen theme instead of flashing the default one.
  await di.sl<PreferencesCubit>().load();
  await di.sl<LifestyleCubit>().load();

  runApp(const HousliceApp());
}
