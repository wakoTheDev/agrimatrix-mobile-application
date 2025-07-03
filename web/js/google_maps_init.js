// Google Maps initialization helper for Flutter web apps

// Track Google Maps loading state
window.googleMapsInitialized = false;
window.googleMapsLoadingStarted = false;
window.googleMapsLoadFailed = false;

// Define the initialization callback function that the Google Maps script will call
function initGoogleMapsCallback() {
  console.log('Google Maps API loaded successfully!');
  window.googleMapsInitialized = true;
  window.googleMapsLoadFailed = false;
  
  // Make sure the flutter_google_maps_webhelper object exists
  if (!window.flutter_google_maps_webhelper) {
    window.flutter_google_maps_webhelper = {};
  }
  
  window.flutter_google_maps_webhelper.isInitialized = true;
  
  // Dispatch a custom event that Flutter can listen for
  const event = new CustomEvent('google_maps_initialized');
  window.dispatchEvent(event);
  
  // Update any pending maps
  if (window.flutter_google_maps_webhelper.notifyMapContainers) {
    window.flutter_google_maps_webhelper.notifyMapContainers();
  }
}

// Detect if the Google Maps JavaScript API fails to load
window.addEventListener('error', function(e) {
  const errorMessage = e.message || '';
  
  // Check if this is a Google Maps related error
  if (
    errorMessage.includes('google is not defined') || 
    errorMessage.includes('maps is not defined') || 
    errorMessage.includes('MapsNetworkError') ||
    errorMessage.includes('google.maps') ||
    errorMessage.includes('Cannot read properties of undefined')
  ) {
    console.error('Google Maps Error:', errorMessage);
    window.googleMapsLoadFailed = true;
    
    document.dispatchEvent(new CustomEvent('FLUTTER_GOOGLE_MAPS_ERROR', {
      detail: {
        message: errorMessage
      }
    }));
    
    // If we have a list of map containers waiting for initialization, notify them of the error
    if (window.flutter_google_maps_webhelper && window.flutter_google_maps_webhelper.notifyMapError) {
      window.flutter_google_maps_webhelper.notifyMapError(errorMessage);
    }
    
    // Try to reload the maps if this was the first error
    if (!window.googleMapsReloadAttempted) {
      window.googleMapsReloadAttempted = true;
      console.log('Attempting to reload Google Maps...');
      
      // Wait a moment before trying again
      setTimeout(() => {
        if (window.flutter_google_maps_webhelper) {
          window.flutter_google_maps_webhelper.loadGoogleMaps();
        }
      }, 2000);
    }
    
    // Prevent the error from propagating
    e.preventDefault();
  }
});

// Initialize helper object for Flutter to communicate with
window.flutter_google_maps_webhelper = {
  isInitialized: false,
  mapContainers: [],
  
  isReady: function() {
    return window.google && window.google.maps;
  },
  
  loadGoogleMaps: function() {
    // Allow reloading if there was a failure
    if (window.googleMapsLoadingStarted && !window.googleMapsLoadFailed) {
      console.log('Google Maps loading already in progress, not starting again');
      return;
    }
    
    window.googleMapsLoadingStarted = true;
    
    // Reset error state if retrying
    window.googleMapsLoadFailed = false;
    
    // Track loading in the agrimatrix global object if available
    if (window.agrimatrix) {
      window.agrimatrix.mapsLoadingAttempts++;
    }
    
    // Remove any existing Google Maps script elements to prevent conflicts
    const existingScripts = document.querySelectorAll('script[src*="maps.googleapis.com/maps/api/js"]');
    existingScripts.forEach(script => script.remove());
    
    console.log('Dynamically loading Google Maps API script... (attempt ' + 
                (window.agrimatrix ? window.agrimatrix.mapsLoadingAttempts : '?') + ')');
    const script = document.createElement('script');
    script.src = 'https://maps.googleapis.com/maps/api/js?key=AIzaSyBGX-3ld9pjsJ_jxp8Lk_-_VsIEAc2j0zs&libraries=places&callback=initGoogleMapsCallback';
    script.async = true;
    script.defer = true;
    
    // Add error handling directly on the script tag
    script.onerror = function(error) {
      console.error('Error loading Google Maps script:', error);
      window.googleMapsLoadFailed = true;
      window.flutter_google_maps_webhelper.notifyMapError('Failed to load Google Maps script');
    };
    
    // Add timeout to detect if the script takes too long to load
    const timeoutId = setTimeout(function() {
      if (!window.googleMapsInitialized) {
        console.error('Google Maps script loading timeout');
        window.googleMapsLoadFailed = true;
        window.flutter_google_maps_webhelper.notifyMapError('Timeout loading Google Maps');
        
        // Try auto-recovery
        if (window.agrimatrix && typeof window.agrimatrix.retryMapsLoad === 'function') {
          if (window.agrimatrix.mapsLoadingAttempts < window.agrimatrix.maxRetryAttempts) {
            console.log('Auto-recovery: attempting to reload Google Maps');
            setTimeout(() => {
              window.agrimatrix.retryMapsLoad();
            }, 2000); // Wait 2 seconds before retrying
          }
        }
      }
    }, 10000); // 10 second timeout
    
    document.head.appendChild(script);
  },
  
  // Register a map container to be notified of initialization or errors
  registerMapContainer: function(id) {
    if (!this.mapContainers.includes(id)) {
      this.mapContainers.push(id);
    }
  },
  
  // Notify all registered map containers of initialization
  notifyMapContainers: function() {
    console.log('Notifying map containers that Google Maps is ready');
    // Custom event would be handled by Flutter web platform views
  },
  
  // Notify all registered map containers of an error
  notifyMapError: function(errorMessage) {
    console.log('Notifying map containers of Google Maps error:', errorMessage);
    // Custom event would be handled by Flutter web platform views
  }
};
