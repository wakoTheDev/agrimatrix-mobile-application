import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../services/enhanced_communication_service.dart';
import '../services/user_discovery_service.dart';
import '../models/app_models.dart';
import '../widgets/incoming_call_overlay.dart';
import '../screens/enhanced_chat_screen.dart';
import '../screens/call_screen.dart';
import '../services/web_helper.dart' as web;

class CommunicationWrapper extends StatefulWidget {
  final Widget child;

  const CommunicationWrapper({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  State<CommunicationWrapper> createState() => _CommunicationWrapperState();
}

class _CommunicationWrapperState extends State<CommunicationWrapper>
    with WidgetsBindingObserver {
  final EnhancedCommunicationService _communicationService = EnhancedCommunicationService();
  final UserDiscoveryService _userDiscovery = UserDiscoveryService();
  
  StreamSubscription<IncomingCall>? _incomingCallSubscription;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    
    // Delay communication initialization to prevent blocking the UI during app startup
    Future.delayed(const Duration(milliseconds: 300), () {
      // For web platform, we'll delay initialization or conditionally initialize
      // This helps prevent issues with WebRTC and other services that might not be fully supported
      if (!kIsWeb) {
        _initializeCommunication();
      } else {
        // For web, we'll just log that initialization was skipped
        debugPrint('Running on web platform - communication services initialization skipped');
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _incomingCallSubscription?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    // Only attempt to manage service state if it was successfully initialized
    if (_isInitialized && !kIsWeb) {
      switch (state) {
        case AppLifecycleState.resumed:
          // Handle resume - user presence is managed by the service internally
          break;
        case AppLifecycleState.paused:
        case AppLifecycleState.inactive:
        case AppLifecycleState.detached:
        case AppLifecycleState.hidden:
          // Handle background - user presence is managed by the service internally
          break;
      }
    }
  }

  Future<void> _initializeCommunication() async {
    try {
      // Check if we should initialize the communication service based on platform
      if (!web.shouldInitializeService('communication')) {
        debugPrint('Skipping communication service initialization based on platform constraints');
        return;
      }
      
      final currentUser = await _userDiscovery.getCurrentUser();
      if (currentUser != null) {
        await _communicationService.initialize(currentUser.id);
        
        // Listen for incoming calls
        _incomingCallSubscription = _communicationService.incomingCallStream.listen(
          _handleIncomingCall,
        );
        
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      debugPrint('Error initializing communication: $e');
      
      // Don't set _isInitialized to true if initialization failed
      // This will prevent lifecycle methods from attempting to use the services
    }
  }

  void _handleIncomingCall(IncomingCall incomingCall) {
    if (mounted) {
      CallOverlayManager.showIncomingCall(context, incomingCall);
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

// Extension to provide easy access to communication service from any widget
extension CommunicationContext on BuildContext {
  EnhancedCommunicationService get communication => EnhancedCommunicationService();
  UserDiscoveryService get userDiscovery => UserDiscoveryService();
  
  // Quick call actions
  Future<void> makeCall(String userId, CallType type) async {
    final userResult = await userDiscovery.getUserById(userId);
    if (userResult != null) {
      await communication.startCall(userId, type);
      
      if (mounted) {
        Navigator.of(this).push(
          MaterialPageRoute(
            builder: (context) => CallScreen(
              receiverId: userId,
              receiverName: userResult.name,
              receiverImage: userResult.profileImage,
              callType: type,
              isIncoming: false,
            ),
          ),
        );
      }
    }
  }
  
  Future<void> startChat(String userId) async {
    final userResult = await userDiscovery.getUserById(userId);
    if (userResult != null) {
      if (mounted) {
        Navigator.of(this).push(
          MaterialPageRoute(
            builder: (context) => ChatScreen(
              receiverId: userId,
              receiverName: userResult.name,
              receiverImage: userResult.profileImage,
            ),
          ),
        );
      }
    }
  }
}
