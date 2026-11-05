import 'package:firebase_core/firebase_core.dart';

// Placeholder for the local emulators until `flutterfire configure` replaces
// this file with the real project's config.
abstract final class DefaultFirebaseOptions {
  static const currentPlatform = FirebaseOptions(
    apiKey: 'AIzaSyDemoKeyForLocalEmulatorsOnly00000',
    appId: '1:000000000000:ios:0000000000000000000000',
    messagingSenderId: '000000000000',
    projectId: 'demo-bugbounty',
    storageBucket: 'demo-bugbounty.appspot.com',
    iosBundleId: 'com.alu.aluBugBounty',
  );
}
