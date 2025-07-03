import 'package:flutter/material.dart';
import 'onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  final bool firebaseInitialized;
  
  const SplashScreen({
    super.key,
    required this.firebaseInitialized,
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _isLoading = true;
  String _loadingMessage = "Loading resources...";
  bool _showRetryButton = false;
  
  @override
  void initState() {
    super.initState();
    
    // Show longer loading status for web or if Firebase failed to initialize
    if (!widget.firebaseInitialized) {
      _loadingMessage = "Loading resources (offline mode)...";
      debugPrint('SplashScreen started in offline mode due to Firebase initialization failure');
    }
    
    // Navigate to onboarding screen after appropriate delay
    _navigateToOnboarding();
  }

  Future<void> _navigateToOnboarding() async {
    try {
      // Longer delay if Firebase failed to initialize to give more time
      final delay = !widget.firebaseInitialized ? 5 : 3;
      await Future.delayed(Duration(seconds: delay));
      
      // Check if the widget is still mounted before using context
      if (!mounted) return;
      
      setState(() {
        _isLoading = false;
      });
      
      if (context.mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const OnboardingScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _loadingMessage = "Error loading application: $e";
          _showRetryButton = true;
        });
        debugPrint('Error in _navigateToOnboarding: $e');
      }
    }
  }
  
  void _retryLoading() {
    setState(() {
      _isLoading = true;
      _loadingMessage = "Retrying...";
      _showRetryButton = false;
    });
    _navigateToOnboarding();
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
            const SizedBox(height: 24),
            // Loading indicator
            if (_isLoading)
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            const SizedBox(height: 20),
            // Loading message
            Text(
              _loadingMessage,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            // Retry button for error recovery
            if (_showRetryButton)
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: ElevatedButton(
                  onPressed: _retryLoading,
                  child: const Text('Retry'),
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