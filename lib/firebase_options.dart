import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for android - '
          'you can configure this inside Firebase Console.',
        );
      case TargetPlatform.iOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for ios - '
          'you can configure this inside Firebase Console.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCgrhrK4TgqBG6Rxt6KxNjrN4f4GgxltdM',
    appId: '1:813589345128:web:d29703026b173c430d9cdd',
    messagingSenderId: '813589345128',
    projectId: 'torneo-lozzo-2026',
    authDomain: 'torneo-lozzo-2026.firebaseapp.com',
    storageBucket: 'torneo-lozzo-2026.firebasestorage.app',
    measurementId: 'G-8DRJR0X9ZN',
  );
}
