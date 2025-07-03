// This script ensures that Google Maps is properly initialized
// before Flutter web attempts to use it

// Check if the google object exists
if (typeof window.google === 'undefined') {
  window.google = {};
}

// This function will be called by the Flutter app to check if maps is ready
window.isGoogleMapsInitialized = function() {
  return window.google && window.google.maps;
};

// Display error if Google Maps fails to load
window.addEventListener('error', function(e) {
  if (e.message.includes('google is not defined') || e.message.includes('maps is not defined')) {
    console.error('Google Maps failed to load. Please check your API key.');
    // Could show a user-friendly error message here
  }
});
