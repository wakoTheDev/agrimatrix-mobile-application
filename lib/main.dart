import 'package:agrimatrix/firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'screens/splash_screen.dart';
import 'screens/sign_in_screen.dart';
import 'widgets/communication_wrapper.dart';
import 'services/logging_service.dart';

void main() async {
  // Initialize Flutter binding
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase with proper error handling
  bool firebaseInitialized = false;
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    LoggingService.info('Firebase initialized successfully', 'Main');
    
    // Verify Firebase Auth is working
    final auth = FirebaseAuth.instance;
    LoggingService.debug('Firebase Auth instance created: ${auth.toString()}', 'Main');
    
    // Test if we can access Firebase Auth features
    final apps = Firebase.apps;
    LoggingService.info('Registered Firebase apps: ${apps.length}', 'Main');
    
    firebaseInitialized = true;
  } catch (e, stackTrace) {
    LoggingService.error('Error initializing Firebase', e, stackTrace, 'Main');
    LoggingService.warning('Continuing without Firebase features', 'Main');
    // Continue with app initialization even if Firebase fails
  }
  
  // Run the app after initialization attempts
  runApp(MyApp(firebaseInitialized: firebaseInitialized));
}

class MyApp extends StatelessWidget {
  final bool firebaseInitialized;
  
  const MyApp({super.key, required this.firebaseInitialized});

  @override
  Widget build(BuildContext context) {    
    return CommunicationWrapper(
      child: MaterialApp(
        title: 'AgriMatrix',
        theme: ThemeData(
          primaryColor: const Color(0xFF2B5320),
          useMaterial3: true,
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => SplashScreen(firebaseInitialized: firebaseInitialized),
          '/signin': (context) => const SignInScreen(),
        },
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}