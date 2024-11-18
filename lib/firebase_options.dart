// firebase_options.dart
import 'package:firebase_core/firebase_core.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    return const FirebaseOptions(
      apiKey: "AIzaSyCwVB8MQKaDgblUt_Ageoqs-1hHVxP4KQA",
          authDomain: "marketplace-flutter-b74b7.firebaseapp.com",
          databaseURL: "https://marketplace-flutter-b74b7-default-rtdb.firebaseio.com",
          projectId: "marketplace-flutter-b74b7",
          storageBucket: "marketplace-flutter-b74b7.appspot.com",
          messagingSenderId: "217118730456",
          appId: "1:217118730456:web:8e4309b0ff4125c2d8cfad",
    );
  }
}
