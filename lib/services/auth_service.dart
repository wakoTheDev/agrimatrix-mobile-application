import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'logging_service.dart';

class AuthService {
  FirebaseAuth? _auth;
  FirebaseFirestore? _firestore;
  
  AuthService() {
    try {
      // Check if Firebase is initialized before accessing instances
      if (Firebase.apps.isNotEmpty) {
        _auth = FirebaseAuth.instance;
        _firestore = FirebaseFirestore.instance;
        LoggingService.info('AuthService initialized with Firebase', 'AuthService');
      } else {
        LoggingService.warning('Firebase not initialized, AuthService running in offline mode', 'AuthService');
      }
    } catch (e) {
      LoggingService.error('Error initializing AuthService', e, null, 'AuthService');
    }
  }

  // Get current user
  User? get currentUser {
    try {
      return _auth?.currentUser;
    } catch (e) {
      LoggingService.error('Error getting current user', e, null, 'AuthService');
      return null;
    }
  }

  // Get auth state changes
  Stream<User?> get authStateChanges {
    try {
      return _auth?.authStateChanges() ?? Stream.value(null);
    } catch (e) {
      LoggingService.error('Error getting auth state changes', e, null, 'AuthService');
      return Stream.value(null);
    }
  }

  // Sign in with email and password
  Future<UserCredential> signInWithEmailAndPassword(String email, String password) async {
    if (_auth == null) {
      throw Exception('Firebase Auth not initialized. Please check your connection and try again.');
    }
    
    try {
      return await _auth!.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      LoggingService.error('Error signing in with email and password', e, null, 'AuthService');
      rethrow;
    }
  }

  // Register with email and password
  Future<UserCredential> registerWithEmailAndPassword(
    String email, 
    String password,
    String fullName,
    String phoneNumber,
  ) async {
    if (_auth == null || _firestore == null) {
      throw Exception('Firebase services not initialized. Please check your connection and try again.');
    }
    
    try {
      // Create user with email and password
      final userCredential = await _auth!.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Add user details to Firestore
      await _firestore!.collection('users').doc(userCredential.user!.uid).set({
        'fullName': fullName,
        'email': email,
        'phoneNumber': phoneNumber,
        'createdAt': FieldValue.serverTimestamp(),
      });

      return userCredential;
    } catch (e) {
      LoggingService.error('Error registering user', e, null, 'AuthService');
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    if (_auth == null) {
      LoggingService.warning('Firebase Auth not initialized, cannot sign out', 'AuthService');
      return;
    }
    
    try {
      await _auth!.signOut();
      LoggingService.info('User signed out successfully', 'AuthService');
    } catch (e) {
      LoggingService.error('Error signing out', e, null, 'AuthService');
      rethrow;
    }
  }

  // Check if user is signed in
  bool get isUserSignedIn {
    try {
      return _auth?.currentUser != null;
    } catch (e) {
      LoggingService.error('Error checking if user is signed in', e, null, 'AuthService');
      return false;
    }
  }

  // Sign in anonymously (guest mode)
  Future<UserCredential> signInAnonymously() async {
    if (_auth == null) {
      throw Exception('Firebase Auth not initialized. Please check your connection and try again.');
    }
    
    try {
      return await _auth!.signInAnonymously();
    } catch (e) {
      LoggingService.error('Error signing in anonymously', e, null, 'AuthService');
      rethrow;
    }
  }

  // Check if user is a guest
  bool get isGuest {
    try {
      return _auth?.currentUser?.isAnonymous ?? false;
    } catch (e) {
      LoggingService.error('Error checking if user is guest', e, null, 'AuthService');
      return false;
    }
  }

  // Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    if (_auth == null) {
      throw Exception('Firebase Auth not initialized. Please check your connection and try again.');
    }
    
    try {
      await _auth!.sendPasswordResetEmail(email: email);
      LoggingService.info('Password reset email sent', 'AuthService');
    } catch (e) {
      LoggingService.error('Error sending password reset email', e, null, 'AuthService');
      rethrow;
    }
  }
}
