// Fix for the Google Maps "maps is undefined" error
// This provides a WebContainer component that helps detect and recover from map load errors

import 'package:flutter/material.dart';

// This class creates a container that helps with map errors in web
class WebMapContainer extends StatefulWidget {
  final Widget mapWidget;
  final Function onError;
  final double height;
  final double width;
  
  const WebMapContainer({
    Key? key,
    required this.mapWidget,
    required this.onError,
    this.height = double.infinity,
    this.width = double.infinity,
  }) : super(key: key);
  
  @override
  State<WebMapContainer> createState() => _WebMapContainerState();
}

class _WebMapContainerState extends State<WebMapContainer> {
  bool _hasError = false;
  
  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            const Text(
              'Google Maps could not be loaded',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('Please check your internet connection and try again'),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2B5320),
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                setState(() => _hasError = false);
              },
              child: const Text('Try Again'),
            ),
          ],
        ),
      );
    }
    
    return SizedBox(
      height: widget.height,
      width: widget.width,
      child: ErrorHandler(
        child: widget.mapWidget,
        onError: (error) {
          setState(() => _hasError = true);
          widget.onError(error);
        },
      ),
    );
  }
}

class ErrorHandler extends StatefulWidget {
  final Widget child;
  final Function(dynamic) onError;
  
  const ErrorHandler({
    Key? key, 
    required this.child,
    required this.onError,
  }) : super(key: key);
  
  @override
  State<ErrorHandler> createState() => _ErrorHandlerState();
}

class _ErrorHandlerState extends State<ErrorHandler> {
  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
  
  @override
  void initState() {
    super.initState();
    
    // Store the original error handler so we can restore it
    final originalOnError = FlutterError.onError;
    
    // We catch errors at runtime using Flutter's error handling
    FlutterError.onError = (FlutterErrorDetails details) {
      final error = details.exception.toString();
      if (error.contains('maps') || error.contains('google')) {
        widget.onError(details.exception);
      } else {
        // Forward to Flutter's default error handler
        if (originalOnError != null) {
          originalOnError(details);
        } else {
          FlutterError.presentError(details);
        }
      }
    };
  }
  
  @override
  void dispose() {
    // Reset FlutterError.onError to avoid issues when navigating away
    // This prevents our handler from being called after this widget is disposed
    FlutterError.onError = null;
    super.dispose();
  }
}
