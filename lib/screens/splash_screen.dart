import 'package:flutter/material.dart';
import 'onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Navigate to onboarding screen after 3 seconds
    _navigateToOnboarding();
  }

  Future<void> _navigateToOnboarding() async {
    await Future.delayed(const Duration(seconds: 3));
    
    // Check if the widget is still mounted before using context
    if (!mounted) return;
    
    if (context.mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const OnboardingScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2B5320), // Dark green background
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo icon
            Container(
              margin: const EdgeInsets.only(bottom: 20),
              child: Icon(
                Icons.eco, // Using a plant icon as placeholder
                size: 80,
                color: Colors.yellow[300],
              ),
            ),
            // AgriMatrix text
            const Text(
              'AgriMatrix',
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 1.2,
              ),
            ),
            // Tagline
            const Text(
              'Empowering Farmers',
              style: TextStyle(
                fontSize: 18,
                color: Colors.white70,
                letterSpacing: 0.5,
              ),
            ),
            // Loading indicator
            const SizedBox(height: 40),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}