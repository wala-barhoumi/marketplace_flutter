
import 'package:app/screens/home_screen.dart';
import 'package:app/screens/login_screen.dart';
import 'package:app/screens/signup_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

void main() async {void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    if (kIsWeb) {
      // Firebase initialization for web
      await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: "AIzaSyCwVB8MQKaDgblUt_Ageoqs-1hHVxP4KQA",
          authDomain: "marketplace-flutter-b74b7.firebaseapp.com",
          databaseURL: "https://marketplace-flutter-b74b7-default-rtdb.firebaseio.com",
          projectId: "marketplace-flutter-b74b7",
          storageBucket: "marketplace-flutter-b74b7.appspot.com",
          messagingSenderId: "217118730456",
          appId: "1:217118730456:web:8e4309b0ff4125c2d8cfad",
        ),
      );
      debugPrint('Firebase initialized for web');
    } else {
      // Firebase initialization for mobile
      await Firebase.initializeApp();
      debugPrint('Firebase initialized for mobile');
    }
    runApp(const MyApp());
    debugPrint('App started');
  } catch (e) {
    // Log or handle initialization error
    debugPrint('Firebase initialization failed: $e');
  }
}
  WidgetsFlutterBinding.ensureInitialized();

  try {
    if (kIsWeb) {
      // Firebase initialization for web
      await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: "AIzaSyCwVB8MQKaDgblUt_Ageoqs-1hHVxP4KQA",
          authDomain: "marketplace-flutter-b74b7.firebaseapp.com",
          databaseURL: "https://marketplace-flutter-b74b7-default-rtdb.firebaseio.com",
          projectId: "marketplace-flutter-b74b7",
          storageBucket: "marketplace-flutter-b74b7.appspot.com",
          messagingSenderId: "217118730456",
          appId: "1:217118730456:web:8e4309b0ff4125c2d8cfad",
        ),
      );
    } else {
      // Firebase initialization for mobile
      await Firebase.initializeApp();
    }
    runApp(const MyApp());
  } catch (e) {
    // Log or handle initialization error
    debugPrint('Firebase initialization failed: $e');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {

    
    return MaterialApp(
      title: 'Marketplace App',
      theme: ThemeData(
        primarySwatch: Colors.purple,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
        '/home':(context)=>const HomeScreen(),
      },
    );
  }
}
//wala&@gmail.com