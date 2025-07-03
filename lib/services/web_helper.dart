// This file is used to ensure we can import dart:html only on web platforms
// without causing errors on mobile platforms
import 'package:flutter/foundation.dart' show kIsWeb;

// Empty stub for non-web platforms
bool isGoogleMapsLoaded() {
  return false;
}

void initializeGoogleMapsWebHelper() {
  // Empty stub for non-web platforms
}

// Check if we're running on web platform
bool isWebPlatform() {
  return kIsWeb;
}

// Check if a service should be initialized based on platform constraints
bool shouldInitializeService(String serviceName) {
  // On mobile platforms, initialize all services
  if (!kIsWeb) {
    return true;
  }
  
  // On web, be selective about which services to initialize
  switch (serviceName.toLowerCase()) {
    case 'webrtc':
    case 'rtc':
    case 'communication':
      // These services can cause issues on web, so consider disabling them
      return false;
    case 'maps':
    case 'google_maps':
      // Maps should be initialized on web but with special handling
      return true;
    default:
      // By default, initialize services on web
      return true;
  }
}
