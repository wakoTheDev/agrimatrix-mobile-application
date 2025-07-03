import 'package:flutter/material.dart';
import '../models/market_models.dart';

/// Lightweight chart service providing placeholder charts for production
/// This version uses Flutter's built-in widgets instead of external chart libraries
class ChartService {
  static const Color primaryColor = Color(0xFF2B5320);
  static const Color accentColor = Color(0xFF4CAF50);

  /// Create a simple line chart representation using containers and custom paint
  static Widget buildPriceChart({
    required List<PriceData> data,
    String title = 'Price Chart',
  }) {
    if (data.isEmpty) {
      return Container(
        height: 300,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Center(
          child: Text(
            'No price data available',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    return Container(
      height: 300,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: CustomPaint(
                painter: SimplePriceChartPainter(data),
                size: const Size(double.infinity, double.infinity),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Data points: ${data.length}',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
              if (data.isNotEmpty)
                Text(
                  'Latest: \$${data.last.price.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 12, color: primaryColor),
                ),
            ],
          ),
        ],
      ),
    );
  }

  /// Create a simple bar chart representation
  static Widget buildVolumeChart({
    required Map<int, PriceData> data,
    String title = 'Volume Chart',
  }) {
    if (data.isEmpty) {
      return Container(
        height: 300,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Center(
          child: Text(
            'No volume data available',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    return Container(
      height: 300,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: CustomPaint(
                painter: SimpleVolumeChartPainter(data.values.toList()),
                size: const Size(double.infinity, double.infinity),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Volume entries: ${data.length}',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  /// Create a simple comparison chart
  static Widget buildComparisonChart({
    required Map<int, PriceData> currentData,
    required Map<int, PriceData> previousData,
    String title = 'Comparison Chart',
  }) {
    if (currentData.isEmpty && previousData.isEmpty) {
      return Container(
        height: 300,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Center(
          child: Text(
            'No comparison data available',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    return Container(
      height: 300,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: const BoxDecoration(
                  color: primaryColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 4),
              const Text('Current', style: TextStyle(fontSize: 12)),
              const SizedBox(width: 16),
              Container(
                width: 12,
                height: 12,
                decoration: const BoxDecoration(
                  color: accentColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 4),
              const Text('Previous', style: TextStyle(fontSize: 12)),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: CustomPaint(
                painter: SimpleComparisonChartPainter(currentData, previousData),
                size: const Size(double.infinity, double.infinity),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Current: ${currentData.length} | Previous: ${previousData.length}',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  // Legacy method names for backwards compatibility
  static Widget createPriceChart(List<PriceData> data) {
    return buildPriceChart(data: data);
  }

  static Widget createVolumeChart(Map<int, PriceData> data) {
    return buildVolumeChart(data: data);
  }
}

/// Custom painter for simple price chart
class SimplePriceChartPainter extends CustomPainter {
  final List<PriceData> data;

  SimplePriceChartPainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final paint = Paint()
      ..color = ChartService.primaryColor
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final pointPaint = Paint()
      ..color = ChartService.primaryColor
      ..style = PaintingStyle.fill;

    final gridPaint = Paint()
      ..color = Colors.grey.shade300
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    // Draw grid lines
    for (int i = 1; i < 4; i++) {
      final y = (i / 4) * size.height;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    for (int i = 1; i < 6; i++) {
      final x = (i / 6) * size.width;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }

    // Calculate the range and scale
    final minPrice = data.map((e) => e.price).reduce((a, b) => a < b ? a : b);
    final maxPrice = data.map((e) => e.price).reduce((a, b) => a > b ? a : b);
    final priceRange = maxPrice - minPrice;

    if (priceRange == 0) return;

    final path = Path();
    final points = <Offset>[];

    for (int i = 0; i < data.length; i++) {
      final x = (i / (data.length - 1)) * size.width;
      final y = size.height - ((data[i].price - minPrice) / priceRange) * size.height;
      
      final point = Offset(x, y);
      points.add(point);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    // Draw the line
    canvas.drawPath(path, paint);

    // Draw points
    for (final point in points) {
      canvas.drawCircle(point, 3, pointPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// Custom painter for simple volume chart
class SimpleVolumeChartPainter extends CustomPainter {
  final List<PriceData> data;

  SimpleVolumeChartPainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final paint = Paint()
      ..color = ChartService.accentColor
      ..style = PaintingStyle.fill;

    final gridPaint = Paint()
      ..color = Colors.grey.shade300
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    // Draw grid lines
    for (int i = 1; i < 4; i++) {
      final y = (i / 4) * size.height;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Calculate the range and scale
    final maxPrice = data.map((e) => e.price).reduce((a, b) => a > b ? a : b);

    if (maxPrice == 0) return;

    final barWidth = size.width / data.length * 0.8;

    for (int i = 0; i < data.length; i++) {
      final barHeight = (data[i].price / maxPrice) * size.height;
      final x = (i / data.length) * size.width + (size.width / data.length - barWidth) / 2;
      final y = size.height - barHeight;

      final rect = Rect.fromLTWH(x, y, barWidth, barHeight);
      canvas.drawRect(rect, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// Custom painter for simple comparison chart
class SimpleComparisonChartPainter extends CustomPainter {
  final Map<int, PriceData> currentData;
  final Map<int, PriceData> previousData;

  SimpleComparisonChartPainter(this.currentData, this.previousData);

  @override
  void paint(Canvas canvas, Size size) {
    if (currentData.isEmpty && previousData.isEmpty) return;

    final currentPaint = Paint()
      ..color = ChartService.primaryColor
      ..style = PaintingStyle.fill;

    final previousPaint = Paint()
      ..color = ChartService.accentColor
      ..style = PaintingStyle.fill;

    final gridPaint = Paint()
      ..color = Colors.grey.shade300
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    // Draw grid lines
    for (int i = 1; i < 4; i++) {
      final y = (i / 4) * size.height;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Get all data points for scaling
    final allPrices = <double>[];
    allPrices.addAll(currentData.values.map((e) => e.price));
    allPrices.addAll(previousData.values.map((e) => e.price));

    if (allPrices.isEmpty) return;

    final maxPrice = allPrices.reduce((a, b) => a > b ? a : b);
    if (maxPrice == 0) return;

    final maxIndex = [
      if (currentData.isNotEmpty) currentData.keys.reduce((a, b) => a > b ? a : b),
      if (previousData.isNotEmpty) previousData.keys.reduce((a, b) => a > b ? a : b),
    ].fold(0, (a, b) => a > b ? a : b);

    final barWidth = size.width / (maxIndex + 1) * 0.3;

    // Draw current data bars
    for (final entry in currentData.entries) {
      final barHeight = (entry.value.price / maxPrice) * size.height;
      final x = (entry.key / (maxIndex + 1)) * size.width;
      final y = size.height - barHeight;

      final rect = Rect.fromLTWH(x, y, barWidth, barHeight);
      canvas.drawRect(rect, currentPaint);
    }

    // Draw previous data bars
    for (final entry in previousData.entries) {
      final barHeight = (entry.value.price / maxPrice) * size.height;
      final x = (entry.key / (maxIndex + 1)) * size.width + barWidth;
      final y = size.height - barHeight;

      final rect = Rect.fromLTWH(x, y, barWidth, barHeight);
      canvas.drawRect(rect, previousPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
