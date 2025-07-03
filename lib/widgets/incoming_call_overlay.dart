import 'package:flutter/material.dart';
import 'dart:async';
import '../models/app_models.dart';
import '../services/enhanced_communication_service.dart';
import '../services/logging_service.dart';
import '../screens/call_screen.dart';

class IncomingCallOverlay extends StatefulWidget {
  final IncomingCall incomingCall;
  final VoidCallback onDismiss;

  const IncomingCallOverlay({
    super.key,
    required this.incomingCall,
    required this.onDismiss,
  });

  @override
  State<IncomingCallOverlay> createState() => _IncomingCallOverlayState();
}

class _IncomingCallOverlayState extends State<IncomingCallOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  
  final EnhancedCommunicationService _communicationService = EnhancedCommunicationService();
  Timer? _autoRejectTimer;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
    
    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
    
    _animationController.forward();
    
    // Auto-reject after 30 seconds
    _autoRejectTimer = Timer(const Duration(seconds: 30), () {
      _rejectCall();
    });
  }

  @override
  void dispose() {
    _autoRejectTimer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _acceptCall() async {
    _autoRejectTimer?.cancel();
    
    try {
      await _communicationService.acceptCall(widget.incomingCall.callId);
      
      if (mounted) {
        // Navigate to call screen
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => CallScreen(
              receiverId: widget.incomingCall.callerId,
              receiverName: widget.incomingCall.callerName,
              receiverImage: widget.incomingCall.callerImage,
              callType: widget.incomingCall.callType,
              isIncoming: true,
              callId: widget.incomingCall.callId,
            ),
          ),
        );
        
        widget.onDismiss();
      }
    } catch (e) {
      LoggingService.error('Error accepting call', e);
      _rejectCall();
    }
  }

  Future<void> _rejectCall() async {
    _autoRejectTimer?.cancel();
    
    try {
      await _communicationService.rejectCall(widget.incomingCall.callId);
    } catch (e) {
      LoggingService.error('Error rejecting call', e);
    }
    
    widget.onDismiss();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Opacity(
            opacity: _opacityAnimation.value,
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: _buildCallCard(),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCallCard() {
    return Container(
      margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header with caller info
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  widget.incomingCall.callType == CallType.video
                      ? Colors.blue
                      : Colors.green,
                  widget.incomingCall.callType == CallType.video
                      ? Colors.blue[700]!
                      : Colors.green[700]!,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(
                      widget.incomingCall.callType == CallType.video
                          ? Icons.videocam
                          : Icons.phone,
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      widget.incomingCall.callType == CallType.video
                          ? 'Incoming Video Call'
                          : 'Incoming Call',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundImage: widget.incomingCall.callerImage.isNotEmpty
                          ? NetworkImage(widget.incomingCall.callerImage)
                          : null,
                      child: widget.incomingCall.callerImage.isEmpty
                          ? Text(
                              widget.incomingCall.callerName.isNotEmpty
                                  ? widget.incomingCall.callerName[0].toUpperCase()
                                  : '?',
                              style: const TextStyle(
                                fontSize: 24,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.incomingCall.callerName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'AgriMatrix User',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Call controls
          Container(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Reject button
                GestureDetector(
                  onTap: _rejectCall,
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.call_end,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ),
                
                // Accept button
                GestureDetector(
                  onTap: _acceptCall,
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: const BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      widget.incomingCall.callType == CallType.video
                          ? Icons.videocam
                          : Icons.call,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CallOverlayManager {
  static OverlayEntry? _currentOverlay;
  static bool _isShowing = false;

  static void showIncomingCall(
    BuildContext context,
    IncomingCall incomingCall,
  ) {
    if (_isShowing) {
      hideCurrentCall();
    }

    _isShowing = true;
    _currentOverlay = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + 50,
        left: 0,
        right: 0,
        child: IncomingCallOverlay(
          incomingCall: incomingCall,
          onDismiss: hideCurrentCall,
        ),
      ),
    );

    Overlay.of(context).insert(_currentOverlay!);
  }

  static void hideCurrentCall() {
    if (_currentOverlay != null) {
      _currentOverlay!.remove();
      _currentOverlay = null;
      _isShowing = false;
    }
  }

  static bool get isShowing => _isShowing;
}
