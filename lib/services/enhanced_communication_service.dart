import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/app_models.dart';
import '../services/web_helper.dart' as web;
import '../services/webrtc_service.dart';
import 'logging_service.dart';

// Enhanced communication service with optimized loading
class EnhancedCommunicationService {
  // Singleton pattern implementation
  static final EnhancedCommunicationService _instance = EnhancedCommunicationService._internal();
  factory EnhancedCommunicationService() => _instance;
  EnhancedCommunicationService._internal();

  // Internal services
  final WebRTCService _rtcService = WebRTCService();
  
  // Flag to track initialization
  bool _initialized = false;
  
  // Stream controller for incoming calls
  final StreamController<IncomingCall> _incomingCallController = 
      StreamController<IncomingCall>.broadcast();
  
  // Public stream for incoming calls
  Stream<IncomingCall> get incomingCallStream => _incomingCallController.stream;
  
  // Call state stream forwarded from WebRTC service
  Stream<CallState> get callStateStream => _rtcService.callStateStream;

  // Stream controller for incoming messages
  final StreamController<ChatMessage> _messageController = 
      StreamController<ChatMessage>.broadcast();
  
  // Public stream for incoming messages
  Stream<ChatMessage> get messageStream => _messageController.stream;

  /// Initialize the service
  Future<bool> initialize(String userId) async {
    if (_initialized) return true;
    
    if (kIsWeb && !web.shouldInitializeService('communication')) {
      LoggingService.info('Communication service initialization skipped on web platform', 'Communication');
      return false;
    }

    // Initialize WebRTC service
    final rtcInitialized = await _rtcService.initialize(userId);
    
    _initialized = rtcInitialized;
    return _initialized;
  }

  /// Start a call to another user
  Future<String?> startCall(String receiverId, CallType callType) async {
    if (!_initialized) {
      LoggingService.warning('Cannot start call: Communication service not initialized', 'Communication');
      return null;
    }
    
    return await _rtcService.startCall(receiverId, callType);
  }

  /// Accept an incoming call
  Future<bool> acceptCall(String callId) async {
    if (!_initialized) return false;
    
    return await _rtcService.acceptCall(callId);
  }

  /// Reject an incoming call
  Future<void> rejectCall(String callId) async {
    await _rtcService.rejectCall(callId);
  }

  /// End the current call
  Future<void> endCall() async {
    await _rtcService.endCall();
  }

  /// Toggle microphone mute state
  void toggleMute(bool isMuted) {
    _rtcService.toggleMute(isMuted);
  }

  /// Toggle camera on/off
  void toggleCamera(bool isCameraOff) {
    _rtcService.toggleCamera(isCameraOff);
  }

  /// Toggle speaker mode
  void toggleSpeaker(bool isSpeakerOn) {
    _rtcService.toggleSpeaker(isSpeakerOn);
  }

  /// Send a message to another user
  Future<bool> sendMessage(String receiverId, String content, MessageType type) async {
    if (!_initialized) {
      LoggingService.warning('Cannot send message: Communication service not initialized', 'Communication');
      return false;
    }

    try {
      // Create a new message
      final message = ChatMessage(
        id: 'msg-${DateTime.now().millisecondsSinceEpoch}',
        senderId: 'current-user', // This should be replaced with actual current user ID
        receiverId: receiverId,
        content: content,
        type: type,
        timestamp: DateTime.now(),
      );

      // In a real implementation, this would send to Firebase/backend
      // For now, just emit the message back to simulate sending
      Future.delayed(const Duration(milliseconds: 100), () {
        _messageController.add(message);
      });

      return true;
    } catch (e) {
      LoggingService.error('Failed to send message', e, null, 'Communication');
      return false;
    }
  }

  /// Clean up resources
  void dispose() {
    _rtcService.dispose();
    _incomingCallController.close();
    _messageController.close();
  }
}
