
/// Price data point for market price history
class PriceData {
  final DateTime timestamp;
  final double price;

  PriceData(this.timestamp, this.price);
}

/// Market location data for map displays
class MarketLocation {
  final String name;
  final String product;
  final double price;
  final double latitude;
  final double longitude;
  final String address;
  final String contact;
  final bool verified;
  final String region;

  MarketLocation({
    required this.name,
    required this.product,
    required this.price,
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.contact,
    required this.verified,
    this.region = '',
  });
}
