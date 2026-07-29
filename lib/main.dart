import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'app.dart';
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
  runApp(const HousliceApp());
}
