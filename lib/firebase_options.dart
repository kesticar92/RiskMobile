// Firebase configuration for project: riskmobile-c59fc
// Platforms: Android, iOS, Web

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCzhFsk4-Z7CXwJrhSfJsFMvTbGG41SDVE',
    appId: '1:501384127347:android:9d9bb6fd14b542244e9b06',
    messagingSenderId: '501384127347',
    projectId: 'riskmobile-c59fc',
    storageBucket: 'riskmobile-c59fc.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyD-kG7DX_qhac3BrDWDpV_VPQtQq-3IcbU',
    appId: '1:501384127347:ios:17ed50c85a85273f4e9b06',
    messagingSenderId: '501384127347',
    projectId: 'riskmobile-c59fc',
    storageBucket: 'riskmobile-c59fc.firebasestorage.app',
    iosBundleId: 'com.riskmobile.app',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAstaFax71sjPYMxQnPF6INHyRlS2WdBB8',
    appId: '1:501384127347:web:dcfb3cfca181fd374e9b06',
    messagingSenderId: '501384127347',
    projectId: 'riskmobile-c59fc',
    storageBucket: 'riskmobile-c59fc.firebasestorage.app',
    authDomain: 'riskmobile-c59fc.firebaseapp.com',
  );
}
