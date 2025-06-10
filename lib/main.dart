import 'package:agrimatrix/firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'screens/splash_screen.dart';
import 'screens/sign_in_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint('Firebase initialized successfully');
    
    // Verify Firebase Auth is working
    final auth = FirebaseAuth.instance;
    debugPrint('Firebase Auth instance created: ${auth.toString()}');
    
    // Test if we can access Firebase Auth features
    final apps = Firebase.apps;
    debugPrint('Registered Firebase apps: ${apps.length}');
    
  } catch (e, stackTrace) {
    debugPrint('Error initializing Firebase: $e');
    debugPrint('Stack trace: $stackTrace');
  }
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {    return MaterialApp(
      title: 'AgriMatrix',
      theme: ThemeData(
        primaryColor: const Color(0xFF2B5320),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/signin': (context) => const SignInScreen(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}