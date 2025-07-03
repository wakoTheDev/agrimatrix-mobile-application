import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'logging_service.dart';

class InsightsService {
  static final InsightsService _instance = InsightsService._internal();
  factory InsightsService() => _instance;
  InsightsService._internal();

  Timer? _insightsTimer;
  List<String> _userInterests = [];

  Future<void> initialize() async {
    await _loadUserPreferences();
    _startPeriodicInsightsUpdate();
  }

  Future<void> _loadUserPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _userInterests = prefs.getStringList('user_interests') ?? ['Maize', 'Tomatoes', 'Carrots'];
    } catch (e) {
      LoggingService.error('Error loading user preferences', e);
    }
  }

  void _startPeriodicInsightsUpdate() {
    _insightsTimer?.cancel();
    _insightsTimer = Timer.periodic(const Duration(hours: 1), (timer) {
      _generateInsights();
    });
  }

  Future<List<Map<String, dynamic>>> getMarketInsights() async {
    return _generateInsights();
  }

  Future<List<Map<String, dynamic>>> _generateInsights() async {
    final insights = <Map<String, dynamic>>[];

    // Generate price trend insights
    insights.addAll(await _generatePriceTrendInsights());
    
    // Generate seasonal insights
    insights.addAll(_generateSeasonalInsights());
    
    // Generate demand insights
    insights.addAll(_generateDemandInsights());
    
    // Generate market opportunity insights
    insights.addAll(_generateOpportunityInsights());

    // Sort by priority (critical first)
    insights.sort((a, b) {
      final aPriority = _getPriorityIndex(a['priority'] as String);
      final bPriority = _getPriorityIndex(b['priority'] as String);
      return bPriority.compareTo(aPriority);
    });

    return insights.take(10).toList();
  }

  int _getPriorityIndex(String priority) {
    switch (priority) {
      case 'critical':
        return 3;
      case 'high':
        return 2;
      case 'medium':
        return 1;
      case 'low':
      default:
        return 0;
    }
  }

  Future<List<Map<String, dynamic>>> _generatePriceTrendInsights() async {
    final insights = <Map<String, dynamic>>[];
    
    // Simulate price trend analysis
    for (final product in _userInterests) {
      final currentPrice = 45.0 + (DateTime.now().millisecond % 20);
      final previousPrice = currentPrice - (DateTime.now().second % 10);
      final priceChange = ((currentPrice - previousPrice) / previousPrice * 100);
      
      if (priceChange.abs() > 10) {
        insights.add({
          'id': 'price_trend_${product.toLowerCase()}',
          'title': '$product Price ${priceChange > 0 ? 'Surge' : 'Drop'}',
          'description': '$product prices have ${priceChange > 0 ? 'increased' : 'decreased'} by ${priceChange.abs().toStringAsFixed(1)}% in the last week.',
          'type': 'price_alert',
          'priority': priceChange.abs() > 20 ? 'critical' : 'high',
          'product': product,
          'data': {
            'current_price': currentPrice,
            'previous_price': previousPrice,
            'change_percent': priceChange,
          },
          'timestamp': DateTime.now().toIso8601String(),
          'actionable': true,
          'action_text': priceChange > 0 ? 'Consider selling' : 'Good time to buy',
        });
      }
    }

    return insights;
  }

  List<Map<String, dynamic>> _generateSeasonalInsights() {
    final insights = <Map<String, dynamic>>[];
    final currentMonth = DateTime.now().month;
    
    // Seasonal planting recommendations
    final seasonalCrops = _getSeasonalCrops(currentMonth);
    
    for (final crop in seasonalCrops) {
      insights.add({
        'id': 'seasonal_${crop['name'].toString().toLowerCase()}',
        'title': '${crop['name']} Planting Season',
        'description': 'Optimal time to plant ${crop['name']}. Expected harvest in ${crop['harvest_months']} months.',
        'type': 'seasonal_advice',
        'priority': 'medium',
        'product': crop['name'],
        'data': {
          'planting_month': currentMonth,
          'harvest_months': crop['harvest_months'],
          'expected_yield': crop['expected_yield'],
        },
        'timestamp': DateTime.now().toIso8601String(),
        'actionable': true,
        'action_text': 'Start planting preparation',
      });
    }

    return insights;
  }

  List<Map<String, dynamic>> _getSeasonalCrops(int month) {
    // Kenya's seasonal crop calendar
    switch (month) {
      case 3:
      case 4:
      case 5: // Long rains season
        return [
          {'name': 'Maize', 'harvest_months': 4, 'expected_yield': '2-3 tons/ha'},
          {'name': 'Beans', 'harvest_months': 3, 'expected_yield': '1-1.5 tons/ha'},
        ];
      case 10:
      case 11:
      case 12: // Short rains season
        return [
          {'name': 'Tomatoes', 'harvest_months': 3, 'expected_yield': '15-20 tons/ha'},
          {'name': 'Carrots', 'harvest_months': 3, 'expected_yield': '20-25 tons/ha'},
        ];
      default:
        return [];
    }
  }

  List<Map<String, dynamic>> _generateDemandInsights() {
    final insights = <Map<String, dynamic>>[];
    
    // Simulate demand analysis based on historical patterns
    final highDemandProducts = ['Tomatoes', 'Carrots', 'Onions'];
    
    for (final product in highDemandProducts) {
      if (_userInterests.contains(product)) {
        insights.add({
          'id': 'demand_${product.toLowerCase()}',
          'title': 'High Demand Alert: $product',
          'description': '$product showing increased market demand. Supply shortages expected in local markets.',
          'type': 'demand_alert',
          'priority': 'high',
          'product': product,
          'data': {
            'demand_increase': 25.0 + (DateTime.now().millisecond % 15),
            'supply_shortage': true,
            'recommended_action': 'increase_production',
          },
          'timestamp': DateTime.now().toIso8601String(),
          'actionable': true,
          'action_text': 'Consider increasing production',
        });
      }
    }

    return insights;
  }

  List<Map<String, dynamic>> _generateOpportunityInsights() {
    final insights = <Map<String, dynamic>>[];
    
    // Market opportunity insights
    insights.add({
      'id': 'export_opportunity',
      'title': 'Export Opportunity Available',
      'description': 'Regional demand for organic vegetables increased by 30%. Consider organic certification.',
      'type': 'opportunity',
      'priority': 'medium',
      'product': 'Organic Vegetables',
      'data': {
        'market': 'Regional Export',
        'demand_increase': 30.0,
        'certification_required': 'Organic',
        'potential_premium': 40.0,
      },
      'timestamp': DateTime.now().toIso8601String(),
      'actionable': true,
      'action_text': 'Explore organic certification',
    });

    // Value addition opportunity
    insights.add({
      'id': 'value_addition',
      'title': 'Value Addition Opportunity',
      'description': 'Processed tomato products showing 50% higher margins than fresh produce.',
      'type': 'opportunity',
      'priority': 'medium',
      'product': 'Tomatoes',
      'data': {
        'processing_type': 'Sauce/Paste',
        'margin_increase': 50.0,
        'investment_required': 'Processing equipment',
      },
      'timestamp': DateTime.now().toIso8601String(),
      'actionable': true,
      'action_text': 'Research processing options',
    });

    return insights;
  }

  Future<List<Map<String, dynamic>>> getPriceAlerts() async {
    final alerts = <Map<String, dynamic>>[];
    
    for (final product in _userInterests) {
      final currentPrice = 45.0 + (DateTime.now().millisecond % 20);
      final targetPrice = 50.0; // User's target price
      
      if (currentPrice >= targetPrice) {
        alerts.add({
          'id': 'alert_${product.toLowerCase()}',
          'product': product,
          'current_price': currentPrice,
          'target_price': targetPrice,
          'alert_type': 'price_reached',
          'message': '$product has reached your target price of KES $targetPrice',
          'timestamp': DateTime.now().toIso8601String(),
        });
      }
    }

    return alerts;
  }

  Future<Map<String, dynamic>> getWeatherInsights() async {
    // Simulate weather-based agricultural insights
    return {
      'current_conditions': 'Partly cloudy',
      'temperature': 24.0 + (DateTime.now().hour % 10),
      'humidity': 65.0 + (DateTime.now().minute % 20),
      'rainfall_prediction': 'Light rain expected in 2 days',
      'farming_recommendation': 'Good conditions for planting. Consider irrigation backup.',
      'alert_level': 'normal',
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  Future<List<Map<String, dynamic>>> getMarketNews() async {
    // Simulate agricultural market news
    return [
      {
        'id': 'news_1',
        'title': 'Government Announces Fertilizer Subsidies',
        'summary': 'New fertilizer subsidy program aims to reduce input costs by 30%.',
        'category': 'policy',
        'relevance': 'high',
        'timestamp': DateTime.now().subtract(const Duration(hours: 2)).toIso8601String(),
      },
      {
        'id': 'news_2',
        'title': 'Export Market Opens for Kenyan Avocados',
        'summary': 'New trade agreement allows direct export to European markets.',
        'category': 'trade',
        'relevance': 'medium',
        'timestamp': DateTime.now().subtract(const Duration(hours: 6)).toIso8601String(),
      },
      {
        'id': 'news_3',
        'title': 'Climate-Smart Agriculture Training Program',
        'summary': 'Free training program on sustainable farming practices starts next month.',
        'category': 'education',
        'relevance': 'medium',
        'timestamp': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
      },
    ];
  }

  Future<void> saveUserInterests(List<String> interests) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('user_interests', interests);
      _userInterests = interests;
    } catch (e) {
      LoggingService.error('Error saving user interests', e);
    }
  }

  Future<List<String>> getUserInterests() async {
    return _userInterests;
  }

  void dispose() {
    _insightsTimer?.cancel();
  }
}
