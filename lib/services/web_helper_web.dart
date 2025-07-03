// This file contains web-specific code for Google Maps
import 'dart:js' as js;
// Keep html import commented but available if needed later
// import 'dart:html' as html;

// Check if Google Maps is loaded in the browser
bool isGoogleMapsLoaded() {
  try {
    // Check if 'google' exists in the window object
    final hasGoogle = js.context.hasProperty('google');
    // Check if 'maps' exists in the google object
    final hasMaps = hasGoogle && js.context['google'] != null && js.context['google'].hasProperty('maps');
    return hasGoogle && hasMaps;
  } catch (e) {
    print('Error checking Google Maps status: $e');
    return false;
  }
}

// Initialize the web helper for Google Maps
void initializeGoogleMapsWebHelper() {
  try {
    // Check if flutter_google_maps_webhelper exists in the window context
    if (js.context.hasProperty('flutter_google_maps_webhelper')) {
      // Call the loadGoogleMaps method
      js.context['flutter_google_maps_webhelper'].callMethod('loadGoogleMaps');
    } else {
      print('flutter_google_maps_webhelper not available in window context');
    }
  } catch (e) {
    print('Error initializing Google Maps for web: $e');
  }
}
