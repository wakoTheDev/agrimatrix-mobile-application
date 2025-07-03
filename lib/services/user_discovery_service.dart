import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/app_models.dart';
import 'logging_service.dart';

class UserDiscoveryService {
  static final UserDiscoveryService _instance = UserDiscoveryService._internal();
  factory UserDiscoveryService() => _instance;
  UserDiscoveryService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user profile
  Future<AppUser?> getCurrentUser() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    try {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists) {
        final data = doc.data()!;
        return AppUser(
          id: user.uid,
          name: data['name'] ?? user.displayName ?? 'Unknown',
          phone: data['phone'] ?? user.phoneNumber ?? '',
          email: data['email'] ?? user.email ?? '',
          profileImage: data['profileImage'] ?? user.photoURL ?? '',
          isOnline: data['isOnline'] ?? false,
          lastSeen: data['lastSeen'] != null 
            ? DateTime.fromMillisecondsSinceEpoch(data['lastSeen'])
            : DateTime.now(),
          verified: data['verified'] ?? false,
        );
      }
    } catch (e) {
      LoggingService.error('Error getting current user', e);
    }
    return null;
  }

  // Search for users by username, name, or phone
  Future<List<UserSearchResult>> searchUsers(String query, {int limit = 20}) async {
    if (query.isEmpty) return [];

    final currentUserId = _auth.currentUser?.uid;
    if (currentUserId == null) return [];

    try {
      final List<UserSearchResult> results = [];
      
      // Search by username
      final usernameQuery = await _firestore
          .collection('users')
          .where('username', isGreaterThanOrEqualTo: query.toLowerCase())
          .where('username', isLessThan: query.toLowerCase() + '\uf8ff')
          .limit(limit)
          .get();

      for (var doc in usernameQuery.docs) {
        if (doc.id != currentUserId) {
          results.add(_userSearchResultFromDoc(doc));
        }
      }

      // Search by name if we have fewer results
      if (results.length < limit) {
        final nameQuery = await _firestore
            .collection('users')
            .where('name', isGreaterThanOrEqualTo: query)
            .where('name', isLessThan: query + '\uf8ff')
            .limit(limit - results.length)
            .get();

        for (var doc in nameQuery.docs) {
          if (doc.id != currentUserId && 
              !results.any((r) => r.id == doc.id)) {
            results.add(_userSearchResultFromDoc(doc));
          }
        }
      }

      return results;
    } catch (e) {
      LoggingService.error('Error searching users', e, null, 'UserDiscoveryService');
      return [];
    }
  }

  // Get user by ID
  Future<UserSearchResult?> getUserById(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        return _userSearchResultFromDocSnapshot(doc);
      }
    } catch (e) {
      LoggingService.error('Error getting user by ID', e, null, 'UserDiscoveryService');
    }
    return null;
  }

  // Get users by location (nearby users)
  Future<List<UserSearchResult>> getNearbyUsers({
    required double latitude,
    required double longitude,
    double radiusKm = 50.0,
    int limit = 20,
  }) async {
    final currentUserId = _auth.currentUser?.uid;
    if (currentUserId == null) return [];

    try {
      // Simple lat/lng range query (for production, use geohash)
      final latRange = radiusKm / 111.0; // Rough km to degree conversion
      final lngRange = radiusKm / (111.0 * 0.8); // Adjusted for longitude

      final query = await _firestore
          .collection('users')
          .where('latitude', isGreaterThan: latitude - latRange)
          .where('latitude', isLessThan: latitude + latRange)
          .limit(limit * 2) // Get more to filter by longitude
          .get();

      final List<UserSearchResult> results = [];
      for (var doc in query.docs) {
        if (doc.id != currentUserId) {
          final data = doc.data();
          final userLng = data['longitude']?.toDouble() ?? 0.0;
          
          // Check longitude range
          if (userLng >= longitude - lngRange && userLng <= longitude + lngRange) {
            results.add(_userSearchResultFromDoc(doc));
          }
        }
      }

      return results.take(limit).toList();
    } catch (e) {
      LoggingService.error('Error getting nearby users', e);
      return [];
    }
  }

  // Get recent contacts (users we've chatted with)
  Future<List<UserSearchResult>> getRecentContacts({int limit = 10}) async {
    final currentUserId = _auth.currentUser?.uid;
    if (currentUserId == null) return [];

    try {
      final chatsQuery = await _firestore
          .collection('chats')
          .where('participants', arrayContains: currentUserId)
          .orderBy('lastMessageTime', descending: true)
          .limit(limit)
          .get();

      final List<UserSearchResult> results = [];
      for (var doc in chatsQuery.docs) {
        final data = doc.data();
        final participants = List<String>.from(data['participants']);
        final otherUserId = participants.firstWhere(
          (id) => id != currentUserId,
          orElse: () => '',
        );

        if (otherUserId.isNotEmpty) {
          final user = await getUserById(otherUserId);
          if (user != null) {
            results.add(user);
          }
        }
      }

      return results;
    } catch (e) {
      LoggingService.error('Error getting recent contacts', e);
      return [];
    }
  }

  // Update user profile
  Future<void> updateUserProfile({
    required String name,
    required String username,
    String? profileImage,
    String? location,
    double? latitude,
    double? longitude,
  }) async {
    final currentUserId = _auth.currentUser?.uid;
    if (currentUserId == null) return;

    try {
      final updateData = {
        'name': name,
        'username': username.toLowerCase(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (profileImage != null) updateData['profileImage'] = profileImage;
      if (location != null) updateData['location'] = location;
      if (latitude != null) updateData['latitude'] = latitude;
      if (longitude != null) updateData['longitude'] = longitude;

      await _firestore
          .collection('users')
          .doc(currentUserId)
          .update(updateData);
    } catch (e) {
      LoggingService.error('Error updating user profile', e);
    }
  }

  // Set user online status
  Future<void> setUserOnlineStatus(bool isOnline) async {
    final currentUserId = _auth.currentUser?.uid;
    if (currentUserId == null) return;

    try {
      await _firestore
          .collection('users')
          .doc(currentUserId)
          .update({
        'isOnline': isOnline,
        'lastSeen': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      LoggingService.error('Error updating online status', e);
    }
  }

  // Check if username is available
  Future<bool> isUsernameAvailable(String username) async {
    try {
      final query = await _firestore
          .collection('users')
          .where('username', isEqualTo: username.toLowerCase())
          .limit(1)
          .get();

      return query.docs.isEmpty;
    } catch (e) {
      LoggingService.error('Error checking username availability', e);
      return false;
    }
  }

  // Create user profile (called during registration)
  Future<void> createUserProfile({
    required String userId,
    required String name,
    required String username,
    required String email,
    String? phone,
    String? profileImage,
  }) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .set({
        'name': name,
        'username': username.toLowerCase(),
        'email': email,
        'phone': phone ?? '',
        'profileImage': profileImage ?? '',
        'isOnline': true,
        'verified': false,
        'createdAt': FieldValue.serverTimestamp(),
        'lastSeen': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      LoggingService.error('Error creating user profile', e);
    }
  }

  UserSearchResult _userSearchResultFromDoc(QueryDocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserSearchResult(
      id: doc.id,
      name: data['name'] ?? 'Unknown',
      username: data['username'] ?? '',
      profileImage: data['profileImage'] ?? '',
      isOnline: data['isOnline'] ?? false,
      verified: data['verified'] ?? false,
      location: data['location'] ?? '',
    );
  }

  UserSearchResult _userSearchResultFromDocSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserSearchResult(
      id: doc.id,
      name: data['name'] ?? 'Unknown',
      username: data['username'] ?? '',
      profileImage: data['profileImage'] ?? '',
      isOnline: data['isOnline'] ?? false,
      verified: data['verified'] ?? false,
      location: data['location'] ?? '',
    );
  }

  // Get user's chat list
  Future<List<Chat>> getUserChats() async {
    final currentUserId = _auth.currentUser?.uid;
    if (currentUserId == null) return [];

    try {
      final query = await _firestore
          .collection('chats')
          .where('participants', arrayContains: currentUserId)
          .orderBy('lastMessageTime', descending: true)
          .get();

      final List<Chat> chats = [];
      for (var doc in query.docs) {
        final data = doc.data();
        chats.add(Chat.fromJson({...data, 'id': doc.id}));
      }

      return chats;
    } catch (e) {
      LoggingService.error('Error getting user chats', e);
      return [];
    }
  }

  void dispose() {
    // Clean up any resources if needed
  }
}
