import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;

/// PLACEHOLDER — replace by running the FlutterFire CLI:
///
/// ```sh
/// dart pub global activate flutterfire_cli
/// flutterfire configure
/// ```
///
/// That command regenerates this file with your real Firebase project keys.
/// Until then [currentPlatform] throws, which `main()` catches to start the
/// app in demo mode (in-memory data, no Firebase required).
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    throw UnsupportedError(
      'Firebase has not been configured yet. Run "flutterfire configure" '
      'to generate lib/firebase_options.dart for your Firebase project.',
    );
  }
}
