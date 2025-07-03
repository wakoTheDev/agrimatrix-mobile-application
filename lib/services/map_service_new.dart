import 'dart:async';
import 'package:flutter/material.dart';
import '../models/app_models.dart';
import '../services/web_helper.dart' as web;

// Lightweight map service placeholder for when Google Maps dependencies are not available
class MapService {
  static final MapService _instance = MapService._internal();
  factory MapService() => _instance;
  MapService._internal();

  // Mock location data for Kenya center (Nairobi)
  static const double _kenyaLat = -1.2921;
  static const double _kenyaLng = 36.8219;

  final StreamController<List<MarketLocation>> _markersController =
      StreamController<List<MarketLocation>>.broadcast();

  Stream<List<MarketLocation>> get markersStream => _markersController.stream;

  List<MarketLocation> _currentMarkers = [];
  bool _isInitialized = false;

  /// Initialize the map service
  Future<bool> initialize() async {
    if (!web.shouldInitializeService('maps')) {
      debugPrint('Map service initialization skipped (dependencies not available)');
      return false;
    }

    _isInitialized = true;
    return true;
  }

  /// Get current location (mock implementation)
  Future<Map<String, double>?> getCurrentLocation() async {
    if (!_isInitialized) {
      debugPrint('Map service not initialized');
      return null;
    }

    // Return mock location (Nairobi, Kenya)
    return {
      'latitude': _kenyaLat,
      'longitude': _kenyaLng,
    };
  }

  /// Check location permission (mock implementation)
  Future<bool> checkLocationPermission() async {
    // For this lightweight version, always return true
    return true;
  }

  /// Request location permission (mock implementation)
  Future<bool> requestLocationPermission() async {
    // For this lightweight version, always return true
    return true;
  }

  /// Add market locations to map
  void addMarketLocations(List<MarketLocation> locations) {
    _currentMarkers = locations;
    _markersController.add(_currentMarkers);
  }

  /// Update market locations
  void updateMarketLocations(List<MarketLocation> locations) {
    addMarketLocations(locations);
  }

  /// Clear all markers
  void clearMarkers() {
    _currentMarkers.clear();
    _markersController.add(_currentMarkers);
  }

  /// Get markers within radius (mock implementation)
  List<MarketLocation> getMarkersWithinRadius(
    double centerLat,
    double centerLng,
    double radiusKm,
  ) {
    return _currentMarkers.where((marker) {
      // Simple distance calculation (not accurate, but sufficient for mock)
      final latDiff = (marker.latitude - centerLat).abs();
      final lngDiff = (marker.longitude - centerLng).abs();
      final distance = (latDiff + lngDiff) * 111; // Rough km conversion
      return distance <= radiusKm;
    }).toList();
  }

  /// Build a placeholder map widget
  Widget buildMapWidget({
    double? initialLat,
    double? initialLng,
    Function(double lat, double lng)? onTap,
    Function(List<MarketLocation>)? onMarkersChanged,
  }) {
    return Container(
      height: 300,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.map,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Interactive Map',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Google Maps integration available\nwhen dependencies are installed',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 16),
          if (_currentMarkers.isNotEmpty)
            Text(
              '${_currentMarkers.length} market locations available',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
        ],
      ),
    );
  }

  /// Calculate distance between two points (mock implementation)
  double calculateDistance(
    double lat1,
    double lng1,
    double lat2,
    double lng2,
  ) {
    // Simple distance calculation (not accurate, but sufficient for mock)
    final latDiff = (lat2 - lat1).abs();
    final lngDiff = (lng2 - lng1).abs();
    return (latDiff + lngDiff) * 111; // Rough km conversion
  }

  /// Filter markers by product type
  void filterMarkersByProduct(String productType) {
    final filteredMarkers = _currentMarkers
        .where((marker) => marker.product.toLowerCase().contains(productType.toLowerCase()))
        .toList();
    _markersController.add(filteredMarkers);
  }

  /// Filter markers by price range
  void filterMarkersByPriceRange(double minPrice, double maxPrice) {
    final filteredMarkers = _currentMarkers
        .where((marker) => marker.price >= minPrice && marker.price <= maxPrice)
        .toList();
    _markersController.add(filteredMarkers);
  }

  /// Search markers by location name
  void searchMarkersByLocation(String searchTerm) {
    final filteredMarkers = _currentMarkers
        .where((marker) => 
            marker.name.toLowerCase().contains(searchTerm.toLowerCase()) ||
            marker.address.toLowerCase().contains(searchTerm.toLowerCase()))
        .toList();
    _markersController.add(filteredMarkers);
  }

  /// Reset all filters
  void resetFilters() {
    _markersController.add(_currentMarkers);
  }

  /// Get current markers
  List<MarketLocation> get currentMarkers => _currentMarkers;

  /// Dispose resources
  void dispose() {
    _markersController.close();
  }
}
