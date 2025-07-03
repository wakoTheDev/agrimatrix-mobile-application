import 'package:flutter/material.dart';
import 'dart:async';
import '../services/enhanced_communication_service.dart';
import '../models/app_models.dart';

class CallScreen extends StatefulWidget {
  final String receiverId;
  final String receiverName;
  final String? receiverImage;
  final CallType callType;
  final bool isIncoming;
  final String? callId;

  const CallScreen({
    super.key,
    required this.receiverId,
    required this.receiverName,
    this.receiverImage,
    required this.callType,
    required this.isIncoming,
    this.callId,
  });

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  final EnhancedCommunicationService _communicationService = EnhancedCommunicationService();
  
  bool _isMuted = false;
  bool _isCameraOff = false;
  bool _isSpeakerOn = false;
  CallState _callState = CallState.idle;
  Timer? _callTimer;
  Duration _callDuration = Duration.zero;
  
  StreamSubscription<CallState>? _callStateSubscription;

  @override
  void initState() {
    super.initState();
    _setupCall();
  }

  Future<void> _setupCall() async {
    _callStateSubscription = _communicationService.callStateStream.listen((state) {
      setState(() {
        _callState = state;
      });
      
      if (state == CallState.connected) {
        _startCallTimer();
      } else if (state == CallState.ended || state == CallState.failed) {
        _endCall();
      }
    });

    if (widget.isIncoming) {
      setState(() {
        _callState = CallState.ringing;
      });
    } else {
      await _communicationService.startCall(widget.receiverId, widget.callType);
    }
  }

  void _startCallTimer() {
    _callTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _callDuration = Duration(seconds: timer.tick);
      });
    });
  }

  Future<void> _acceptCall() async {
    if (widget.callId != null) {
      await _communicationService.acceptCall(widget.callId!);
    }
  }

  Future<void> _rejectCall() async {
    if (widget.callId != null) {
      await _communicationService.rejectCall(widget.callId!);
    }
    Navigator.of(context).pop();
  }

  Future<void> _endCall() async {
    await _communicationService.endCall();
    _callTimer?.cancel();
    Navigator.of(context).pop();
  }

  void _toggleMute() {
    setState(() {
      _isMuted = !_isMuted;
    });
    _communicationService.toggleMute(_isMuted);
  }

  void _toggleCamera() {
    setState(() {
      _isCameraOff = !_isCameraOff;
    });
    _communicationService.toggleCamera(_isCameraOff);
  }

  void _toggleSpeaker() {
    setState(() {
      _isSpeakerOn = !_isSpeakerOn;
    });
    _communicationService.toggleSpeaker(_isSpeakerOn);
  }

  @override
  void dispose() {
    _callStateSubscription?.cancel();
    _callTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Call info header
            Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: widget.callType == CallType.video ? 40 : 60,
                    backgroundImage: widget.receiverImage != null && widget.receiverImage!.isNotEmpty
                        ? NetworkImage(widget.receiverImage!)
                        : null,
                    child: widget.receiverImage == null || widget.receiverImage!.isEmpty
                        ? Text(
                            widget.receiverName.isNotEmpty ? widget.receiverName[0].toUpperCase() : 'U',
                            style: TextStyle(
                              fontSize: widget.callType == CallType.video ? 24 : 36,
                              color: Colors.white,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.receiverName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _getCallStateText(),
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                  if (_callState == CallState.connected)
                    Text(
                      _formatDuration(_callDuration),
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                ],
              ),
            ),
            
            // Video view for video calls
            if (widget.callType == CallType.video)
              Expanded(
                child: Stack(
                  children: [
                    // Remote video placeholder (full screen)
                    Container(
                      width: double.infinity,
                      height: double.infinity,
                      color: Colors.grey[800],
                      child: const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.videocam_off, size: 64, color: Colors.white54),
                            SizedBox(height: 16),
                            Text(
                              'Video calling feature\ncoming soon',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.white54, fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    // Local video placeholder (small overlay)
                    Positioned(
                      top: 20,
                      right: 20,
                      child: Container(
                        width: 120,
                        height: 160,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white, width: 2),
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.grey[700],
                        ),
                        child: const Center(
                          child: Icon(Icons.person, size: 32, color: Colors.white54),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            else
              const Expanded(child: SizedBox()),
            
            // Call controls
            Container(
              padding: const EdgeInsets.all(20),
              child: widget.isIncoming && _callState == CallState.ringing
                  ? _buildIncomingCallControls()
                  : _buildCallControls(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIncomingCallControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Reject call
        Container(
          decoration: const BoxDecoration(
            color: Colors.red,
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(Icons.call_end, color: Colors.white, size: 30),
            onPressed: _rejectCall,
            iconSize: 60,
          ),
        ),
        
        // Accept call
        Container(
          decoration: const BoxDecoration(
            color: Colors.green,
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(Icons.call, color: Colors.white, size: 30),
            onPressed: _acceptCall,
            iconSize: 60,
          ),
        ),
      ],
    );
  }

  Widget _buildCallControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Mute/Unmute
        Container(
          decoration: BoxDecoration(
            color: _isMuted ? Colors.red.withValues(alpha:  0.8) : Colors.white.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: Icon(
              _isMuted ? Icons.mic_off : Icons.mic,
              color: Colors.white,
            ),
            onPressed: _toggleMute,
            iconSize: 30,
          ),
        ),
        
        // Speaker (audio calls only)
        if (widget.callType == CallType.audio)
          Container(
            decoration: BoxDecoration(
              color: _isSpeakerOn ? Colors.blue.withValues(alpha: 0.8) : Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(
                _isSpeakerOn ? Icons.volume_up : Icons.volume_down,
                color: Colors.white,
              ),
              onPressed: _toggleSpeaker,
              iconSize: 30,
            ),
          ),
        
        // Camera (video calls only)
        if (widget.callType == CallType.video)
          Container(
            decoration: BoxDecoration(
              color: _isCameraOff ? Colors.red.withValues(alpha: 0.8) : Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(
                _isCameraOff ? Icons.videocam_off : Icons.videocam,
                color: Colors.white,
              ),
              onPressed: _toggleCamera,
              iconSize: 30,
            ),
          ),
        
        // End call
        Container(
          decoration: const BoxDecoration(
            color: Colors.red,
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(Icons.call_end, color: Colors.white),
            onPressed: _endCall,
            iconSize: 30,
          ),
        ),
      ],
    );
  }

  String _getCallStateText() {
    switch (_callState) {
      case CallState.idle:
        return 'Preparing call...';
      case CallState.calling:
        return 'Calling...';
      case CallState.ringing:
        return widget.isIncoming ? 'Incoming call' : 'Ringing...';
      case CallState.connecting:
        return 'Connecting...';
      case CallState.connected:
        return 'Connected';
      case CallState.reconnecting:
        return 'Reconnecting...';
      case CallState.disconnected:
        return 'Disconnected';
      case CallState.ended:
        return 'Call ended';
      case CallState.rejected:
        return 'Call rejected';
      case CallState.failed:
        return 'Connection failed';
      case CallState.timeout:
        return 'Call timed out';
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    
    if (duration.inHours > 0) {
      return '$hours:$minutes:$seconds';
    } else {
      return '$minutes:$seconds';
    }
  }
}
