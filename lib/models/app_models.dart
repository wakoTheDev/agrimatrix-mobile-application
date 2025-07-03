// Export shared models
export 'market_models.dart';
export 'call_models.dart';

// Message model for chat functionality
class ChatMessage {
  final String id;
  final String senderId;
  final String receiverId;
  final String content;
  final MessageType type;
  final DateTime timestamp;
  final bool isRead;
  final String? filePath;
  final String? fileName;

  ChatMessage({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.content,
    required this.type,
    required this.timestamp,
    this.isRead = false,
    this.filePath,
    this.fileName,
  });
}

enum MessageType { text, image, video, audio, file }

// Enhanced Listing model
class EnhancedListing {
  final String id;
  final String sellerId;
  final String sellerName;
  final String product;
  final String description;
  final double quantity;
  final String unit;
  final double pricePerUnit;
  final String location;
  final double latitude;
  final double longitude;
  final List<String> images;
  final String grade;
  final bool isOrganic;
  final DateTime postedDate;
  final DateTime? expiryDate;
  final double rating;
  final bool verified;
  final String phone;
  final ListingStatus status;
  final String category;

  EnhancedListing({
    required this.id,
    required this.sellerId,
    required this.sellerName,
    required this.product,
    required this.description,
    required this.quantity,
    required this.unit,
    required this.pricePerUnit,
    required this.location,
    required this.latitude,
    required this.longitude,
    required this.images,
    required this.grade,
    required this.isOrganic,
    required this.postedDate,
    this.expiryDate,
    required this.rating,
    required this.verified,
    required this.phone,
    required this.status,
    required this.category,
  });
}

enum ListingStatus { active, sold, expired, suspended }

// User model for chat and calling
class AppUser {
  final String id;
  final String name;
  final String phone;
  final String email;
  final String profileImage;
  final bool isOnline;
  final DateTime lastSeen;
  final bool verified;

  AppUser({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.profileImage,
    required this.isOnline,
    required this.lastSeen,
    required this.verified,
  });
}

// Basic listing model for backward compatibility
class Listing {
  final String seller;
  final String product;
  final String quantity;
  final String price;
  final String location;
  final double rating;
  final bool verified;

  Listing({
    required this.seller,
    required this.product,
    required this.quantity,
    required this.price,
    required this.location,
    required this.rating,
    required this.verified,
  });
}

// Use call_models.dart for all call-related functionality

class Chat {
  final String id;
  final List<String> participants;
  final String lastMessage;
  final DateTime lastMessageTime;
  final String lastMessageSenderId;
  final int unreadCount;
  final Map<String, dynamic> participantInfo;

  Chat({
    required this.id,
    required this.participants,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.lastMessageSenderId,
    required this.unreadCount,
    required this.participantInfo,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'participants': participants,
    'lastMessage': lastMessage,
    'lastMessageTime': lastMessageTime.millisecondsSinceEpoch,
    'lastMessageSenderId': lastMessageSenderId,
    'unreadCount': unreadCount,
    'participantInfo': participantInfo,
  };

  factory Chat.fromJson(Map<String, dynamic> json) => Chat(
    id: json['id'],
    participants: List<String>.from(json['participants']),
    lastMessage: json['lastMessage'],
    lastMessageTime: DateTime.fromMillisecondsSinceEpoch(json['lastMessageTime']),
    lastMessageSenderId: json['lastMessageSenderId'],
    unreadCount: json['unreadCount'],
    participantInfo: json['participantInfo'],
  );
}

class UserSearchResult {
  final String id;
  final String name;
  final String username;
  final String profileImage;
  final bool isOnline;
  final bool verified;
  final String location;

  UserSearchResult({
    required this.id,
    required this.name,
    required this.username,
    required this.profileImage,
    required this.isOnline,
    required this.verified,
    required this.location,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'username': username,
    'profileImage': profileImage,
    'isOnline': isOnline,
    'verified': verified,
    'location': location,
  };

  factory UserSearchResult.fromJson(Map<String, dynamic> json) => UserSearchResult(
    id: json['id'],
    name: json['name'],
    username: json['username'],
    profileImage: json['profileImage'],
    isOnline: json['isOnline'],
    verified: json['verified'],
    location: json['location'],
  );
}
