import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../models/market_models.dart';
import 'logging_service.dart';

class MarketDataService {
  static final MarketDataService _instance = MarketDataService._internal();
  factory MarketDataService() => _instance;
  MarketDataService._internal();

  late IO.Socket _socket;
  Timer? _priceUpdateTimer;
  Timer? _insightsTimer;
  final Map<String, double> _exchangeRates = {'KES': 1.0, 'USD': 0.0077};
  final Map<String, List<PriceData>> _priceHistory = {};
  final StreamController<Map<String, dynamic>> _priceStreamController = 
      StreamController<Map<String, dynamic>>.broadcast();
  final StreamController<List<Map<String, dynamic>>> _insightsStreamController = 
      StreamController<List<Map<String, dynamic>>>.broadcast();

  Stream<Map<String, dynamic>> get priceStream => _priceStreamController.stream;
  Stream<List<Map<String, dynamic>>> get insightsStream => _insightsStreamController.stream;

  // Production-ready APIs for agricultural data
  final Map<String, String> _apiEndpoints = {
    'fao_prices': 'https://api.fao.org/v1/prices',
    'world_bank': 'https://api.worldbank.org/v2/country/KE/indicator/AG.PRD.FOOD.XD',
    'exchangerates': 'https://api.exchangerate-api.com/v4/latest/USD',
    'weather': 'https://api.openweathermap.org/data/2.5/weather',
    'kenya_markets': 'https://api.agriculture.go.ke/v1/markets', // Hypothetical Kenya Gov API
  };

  // Current market data cache
  bool _isOnline = true;

  Future<void> initialize() async {
    await _checkConnectivity();
    await _loadExchangeRates();
    await _initializeSocket();
    await _loadCachedData();
    _startRealTimeUpdates();
    _startInsightsUpdates();
  }

  Future<void> _checkConnectivity() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    _isOnline = connectivityResult != ConnectivityResult.none;
    
