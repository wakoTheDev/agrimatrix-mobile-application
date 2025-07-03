import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../services/map_service_new.dart';
import '../services/logging_service.dart';
import '../widgets/web_map_container.dart';

class MarketMapScreen extends StatefulWidget {
  final String searchQuery;
  final String selectedRegion;
  
  const MarketMapScreen({
    super.key, 
    required this.searchQuery, 
    required this.selectedRegion,
  });

  @override
  State<MarketMapScreen> createState() => _MarketMapScreenState();
}

class _MarketMapScreenState extends State<MarketMapScreen> {
  final MapService _mapService = MapService();
  bool _isLoading = true;
  Widget? _mapWidget;
  String? _errorMessage;
  
  @override
  void initState() {
    super.initState();
    _initializeMap();
  }
  
  Future<void> _initializeMap() async {
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      // For web platforms, we need to ensure Google Maps is loaded properly
      if (kIsWeb) {
        // A longer delay for web to ensure maps API is fully loaded
        await Future.delayed(const Duration(seconds: 3));
      }
      
      // Initialize the map service
      await _mapService.initialize();
      
      // Another small delay for web after initialization
      if (kIsWeb) {
        await Future.delayed(const Duration(seconds: 1));
      }
      
      // Build the map widget
      final mapWidget = _mapService.buildMapWidget(
        initialLat: -1.2921, // Nairobi coordinates
        initialLng: 36.8219,
        onTap: (lat, lng) {
          debugPrint('Map tapped at: $lat, $lng');
        },
        onMarkersChanged: (markers) {
          debugPrint('Markers updated: ${markers.length}');
        },
      );
      
      // Update the state with the map widget
      if (mounted) {
        setState(() {
          _mapWidget = mapWidget;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (kDebugMode) {
        LoggingService.error('Error initializing map', e);
      }
      if (mounted) {
        _handleMapError(e.toString());
      }
    }
  }
  
  void _handleMapError(String error) {
    if (!mounted) return;
    
    setState(() {
      _isLoading = false;
      
      // Provide more specific error messages based on the error
      if (error.toLowerCase().contains('maps') || 
          error.toLowerCase().contains('google') || 
          error.toLowerCase().contains('javascript') ||
          error.toLowerCase().contains('api')) {
        
        _errorMessage = kIsWeb
            ? 'Google Maps could not be initialized. Please check your internet connection and ensure your browser allows third-party cookies.'
            : 'Google Maps could not be initialized. Please ensure you have a valid API key and a proper internet connection.';
        
        // Add additional debugging info
        if (kDebugMode) {
          LoggingService.error('Map initialization error: $error');
        }
        if (kDebugMode) {
          LoggingService.debug('Platform is web: $kIsWeb');
        }
        
      } else if (error.toLowerCase().contains('permission')) {
        _errorMessage = 'Location permission denied. Please allow location access to view nearby markets.';
      } else if (error.toLowerCase().contains('location')) {
        _errorMessage = 'Unable to get your location. Please enable location services.';
      } else {
        _errorMessage = 'Failed to load map: $error';
      }
    });
    
    // Show error in the UI
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_errorMessage ?? 'Map error'),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 8),
        action: SnackBarAction(
          label: 'Retry',
          textColor: Colors.white,
          onPressed: _initializeMap,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.searchQuery.isNotEmpty 
              ? 'Markets for "${widget.searchQuery}"' 
              : 'All Markets',
        ),
        backgroundColor: const Color(0xFF2B5320),
        foregroundColor: Colors.white,
        actions: [
          if (widget.selectedRegion != 'All')
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Chip(
                label: Text(
                  widget.selectedRegion,
                  style: const TextStyle(color: Colors.white),
                ),
                backgroundColor: Colors.green[700],
              ),
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _initializeMap,
            tooltip: 'Refresh markets',
          ),
        ],
      ),
      body: Stack(
        children: [
          // Map or error/loading state
          _isLoading 
              ? const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(color: Color(0xFF2B5320)),
                      SizedBox(height: 16),
                      Text('Loading market map...', style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                )
              : _errorMessage != null || _mapWidget == null
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.map, size: 64, color: Colors.grey),
                          const SizedBox(height: 16),
                          const Text(
                            'Could not load the map',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(_errorMessage ?? 'Please check your internet connection'),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2B5320),
                              foregroundColor: Colors.white,
                            ),
                            onPressed: _initializeMap,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Try Again'),
                          ),
                        ],
                      ),
                    )
                  : kIsWeb
                      ? WebMapContainer(
                          mapWidget: _mapWidget!,
                          height: MediaQuery.of(context).size.height,
                          width: MediaQuery.of(context).size.width,
                          onError: (error) {
                            _handleMapError('Web map error: $error');
                          },
                        )
                      : SizedBox(
                          height: MediaQuery.of(context).size.height,
                          width: MediaQuery.of(context).size.width,
                          child: _mapWidget!,
                        ),
                
          // Search overlay
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    const Icon(Icons.search, color: Color(0xFF2B5320)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        widget.searchQuery.isEmpty
                            ? 'Showing all markets'
                            : 'Markets for "${widget.searchQuery}"',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Map legend
          Positioned(
            bottom: 24,
            right: 16,
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildLegendItem(Colors.green, 'Verified Market'),
                    const SizedBox(height: 4),
                    _buildLegendItem(Colors.orange, 'Unverified Market'),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildLegendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(label),
      ],
    );
  }
}
