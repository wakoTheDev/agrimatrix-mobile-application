
enum CallState {
  idle,
  calling,
  ringing,
  connecting,
  connected,
  reconnecting,
  disconnected,
  ended,
  rejected,
  failed,
  timeout,
}

enum CallType {
  audio,
  video,
}

class IncomingCall {
  final String id;
  final String callerId;
  final String callerName;
  final String? callerAvatar;
  final bool isVideo;
  final DateTime timestamp;

  // Additional properties needed by the overlay widget
  String get callId => id;
  String get callerImage => callerAvatar ?? '';
  CallType get callType => isVideo ? CallType.video : CallType.audio;

  IncomingCall({
    required this.id,
    required this.callerId,
    required this.callerName,
    this.callerAvatar,
    required this.isVideo,
    required this.timestamp,
  });

  factory IncomingCall.fromMap(Map<String, dynamic> map) {
    return IncomingCall(
      id: map['id'] ?? '',
      callerId: map['callerId'] ?? '',
      callerName: map['callerName'] ?? '',
      callerAvatar: map['callerAvatar'],
      isVideo: map['isVideo'] ?? false,
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] ?? 0),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'callerId': callerId,
      'callerName': callerName,
      'callerAvatar': callerAvatar,
      'isVideo': isVideo,
      'timestamp': timestamp.millisecondsSinceEpoch,
    };
  }
}

class CallParticipant {
  final String id;
  final String name;
  final String? avatar;
  final bool isOnline;
  final bool isMuted;
  final bool isVideoEnabled;

  CallParticipant({
    required this.id,
    required this.name,
    this.avatar,
    this.isOnline = true,
    this.isMuted = false,
    this.isVideoEnabled = true,
  });

  factory CallParticipant.fromMap(Map<String, dynamic> map) {
    return CallParticipant(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      avatar: map['avatar'],
      isOnline: map['isOnline'] ?? true,
      isMuted: map['isMuted'] ?? false,
      isVideoEnabled: map['isVideoEnabled'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'avatar': avatar,
      'isOnline': isOnline,
      'isMuted': isMuted,
      'isVideoEnabled': isVideoEnabled,
    };
  }

  CallParticipant copyWith({
    String? id,
    String? name,
    String? avatar,
    bool? isOnline,
    bool? isMuted,
    bool? isVideoEnabled,
  }) {
    return CallParticipant(
      id: id ?? this.id,
      name: name ?? this.name,
      avatar: avatar ?? this.avatar,
      isOnline: isOnline ?? this.isOnline,
      isMuted: isMuted ?? this.isMuted,
      isVideoEnabled: isVideoEnabled ?? this.isVideoEnabled,
    );
  }
}

class CallRecord {
  final String id;
  final String callerId;
  final String callerName;
  final String receiverId;
  final String receiverName;
  final CallType type;
  final DateTime startTime;
  final DateTime? endTime;
  final Duration? duration;
  final CallState finalState;
  final bool isIncoming;

  CallRecord({
    required this.id,
    required this.callerId,
    required this.callerName,
    required this.receiverId,
    required this.receiverName,
    required this.type,
    required this.startTime,
    this.endTime,
    this.duration,
    required this.finalState,
    required this.isIncoming,
  });

  factory CallRecord.fromMap(Map<String, dynamic> map) {
    return CallRecord(
      id: map['id'] ?? '',
      callerId: map['callerId'] ?? '',
      callerName: map['callerName'] ?? '',
      receiverId: map['receiverId'] ?? '',
      receiverName: map['receiverName'] ?? '',
      type: CallType.values.firstWhere(
        (e) => e.toString() == 'CallType.${map['type']}',
        orElse: () => CallType.audio,
      ),
      startTime: DateTime.fromMillisecondsSinceEpoch(map['startTime'] ?? 0),
      endTime: map['endTime'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(map['endTime'])
          : null,
      duration: map['duration'] != null 
          ? Duration(milliseconds: map['duration'])
          : null,
      finalState: CallState.values.firstWhere(
        (e) => e.toString() == 'CallState.${map['finalState']}',
        orElse: () => CallState.ended,
      ),
      isIncoming: map['isIncoming'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'callerId': callerId,
      'callerName': callerName,
      'receiverId': receiverId,
      'receiverName': receiverName,
      'type': type.toString().split('.').last,
      'startTime': startTime.millisecondsSinceEpoch,
      'endTime': endTime?.millisecondsSinceEpoch,
      'duration': duration?.inMilliseconds,
      'finalState': finalState.toString().split('.').last,
      'isIncoming': isIncoming,
    };
  }

  String get durationString {
    if (duration == null) return '00:00';
    
    final minutes = duration!.inMinutes;
    final seconds = duration!.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  String get statusText {
    switch (finalState) {
      case CallState.ended:
        return duration != null ? durationString : 'Ended';
      case CallState.rejected:
        return 'Declined';
      case CallState.failed:
        return 'Failed';
      case CallState.timeout:
        return 'Missed';
      default:
        return 'Unknown';
    }
  }
}

// WebRTC signaling message types
enum SignalingType {
  offer,
  answer,
  iceCandidate,
  endCall,
}

class SignalingMessage {
  final SignalingType type;
  final Map<String, dynamic> data;
  final String fromUserId;
  final String toUserId;
  final String callId;

  SignalingMessage({
    required this.type,
    required this.data,
    required this.fromUserId,
    required this.toUserId,
    required this.callId,
  });

  factory SignalingMessage.fromMap(Map<String, dynamic> map) {
    return SignalingMessage(
      type: SignalingType.values.firstWhere(
        (e) => e.toString() == 'SignalingType.${map['type']}',
        orElse: () => SignalingType.offer,
      ),
      data: Map<String, dynamic>.from(map['data'] ?? {}),
      fromUserId: map['fromUserId'] ?? '',
      toUserId: map['toUserId'] ?? '',
      callId: map['callId'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'type': type.toString().split('.').last,
      'data': data,
      'fromUserId': fromUserId,
      'toUserId': toUserId,
      'callId': callId,
    };
  }
}

// User presence for call availability
class UserPresence {
  final String userId;
  final bool isOnline;
  final bool isAvailable;
  final bool inCall;
  final DateTime lastSeen;

  UserPresence({
    required this.userId,
    required this.isOnline,
    required this.isAvailable,
    required this.inCall,
    required this.lastSeen,
  });

  factory UserPresence.fromMap(Map<String, dynamic> map) {
    return UserPresence(
      userId: map['userId'] ?? '',
      isOnline: map['isOnline'] ?? false,
      isAvailable: map['isAvailable'] ?? false,
      inCall: map['inCall'] ?? false,
      lastSeen: DateTime.fromMillisecondsSinceEpoch(map['lastSeen'] ?? 0),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'isOnline': isOnline,
      'isAvailable': isAvailable,
      'inCall': inCall,
      'lastSeen': lastSeen.millisecondsSinceEpoch,
    };
  }

  String get statusText {
    if (inCall) return 'In call';
    if (!isOnline) return 'Last seen ${_formatLastSeen()}';
    if (!isAvailable) return 'Away';
    return 'Online';
  }

  String _formatLastSeen() {
    final now = DateTime.now();
    final difference = now.difference(lastSeen);

    if (difference.inMinutes < 1) {
      return 'just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}