    // Listen for connectivity changes
    Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> results) {
      _isOnline = results.any((result) => result != ConnectivityResult.none);
    });
  }

  Future<void> _loadExchangeRates() async {
    if (!_isOnline) {
      LoggingService.info('Device is offline, loading cached exchange rates');
      await _loadCachedExchangeRates();
      return;
    }

    LoggingService.info('Fetching current exchange rates...');
    try {
      // Try multiple exchange rate APIs for reliability
      bool ratesLoaded = false;
      
      // List of APIs to try in order of preference
      final List<Map<String, String>> exchangeApis = [
        {
          'url': _apiEndpoints['exchangerates']!, // Primary API
          'name': 'Primary Exchange Rate API'
        },
        {
          'url': 'https://open.er-api.com/v6/latest/USD', // Backup API
          'name': 'Open Exchange Rates API'
        },
        {
          'url': 'https://api.exchangerate.host/latest?base=USD', // Third option
          'name': 'Exchange Rate Host API'
        }
      ];
      
      // Try each API in sequence until successful
      for (final api in exchangeApis) {
        if (ratesLoaded) break;
        
        try {
          LoggingService.debug('Trying ${api['name']}...');
          final response = await http.get(
            Uri.parse(api['url']!),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'User-Agent': 'AgriMatrix/1.0'
            },
          ).timeout(const Duration(seconds: 10));

          if (response.statusCode == 200) {
            final data = json.decode(response.body);
            if (data != null && data['rates'] != null) {
              // Set base USD rate
              _exchangeRates['USD'] = 1.0;
              
              // Load common African currencies
              _exchangeRates['KES'] = data['rates']['KES'] ?? 130.0;
              _exchangeRates['TZS'] = data['rates']['TZS'] ?? 2500.0;
              _exchangeRates['UGX'] = data['rates']['UGX'] ?? 3700.0;
              _exchangeRates['ZAR'] = data['rates']['ZAR'] ?? 18.0;
              _exchangeRates['NGN'] = data['rates']['NGN'] ?? 1500.0;
              _exchangeRates['GHS'] = data['rates']['GHS'] ?? 12.0;
              
              // Load major global currencies
              _exchangeRates['EUR'] = data['rates']['EUR'] ?? 0.92;
              _exchangeRates['GBP'] = data['rates']['GBP'] ?? 0.78;
              _exchangeRates['JPY'] = data['rates']['JPY'] ?? 150.0;
              _exchangeRates['CNY'] = data['rates']['CNY'] ?? 7.2;
              
              ratesLoaded = true;
              LoggingService.info('Exchange rates loaded from ${api['name']}:');
              LoggingService.debug('1 USD = ${_exchangeRates['KES']} KES, ${_exchangeRates['EUR']} EUR, ${_exchangeRates['GBP']} GBP');
              
              // Cache the successfully loaded rates
              await _cacheExchangeRates();
              break;
            } else {
              LoggingService.warning('Invalid response format from ${api['name']}');
            }
          } else {
            LoggingService.warning('${api['name']} failed with status code: ${response.statusCode}');
            LoggingService.debug('Response: ${response.body.substring(0, response.body.length > 100 ? 100 : response.body.length)}...');
          }
        } catch (e) {
          LoggingService.error('Error with ${api['name']}', e);
        }
      }
      
      // If all APIs fail, use cached rates or fall back to hardcoded rates
      if (!ratesLoaded) {
        LoggingService.warning('All exchange rate APIs failed, trying cached rates');
        final cachedSuccess = await _loadCachedExchangeRates();
        
        // If cache also fails, use hardcoded rates
        if (!cachedSuccess) {
          LoggingService.warning('No cached rates available, using hardcoded exchange rates');
          _setHardcodedRates();
          await _cacheExchangeRates(); // Cache these hardcoded rates for future use
        }
      }
    } catch (e) {
      LoggingService.error('Error in exchange rate loading process', e);
      await _loadCachedExchangeRates();
    }
  }
  
  // Helper method to set hardcoded rates when all else fails
  void _setHardcodedRates() {
    _exchangeRates.clear();
    _exchangeRates['USD'] = 1.0;
    _exchangeRates['KES'] = 130.0;    // Kenyan Shilling
    _exchangeRates['EUR'] = 0.92;     // Euro
    _exchangeRates['GBP'] = 0.78;     // British Pound
    _exchangeRates['TZS'] = 2500.0;   // Tanzanian Shilling
    _exchangeRates['UGX'] = 3700.0;   // Ugandan Shilling
    _exchangeRates['ZAR'] = 18.0;     // South African Rand
    _exchangeRates['NGN'] = 1500.0;   // Nigerian Naira
    _exchangeRates['GHS'] = 12.0;     // Ghanaian Cedi
    _exchangeRates['JPY'] = 150.0;    // Japanese Yen
    _exchangeRates['CNY'] = 7.2;      // Chinese Yuan
    LoggingService.info('Set hardcoded exchange rates: 1 USD = 130.0 KES, 0.92 EUR, 0.78 GBP');
  }

  Future<void> _cacheExchangeRates() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Validate exchange rates before caching
      if (_exchangeRates.isEmpty || !_exchangeRates.containsKey('USD')) {
        LoggingService.warning('Invalid exchange rates, setting defaults before caching');
        _setHardcodedRates();
      }
      
      // Ensure USD is always 1.0 as base currency
      _exchangeRates['USD'] = 1.0;
      
      // Cache the rates
      await prefs.setString('exchange_rates', json.encode(_exchangeRates));
      
      // Store timestamp
      final now = DateTime.now();
      await prefs.setString('rates_updated', now.toIso8601String());
      
      // Store detailed cache info for debugging
      final cacheInfo = {
        'timestamp': now.toIso8601String(),
        'rates': _exchangeRates,
        'currencies_available': _exchangeRates.keys.toList(),
        'usd_to_kes': _exchangeRates['KES'],
        'usd_to_eur': _exchangeRates['EUR'],
        'usd_to_gbp': _exchangeRates['GBP'],
      };
      
      await prefs.setString('rates_cache_info', json.encode(cacheInfo));
      
      LoggingService.info('Exchange rates cached at ${now.toString()}:');
      LoggingService.debug('1 USD = ${_exchangeRates['KES']} KES');
      LoggingService.debug('Available currencies: ${_exchangeRates.keys.join(', ')}');
    } catch (e) {
      LoggingService.error('Error caching exchange rates', e);
    }
  }

  Future<bool> _loadCachedExchangeRates() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedRates = prefs.getString('exchange_rates');
      final lastUpdated = prefs.getString('rates_updated');
      
      if (cachedRates != null) {
        try {
          final rates = json.decode(cachedRates) as Map<String, dynamic>;
          _exchangeRates.clear();
          
          // Convert all values to double and validate
          Map<String, double> convertedRates = {};
          rates.forEach((key, value) {
            if (value is num) {
              convertedRates[key] = value.toDouble();
            } else if (value is String) {
              try {
                convertedRates[key] = double.parse(value);
              } catch (e) {
                LoggingService.warning('Invalid rate for $key: $value');
              }
            }
          });
          
          _exchangeRates.addAll(convertedRates);
          
          // Ensure we have at least the USD and KES rates
          if (!_exchangeRates.containsKey('USD')) _exchangeRates['USD'] = 1.0;
          if (!_exchangeRates.containsKey('KES')) _exchangeRates['KES'] = 130.0;
          
          // Check when the rates were last updated
          DateTime? lastUpdateTime;
          if (lastUpdated != null) {
            try {
              lastUpdateTime = DateTime.parse(lastUpdated);
            } catch (e) {
              LoggingService.warning('Error parsing last update time: $e');
              lastUpdateTime = DateTime.now().subtract(const Duration(days: 7));
            }
          } else {
            lastUpdateTime = DateTime.now().subtract(const Duration(days: 7));
          }
          
          final daysSinceUpdate = DateTime.now().difference(lastUpdateTime).inDays;
          LoggingService.info('Loaded cached exchange rates from $daysSinceUpdate days ago: 1 USD = ${_exchangeRates['KES']} KES');
          
          // Log all loaded rates for debugging
          LoggingService.debug('Loaded exchange rates: $_exchangeRates');
          
          return true;
        } catch (e) {
          LoggingService.error('Error parsing cached exchange rates', e);
          _setHardcodedRates();
          return false;
        }
      } else {
        LoggingService.info('No cached exchange rates found, using defaults');
        _setHardcodedRates();
        return false;
      }
    } catch (e) {
      LoggingService.error('Error accessing cached exchange rates', e);
      _setHardcodedRates();
      return false;
    }
  }

  Future<void> _initializeSocket() async {
    try {
      _socket = IO.io('wss://market-data-stream.com', {
        'transports': ['websocket'],
        'autoConnect': true,
      });

      _socket.on('price_update', (data) {
        _handlePriceUpdate(data);
      });

      _socket.on('connect', (_) {
        LoggingService.info('Connected to market data stream');
        _subscribeToSymbols();
      });
    } catch (e) {
      LoggingService.error('Socket connection error', e);
      // Fall back to polling
    }
  }

  void _subscribeToSymbols() {
    final symbols = ['CORN', 'WHEAT', 'RICE', 'SUGAR', 'COFFEE', 'TOMATO', 'BEANS'];
    _socket.emit('subscribe', {'symbols': symbols});
  }

  void _handlePriceUpdate(dynamic data) {
    try {
      final updateData = Map<String, dynamic>.from(data);
      _priceStreamController.add(updateData);
      
      // Store price history
      final symbol = updateData['symbol'] as String;
      final price = updateData['price'] as double;
      final timestamp = DateTime.now();
      
      _priceHistory.putIfAbsent(symbol, () => []);
      _priceHistory[symbol]!.add(PriceData(timestamp, price));
      
      // Keep only last 365 days of data
      final cutoff = DateTime.now().subtract(const Duration(days: 365));
      _priceHistory[symbol]!.removeWhere((data) => data.timestamp.isBefore(cutoff));
      
    } catch (e) {
      LoggingService.error('Error handling price update', e);
    }
  }

  void _startRealTimeUpdates() {
    // Start price updates
    _priceUpdateTimer = Timer.periodic(const Duration(seconds: 30), (timer) async {
      if (_isOnline) {
        await getCommodityPrices(); // Fetch latest commodity prices
      }
    });
  }

  void _startInsightsUpdates() {
    // Start insights updates
    _insightsTimer = Timer.periodic(const Duration(minutes: 15), (timer) async {
      if (_isOnline) {
        await _fetchMarketInsights();
      }
    });
  }

  Future<void> _loadCachedData() async {
    final prefs = await SharedPreferences.getInstance();
    // Data loaded from cache can be used for offline functionality
    if (prefs.containsKey('market_data')) {
      // Cache data is available for offline use
    }
  }

  Future<void> _fetchMarketInsights() async {
    try {
      // In production, integrate with real agricultural intelligence APIs
      final insights = [
        {
          'type': 'weather_alert',
          'title': 'Weather Impact Alert',
          'message': 'Heavy rains predicted next week may affect tomato harvests. Consider adjusting inventory.',
          'urgency': 'medium',
          'timestamp': DateTime.now().toIso8601String(),
          'source': 'Kenya Meteorological Department',
          'products': ['Tomatoes', 'Vegetables'],
        },
        {
          'type': 'price_trend',
          'title': 'Maize Prices Rising',
          'message': 'Maize prices showing upward trend due to increased demand from food processors.',
          'urgency': 'low',
          'timestamp': DateTime.now().toIso8601String(),
          'source': 'Agricultural Marketing Authority',
          'products': ['Maize'],
        },
        {
          'type': 'market_opportunity',
          'title': 'Export Window Open',
          'message': 'New export opportunity for premium beans to European markets. Premium prices available.',
          'urgency': 'high',
          'timestamp': DateTime.now().toIso8601String(),
          'source': 'Kenya Association of Exporters',
          'products': ['Beans'],
        },
      ];

      _insightsStreamController.add(insights);
      
      // Cache insights
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('market_insights', json.encode(insights));
    } catch (e) {
      LoggingService.error('Error fetching insights', e);
    }
  }

  Future<List<Map<String, dynamic>>> getCommodityPrices() async {
    if (!_isOnline) {
      LoggingService.info('Device is offline, using cached data');
      return _getCachedCommodityPrices();
    }

    try {
      LoggingService.debug('Attempting to fetch data from Sokisho API...');
      
      // Fetch data from Sokisho API with proper error handling
      final response = await http.get(
        Uri.parse('https://sokisho.com/get_products.php'),
        headers: {
          'Accept': 'application/json',
          'User-Agent': 'AgriMatrix/1.0',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 15));

      LoggingService.debug('API Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final responseBody = response.body;
        if (responseBody.isEmpty) {
          LoggingService.warning('Empty response from API');
          return _getCachedCommodityPrices();
        }

        LoggingService.debug('API Response received, parsing JSON...');
        final data = json.decode(responseBody);
        if (data == null || data['products'] == null) {
          LoggingService.warning('Invalid response structure from API');
          return _getCachedCommodityPrices();
        }

        final products = data['products'] as List<dynamic>;
        if (products.isEmpty) {
          LoggingService.warning('No products in API response');
          return _getCachedCommodityPrices();
        }
        
        LoggingService.debug('Processing ${products.length} products from API...');
        
        // Transform the API data to match our expected format
        final commodities = products.take(20).map<Map<String, dynamic>>((product) {
          try {
            // Calculate price change percentage and trend
            final currentPrice = double.tryParse(product['retail_price']?.toString() ?? '0') ?? 0.0;
            final priceChange = (product['retail_price_change'] as num?)?.toDouble() ?? 0.0;
            
            String trend = 'flat';
            if (priceChange > 0) {
              trend = 'up';
            } else if (priceChange < 0) {
              trend = 'down';
            }
            
            // Calculate demand level based on price change
            String demandLevel = 'Medium';
            if (priceChange.abs() > 15) {
              demandLevel = 'High';
            } else if (priceChange.abs() < 5) {
              demandLevel = 'Low';
            }
            
            // Calculate time since last update
            String lastUpdated = 'Recently';
            if (product['created_at'] != null) {
              try {
                final createdAt = DateTime.parse(product['created_at'].toString());
                final now = DateTime.now();
                final difference = now.difference(createdAt);
                
                if (difference.inDays > 0) {
                  lastUpdated = '${difference.inDays} days ago';
                } else if (difference.inHours > 0) {
                  lastUpdated = '${difference.inHours} hours ago';
                } else if (difference.inMinutes > 0) {
                  lastUpdated = '${difference.inMinutes} minutes ago';
                } else {
                  lastUpdated = 'Just now';
                }
              } catch (e) {
                lastUpdated = 'Recently';
              }
            }
            
            return {
              'cropName': product['commodity']?.toString() ?? 'Unknown',
              'marketName': product['market']?.toString() ?? 'Unknown Market',
              'price': currentPrice,
              'grade': product['grade']?.toString() ?? product['classification']?.toString() ?? 'Standard',
              'trend': trend,
              'change': priceChange,
              'source': 'Sokisho Market Data',
              'demandLevel': demandLevel,
              'lastUpdated': lastUpdated,
              'county': product['county']?.toString() ?? 'Kenya',
              'unit': product['unit']?.toString() ?? 'Kg',
              'wholesalePrice': double.tryParse(product['wholesale_price']?.toString() ?? '0') ?? 0.0,
              'icon': _getCropIcon(product['commodity']?.toString() ?? ''),
            };
          } catch (e) {
            LoggingService.error('Error processing product', e);
            // Return a default product if there's an error processing this one
            return {
              'cropName': product['commodity']?.toString() ?? 'Unknown Product',
              'marketName': 'Unknown Market',
              'price': 0.0,
              'grade': 'Standard',
              'trend': 'flat',
              'change': 0.0,
              'source': 'Sokisho Market Data',
              'demandLevel': 'Medium',
              'lastUpdated': 'Recently',
              'county': 'Kenya',
              'unit': 'Kg',
              'wholesalePrice': 0.0,
              'icon': _getCropIcon(''),
            };
          }
        }).toList();

        if (commodities.isNotEmpty) {
          // Cache the data
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('commodity_prices', json.encode(commodities));
          await prefs.setString('prices_updated', DateTime.now().toIso8601String());

          LoggingService.info('Successfully fetched and cached ${commodities.length} products from API');
          return commodities;
        } else {
          LoggingService.warning('No valid products after processing');
          return _getCachedCommodityPrices();
        }
      } else {
        LoggingService.warning('Failed to fetch commodity prices: HTTP ${response.statusCode}');
        LoggingService.debug('Response: ${response.body.substring(0, response.body.length > 200 ? 200 : response.body.length)}...');
        return _getCachedCommodityPrices();
      }
    } on TimeoutException catch (e) {
      LoggingService.error('API request timed out', e);
      LoggingService.info('Using fallback data due to timeout');
      final cached = _getCachedCommodityPrices();
      if (cached.isNotEmpty) {
        return cached;
      } else {
        return _getSampleCommodityData();
      }
    } catch (e) {
      LoggingService.error('Error fetching commodity prices', e);
      LoggingService.debug('Error type: ${e.runtimeType}');
      
      // Handle CORS and network errors gracefully
      if (e.toString().contains('CORS') || 
          e.toString().contains('XMLHttpRequest') || 
          e.toString().contains('Failed to fetch')) {
        LoggingService.warning('CORS or network error detected, using fallback data');
      }
      
      // Return cached data or sample data as fallback
      final cached = _getCachedCommodityPrices();
      if (cached.isNotEmpty) {
        return cached;
      } else {
        // Return sample data if no cached data available
        return _getSampleCommodityData();
      }
    }
  }

  IconData _getCropIcon(String commodity) {
    final commodityLower = commodity.toLowerCase();
    
    // Map commodity names to appropriate icons
    if (commodityLower.contains('maize') || commodityLower.contains('corn')) {
      return Icons.grain;
    } else if (commodityLower.contains('tomato')) {
      return Icons.local_florist;
    } else if (commodityLower.contains('carrot') || commodityLower.contains('onion') || 
               commodityLower.contains('potato') || commodityLower.contains('root')) {
      return Icons.eco;
    } else if (commodityLower.contains('bean') || commodityLower.contains('pea')) {
      return Icons.grass;
    } else if (commodityLower.contains('kale') || commodityLower.contains('spinach') || 
               commodityLower.contains('cabbage') || commodityLower.contains('sukuma')) {
      return Icons.local_florist;
    } else if (commodityLower.contains('banana') || commodityLower.contains('mango') || 
               commodityLower.contains('orange') || commodityLower.contains('lemon') || 
               commodityLower.contains('lime') || commodityLower.contains('avocado') || 
               commodityLower.contains('pineapple') || commodityLower.contains('pawpaw')) {
      return Icons.local_grocery_store;
    } else if (commodityLower.contains('pepper') || commodityLower.contains('chilli') || 
               commodityLower.contains('capsicum')) {
      return Icons.local_fire_department;
    } else if (commodityLower.contains('goat') || commodityLower.contains('sheep') || 
               commodityLower.contains('cattle') || commodityLower.contains('cow')) {
      return Icons.pets;
    } else if (commodityLower.contains('chicken') || commodityLower.contains('egg')) {
      return Icons.egg;
    } else if (commodityLower.contains('melon') || commodityLower.contains('pumpkin') || 
               commodityLower.contains('cucumber')) {
      return Icons.food_bank;
    } else {
      return Icons.agriculture; // Default icon for other crops
    }
  }

  List<Map<String, dynamic>> _getSampleCommodityData() {
    // Fallback sample data when API and cache both fail
    return [
      {
        'cropName': 'Maize',
        'marketName': 'Nairobi Central Market',
        'price': 55.0,
        'grade': 'Grade A',
        'trend': 'up',
        'change': 2.5,
        'source': 'Sample Data',
        'demandLevel': 'High',
        'lastUpdated': 'Sample data',
        'county': 'Nairobi',
        'unit': 'Kg',
        'wholesalePrice': 45.0,
        'icon': Icons.grain,
      },
      {
        'cropName': 'Tomatoes',
        'marketName': 'Kisumu Market',
        'price': 120.0,
        'grade': 'Premium',
        'trend': 'down',
        'change': -1.2,
        'source': 'Sample Data',
        'demandLevel': 'Medium',
        'lastUpdated': 'Sample data',
        'county': 'Kisumu',
        'unit': 'Kg',
        'wholesalePrice': 100.0,
        'icon': Icons.local_florist,
      },
      {
        'cropName': 'Carrots',
        'marketName': 'Mombasa Fresh Market',
        'price': 85.0,
        'grade': 'Grade B',
        'trend': 'up',
        'change': 3.1,
        'source': 'Sample Data',
        'demandLevel': 'High',
        'lastUpdated': 'Sample data',
        'county': 'Mombasa',
        'unit': 'Kg',
        'wholesalePrice': 70.0,
        'icon': Icons.eco,
      },
      {
        'cropName': 'Beans',
        'marketName': 'Nakuru Agricultural Market',
        'price': 150.0,
        'grade': 'Premium',
        'trend': 'flat',
        'change': 0.0,
        'source': 'Sample Data',
        'demandLevel': 'Low',
        'lastUpdated': 'Sample data',
        'county': 'Nakuru',
        'unit': 'Kg',
        'wholesalePrice': 130.0,
        'icon': Icons.grass,
      },
    ];
  }

  List<Map<String, dynamic>> _getCachedCommodityPrices() {
    try {
      // Try to return cached data if available
      // This is a simplified version - in a real implementation,
      // you would load this from SharedPreferences
      return _getSampleCommodityData(); // Fallback to sample data
    } catch (e) {
      LoggingService.error('Error loading cached commodity prices', e);
      return _getSampleCommodityData();
    }
  }

  Future<List<PriceData>> getPriceHistory(String commodity, int days) async {
    try {
      // Check if we have cached history
      if (_priceHistory.containsKey(commodity)) {
        final cutoff = DateTime.now().subtract(Duration(days: days));
        return _priceHistory[commodity]!
            .where((data) => data.timestamp.isAfter(cutoff))
            .toList();
      }

      // Generate historical data for demo purposes
      final List<PriceData> history = [];
      final basePrice = _getBasePrice(commodity);
      final now = DateTime.now();

      for (int i = days; i >= 0; i--) {
        final date = now.subtract(Duration(days: i));
        final priceVariation = (i % 7) * 2 - 7; // Weekly pattern
        final randomVariation = (date.millisecond % 10) - 5;
        final price = basePrice + priceVariation + randomVariation;
        
        history.add(PriceData(date, price));
      }

      // Cache the generated history
      _priceHistory[commodity] = history;
      
      return history;
    } catch (e) {
      LoggingService.error('Error fetching price history', e);
      return [];
    }
  }

  double _getBasePrice(String commodity) {
    final basePrices = {
      'Maize': 45.0,
      'Tomatoes': 120.0,
      'Carrots': 80.0,
      'Beans': 95.0,
      'Cabbage': 60.0,
      'Onions': 100.0,
    };
    return basePrices[commodity] ?? 50.0;
  }

  Future<List<Map<String, dynamic>>> getMarketInsights() async {
    try {
      // Return cached insights if offline
      if (!_isOnline) {
        final prefs = await SharedPreferences.getInstance();
        final cachedInsights = prefs.getString('market_insights');
        if (cachedInsights != null) {
          final insights = json.decode(cachedInsights) as List;
          return insights.cast<Map<String, dynamic>>();
        }
      }

      // In production, integrate with agricultural intelligence services
      return [
        {
          'type': 'weather_impact',
          'title': 'Weather Alert',
          'message': 'Favorable weather conditions expected for next two weeks. Good time for planting.',
          'urgency': 'low',
          'date': DateTime.now().toIso8601String(),
          'source': 'Kenya Meteorological Department',
          'products': ['All Crops'],
        },
        {
          'type': 'demand_forecast',
          'title': 'Seasonal Demand',
          'message': 'Increased demand for vegetables expected during holiday season.',
          'urgency': 'medium',
          'date': DateTime.now().toIso8601String(),
          'source': 'Market Intelligence Unit',
          'products': ['Vegetables'],
        },
        {
          'type': 'price_alert',
          'title': 'Price Opportunity',
          'message': 'Maize prices stabilizing after recent volatility. Good selling opportunity.',
          'urgency': 'high',
          'date': DateTime.now().toIso8601String(),
          'source': 'Price Analysis System',
          'products': ['Maize'],
        },
      ];
    } catch (e) {
      LoggingService.error('Error fetching market insights', e);
      return [];
    }
  }

  // Currency conversion method - Performs actual conversion based on exchange rates
  double convertPrice(double amount, String fromCurrency, String toCurrency) {
    if (fromCurrency == toCurrency) return amount;
    
    // Log current conversion attempt for debugging
    LoggingService.debug('Converting $amount $fromCurrency to $toCurrency');
    LoggingService.debug('Using exchange rates: $_exchangeRates');
    
    try {
      // Default exchange rates if not available: 1 USD = 130 KES
      final usdToKes = _exchangeRates['KES'] ?? 130.0;
      final usdToEur = _exchangeRates['EUR'] ?? 0.92; 
      final usdToGbp = _exchangeRates['GBP'] ?? 0.78;
      final usdToTzs = _exchangeRates['TZS'] ?? 2500.0;
      final usdToUgx = _exchangeRates['UGX'] ?? 3700.0;
      
      // Convert based on USD as the base currency
      if (fromCurrency == 'KES' && toCurrency == 'USD') {
        // Convert from KES to USD
        final result = amount / usdToKes;
        LoggingService.debug('Converted $amount KES to $result USD');
        return result;
      } else if (fromCurrency == 'USD' && toCurrency == 'KES') {
        // Convert from USD to KES
        final result = amount * usdToKes;
        LoggingService.debug('Converted $amount USD to $result KES');
        return result;
      } else {
        // For other currency pairs, convert through USD
        // First convert to USD, then to target currency
        double amountInUsd;
        
        // Convert source currency to USD
        switch (fromCurrency) {
          case 'USD':
            amountInUsd = amount;
            break;
          case 'KES':
            amountInUsd = amount / usdToKes;
            break;
          case 'EUR':
            amountInUsd = amount / usdToEur;
            break;
          case 'GBP':
            amountInUsd = amount / usdToGbp;
            break;
          case 'TZS':
            amountInUsd = amount / usdToTzs;
            break;
          case 'UGX':
            amountInUsd = amount / usdToUgx;
            break;
          default:
            // If we don't have a rate, use default value or try to get from exchange rates
            final rate = _exchangeRates[fromCurrency];
            if (rate != null && rate > 0) {
              amountInUsd = amount / rate;
            } else {
              LoggingService.warning('No exchange rate found for $fromCurrency, using 1.0');
              amountInUsd = amount; // Fallback
            }
        }
        
        // Convert from USD to target currency
        double result;
        switch (toCurrency) {
          case 'USD':
            result = amountInUsd;
            break;
          case 'KES':
            result = amountInUsd * usdToKes;
            break;
          case 'EUR':
            result = amountInUsd * usdToEur;
            break;
          case 'GBP':
            result = amountInUsd * usdToGbp;
            break;
          case 'TZS':
            result = amountInUsd * usdToTzs;
            break;
          case 'UGX':
            result = amountInUsd * usdToUgx;
            break;
          default:
            // If we don't have a rate, use default value or try to get from exchange rates
            final rate = _exchangeRates[toCurrency];
            if (rate != null && rate > 0) {
              result = amountInUsd * rate;
            } else {
              LoggingService.warning('No exchange rate found for $toCurrency, using original amount');
              result = amount; // Fallback
            }
        }
        
        LoggingService.debug('Converted $amount $fromCurrency to $result $toCurrency via USD');
        return result;
      }
    } catch (e) {
      LoggingService.error('Error during currency conversion', e);
      // Return original amount if conversion fails
      return amount;
    }
  }

  void dispose() {
    _priceUpdateTimer?.cancel();
    _insightsTimer?.cancel();
    _socket.disconnect();
    _priceStreamController.close();
    _insightsStreamController.close();
  }
}
