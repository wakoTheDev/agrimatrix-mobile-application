import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import '../models/app_models.dart';
import 'logging_service.dart';

class LocalStorageService {
  static final LocalStorageService _instance = LocalStorageService._internal();
  factory LocalStorageService() => _instance;
  LocalStorageService._internal();

  Database? _database; // Made nullable for web compatibility
  SharedPreferences? _prefs;
  bool _isWeb = kIsWeb;

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    if (!_isWeb) {
      await _initializeDatabase();
    }
  }

  Future<void> _initializeDatabase() async {
    try {
      final databasePath = await getDatabasesPath();
      final path = join(databasePath, 'agrimatrix.db');

      _database = await openDatabase(
        path,
        version: 1,
        onCreate: (db, version) async {
          await _createTables(db);
        },
      );
    } catch (e) {
      LoggingService.error('Error initializing database', e);
      // Fallback to web-only mode
      _isWeb = true;
    }
  }

  Future<void> _createTables(Database db) async {
    // Messages table
    await db.execute('''
      CREATE TABLE messages (
        id TEXT PRIMARY KEY,
        senderId TEXT NOT NULL,
        receiverId TEXT NOT NULL,
        content TEXT NOT NULL,
        type TEXT NOT NULL,
        timestamp INTEGER NOT NULL,
        isRead INTEGER NOT NULL DEFAULT 0,
        filePath TEXT,
        fileName TEXT
      )
    ''');

    // Listings table
    await db.execute('''
      CREATE TABLE listings (
        id TEXT PRIMARY KEY,
        sellerId TEXT NOT NULL,
        sellerName TEXT NOT NULL,
        product TEXT NOT NULL,
        description TEXT,
        quantity REAL NOT NULL,
        unit TEXT NOT NULL,
        pricePerUnit REAL NOT NULL,
        totalPrice REAL NOT NULL,
        location TEXT NOT NULL,
        category TEXT NOT NULL,
        grade TEXT,
        isOrganic INTEGER NOT NULL DEFAULT 0,
        isAvailable INTEGER NOT NULL DEFAULT 1,
        createdAt INTEGER NOT NULL,
        updatedAt INTEGER NOT NULL,
        images TEXT
      )
    ''');

    // Market data table
    await db.execute('''
      CREATE TABLE market_data (
        id TEXT PRIMARY KEY,
        product TEXT NOT NULL,
        averagePrice REAL NOT NULL,
        highPrice REAL NOT NULL,
        lowPrice REAL NOT NULL,
        priceChange REAL NOT NULL,
        priceChangePercent REAL NOT NULL,
        volume REAL NOT NULL,
        market TEXT NOT NULL,
        date INTEGER NOT NULL
      )
    ''');

    // Price history table
    await db.execute('''
      CREATE TABLE price_history (
        id TEXT PRIMARY KEY,
        product TEXT NOT NULL,
        price REAL NOT NULL,
        date INTEGER NOT NULL,
        market TEXT NOT NULL
      )
    ''');
  }

  // Save message to local storage
  Future<void> saveMessage(ChatMessage message) async {
    if (_isWeb) {
      // For web, use SharedPreferences as fallback
      await _saveMessageToPrefs(message);
      return;
    }
    
    if (_database != null) {
      await _database!.insert(
        'messages',
        {
          'id': message.id,
          'senderId': message.senderId,
          'receiverId': message.receiverId,
          'content': message.content,
          'type': message.type.toString(),
          'timestamp': message.timestamp.millisecondsSinceEpoch,
          'isRead': message.isRead ? 1 : 0,
          'filePath': message.filePath,
          'fileName': message.fileName,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  Future<void> _saveMessageToPrefs(ChatMessage message) async {
    final messageKey = 'message_${message.id}';
    final messageData = {
      'id': message.id,
      'senderId': message.senderId,
      'receiverId': message.receiverId,
      'content': message.content,
      'type': message.type.toString(),
      'timestamp': message.timestamp.millisecondsSinceEpoch,
      'isRead': message.isRead,
      'filePath': message.filePath,
      'fileName': message.fileName,
    };
    await _prefs?.setString(messageKey, jsonEncode(messageData));
    
    // Also maintain a list of message IDs
    final messageIds = _prefs?.getStringList('message_ids') ?? [];
    if (!messageIds.contains(message.id)) {
      messageIds.add(message.id);
      await _prefs?.setStringList('message_ids', messageIds);
    }
  }

  // Get messages from local storage
  Future<List<ChatMessage>> getMessages(String userId, String otherUserId) async {
    if (_isWeb) {
      return await _getMessagesFromPrefs(userId, otherUserId);
    }
    
    if (_database == null) return [];
    
    final results = await _database!.query(
      'messages',
      where: '(senderId = ? AND receiverId = ?) OR (senderId = ? AND receiverId = ?)',
      whereArgs: [userId, otherUserId, otherUserId, userId],
      orderBy: 'timestamp ASC',
    );

    return results.map((row) => ChatMessage(
      id: row['id'] as String,
      senderId: row['senderId'] as String,
      receiverId: row['receiverId'] as String,
      content: row['content'] as String,
      type: MessageType.values.firstWhere(
        (e) => e.toString() == row['type'] as String,
        orElse: () => MessageType.text,
      ),
      timestamp: DateTime.fromMillisecondsSinceEpoch(row['timestamp'] as int),
      isRead: (row['isRead'] as int) == 1,
      filePath: row['filePath'] as String?,
      fileName: row['fileName'] as String?,
    )).toList();
  }

  Future<List<ChatMessage>> _getMessagesFromPrefs(String userId, String otherUserId) async {
    final messageIds = _prefs?.getStringList('message_ids') ?? [];
    final messages = <ChatMessage>[];
    
    for (final messageId in messageIds) {
      final messageData = _prefs?.getString('message_$messageId');
      if (messageData != null) {
        final data = jsonDecode(messageData) as Map<String, dynamic>;
        final senderId = data['senderId'] as String;
        final receiverId = data['receiverId'] as String;
        
        if ((senderId == userId && receiverId == otherUserId) ||
            (senderId == otherUserId && receiverId == userId)) {
          messages.add(ChatMessage(
            id: data['id'] as String,
            senderId: senderId,
            receiverId: receiverId,
            content: data['content'] as String,
            type: MessageType.values.firstWhere(
              (e) => e.toString() == data['type'] as String,
              orElse: () => MessageType.text,
            ),
            timestamp: DateTime.fromMillisecondsSinceEpoch(data['timestamp'] as int),
            isRead: data['isRead'] as bool,
            filePath: data['filePath'] as String?,
            fileName: data['fileName'] as String?,
          ));
        }
      }
    }
    
    messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    return messages;
  }

  // Save listing to local storage
  Future<void> saveListing(EnhancedListing listing) async {
    if (_isWeb) {
      await _saveListingToPrefs(listing);
      return;
    }
    
    if (_database != null) {
      await _database!.insert(
        'listings',
        {
          'id': listing.id,
          'sellerId': listing.sellerId,
          'sellerName': listing.sellerName,
          'product': listing.product,
          'description': listing.description,
          'quantity': listing.quantity,
          'unit': listing.unit,
          'pricePerUnit': listing.pricePerUnit,
          'totalPrice': listing.pricePerUnit * listing.quantity, // Calculate total price
          'location': listing.location,
          'category': listing.category,
          'grade': listing.grade,
          'isOrganic': listing.isOrganic ? 1 : 0,
          'isAvailable': listing.status == ListingStatus.active ? 1 : 0, // Convert status to availability
          'createdAt': listing.postedDate.millisecondsSinceEpoch,
          'updatedAt': listing.postedDate.millisecondsSinceEpoch, // Use postedDate as updatedAt
          'images': jsonEncode(listing.images),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  Future<void> _saveListingToPrefs(EnhancedListing listing) async {
    final listingKey = 'listing_${listing.id}';
    final listingData = {
      'id': listing.id,
      'sellerId': listing.sellerId,
      'sellerName': listing.sellerName,
      'product': listing.product,
      'description': listing.description,
      'quantity': listing.quantity,
      'unit': listing.unit,
      'pricePerUnit': listing.pricePerUnit,
      'totalPrice': listing.pricePerUnit * listing.quantity, // Calculate total price
      'location': listing.location,
      'category': listing.category,
      'grade': listing.grade,
      'isOrganic': listing.isOrganic,
      'isAvailable': listing.status == ListingStatus.active, // Convert status to availability
      'createdAt': listing.postedDate.millisecondsSinceEpoch,
      'updatedAt': listing.postedDate.millisecondsSinceEpoch, // Use postedDate as updatedAt
      'images': listing.images,
    };
    await _prefs?.setString(listingKey, jsonEncode(listingData));
    
    // Also maintain a list of listing IDs
    final listingIds = _prefs?.getStringList('listing_ids') ?? [];
    if (!listingIds.contains(listing.id)) {
      listingIds.add(listing.id);
      await _prefs?.setStringList('listing_ids', listingIds);
    }
  }

  // Get all listings from local storage
  Future<List<EnhancedListing>> getListings() async {
    if (_isWeb) {
      return await _getListingsFromPrefs();
    }
    
    if (_database == null) return [];
    
    final results = await _database!.query('listings');
    return results.map((row) => EnhancedListing(
      id: row['id'] as String,
      sellerId: row['sellerId'] as String,
      sellerName: row['sellerName'] as String,
      product: row['product'] as String,
      description: row['description'] as String? ?? '',
      quantity: row['quantity'] as double,
      unit: row['unit'] as String,
      pricePerUnit: row['pricePerUnit'] as double,
      location: row['location'] as String,
      latitude: 0.0, 
      longitude: 0.0,
      images: List<String>.from(jsonDecode(row['images'] as String)),
      grade: row['grade'] as String? ?? '',
      isOrganic: (row['isOrganic'] as int) == 1,
      postedDate: DateTime.fromMillisecondsSinceEpoch(row['createdAt'] as int),
      rating: 4.0, 
      verified: true, 
      phone: '', 
      status: (row['isAvailable'] as int) == 1 ? ListingStatus.active : ListingStatus.sold,
      category: row['category'] as String,
    )).toList();
  }

  Future<List<EnhancedListing>> _getListingsFromPrefs() async {
    final listingIds = _prefs?.getStringList('listing_ids') ?? [];
    final listings = <EnhancedListing>[];
    
    for (final listingId in listingIds) {
      final listingData = _prefs?.getString('listing_$listingId');
      if (listingData != null) {
        final data = jsonDecode(listingData) as Map<String, dynamic>;
        listings.add(EnhancedListing(
          id: data['id'] as String,
          sellerId: data['sellerId'] as String,
          sellerName: data['sellerName'] as String,
          product: data['product'] as String,
          description: data['description'] as String? ?? '',
          quantity: (data['quantity'] as num).toDouble(),
          unit: data['unit'] as String,
          pricePerUnit: (data['pricePerUnit'] as num).toDouble(),
          location: data['location'] as String,
          latitude: 0.0, // Default values for required fields not in stored data
          longitude: 0.0,
          images: List<String>.from(data['images'] as List),
          grade: data['grade'] as String? ?? '',
          isOrganic: data['isOrganic'] as bool,
          postedDate: DateTime.fromMillisecondsSinceEpoch(data['createdAt'] as int),
          rating: 4.0, // Default rating
          verified: true, // Default verified status
          phone: '', // Default phone
          status: (data['isAvailable'] as bool) ? ListingStatus.active : ListingStatus.sold,
          category: data['category'] as String,
        ));
      }
    }
    
    return listings;
  }

  // Save market data to local storage
  Future<void> saveMarketData(Map<String, dynamic> marketData) async {
    if (_isWeb) {
      await _saveMarketDataToPrefs(marketData);
      return;
    }
    
    if (_database != null) {
      await _database!.insert(
        'market_data',
        marketData,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  Future<void> _saveMarketDataToPrefs(Map<String, dynamic> marketData) async {
    final dataKey = 'market_data_${marketData['id']}';
    await _prefs?.setString(dataKey, jsonEncode(marketData));
    
    // Also maintain a list of market data IDs
    final dataIds = _prefs?.getStringList('market_data_ids') ?? [];
    if (!dataIds.contains(marketData['id'])) {
      dataIds.add(marketData['id']);
      await _prefs?.setStringList('market_data_ids', dataIds);
    }
  }

  // Get market data from local storage
  Future<List<Map<String, dynamic>>> getMarketData() async {
    if (_isWeb) {
      return await _getMarketDataFromPrefs();
    }
    
    if (_database == null) return [];
    
    return await _database!.query(
      'market_data',
      orderBy: 'date DESC',
    );
  }

  Future<List<Map<String, dynamic>>> _getMarketDataFromPrefs() async {
    final dataIds = _prefs?.getStringList('market_data_ids') ?? [];
    final marketData = <Map<String, dynamic>>[];
    
    for (final dataId in dataIds) {
      final data = _prefs?.getString('market_data_$dataId');
      if (data != null) {
        marketData.add(jsonDecode(data) as Map<String, dynamic>);
      }
    }
    
    return marketData;
  }

  // Save batch data efficiently
  Future<void> saveBatchData(List<Map<String, dynamic>> data, String tableName) async {
    if (_isWeb) {
      // For web, save each item individually
      for (final item in data) {
        if (tableName == 'market_data') {
          await _saveMarketDataToPrefs(item);
        }
      }
      return;
    }
    
    if (_database == null) return;
    
    final batch = _database!.batch();
    for (final item in data) {
      batch.insert(tableName, item, conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit();
  }

  // Get price history from local storage
  Future<List<Map<String, dynamic>>> getPriceHistory(String product) async {
    if (_isWeb) {
      // For web, use SharedPreferences with a simplified approach
      final priceHistoryKey = 'price_history_$product';
      final data = _prefs?.getString(priceHistoryKey);
      if (data != null) {
        return List<Map<String, dynamic>>.from(jsonDecode(data));
      }
      return [];
    }
    
    if (_database == null) return [];
    
    final results = await _database!.query(
      'price_history',
      where: 'product = ?',
      whereArgs: [product],
      orderBy: 'date DESC',
    );

    return results;
  }

  // Store user preferences
  Future<void> storeUserPreference(String key, dynamic value) async {
    if (value is String) {
      await _prefs?.setString(key, value);
    } else if (value is int) {
      await _prefs?.setInt(key, value);
    } else if (value is double) {
      await _prefs?.setDouble(key, value);
    } else if (value is bool) {
      await _prefs?.setBool(key, value);
    } else if (value is List<String>) {
      await _prefs?.setStringList(key, value);
    } else {
      await _prefs?.setString(key, jsonEncode(value));
    }
  }

  // Get user preferences
  T? getUserPreference<T>(String key) {
    if (T == String) {
      return _prefs?.getString(key) as T?;
    } else if (T == int) {
      return _prefs?.getInt(key) as T?;
    } else if (T == double) {
      return _prefs?.getDouble(key) as T?;
    } else if (T == bool) {
      return _prefs?.getBool(key) as T?;
    } else if (T == List<String>) {
      return _prefs?.getStringList(key) as T?;
    }
    return null;
  }

  // Clear all local data
  Future<void> clearAllData() async {
    if (_isWeb) {
      await _prefs?.clear();
      return;
    }
    
    if (_database != null) {
      await _database!.delete('messages');
      await _database!.delete('listings');
      await _database!.delete('market_data');
      await _database!.delete('price_history');
    }
    await _prefs?.clear();
  }

  // Dispose resources
  void dispose() {
    _database?.close();
  }
}
