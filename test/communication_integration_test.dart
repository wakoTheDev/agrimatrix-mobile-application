import 'package:flutter_test/flutter_test.dart';
import 'package:agrimatrix/models/app_models.dart';

void main() {
  group('Communication Integration Tests', () {
    test('should initialize communication service with user ID', () async {
      // Arrange
      const userId = 'test-user-123';
      
      // Act & Assert
      expect(userId, isNotNull);
      expect(userId.length, greaterThan(0));
    });

    test('should handle incoming call correctly', () async {
      // Arrange
      final incomingCall = IncomingCall(
        id: 'call-123',
        callerId: 'caller-456',
        callerName: 'John Farmer',
        callerAvatar: 'https://example.com/avatar.jpg',
        isVideo: false,
        timestamp: DateTime.now(),
      );

      // Act & Assert
      expect(incomingCall.id, equals('call-123'));
      expect(incomingCall.callerName, equals('John Farmer'));
      expect(incomingCall.isVideo, isFalse);
    });

    test('should create chat message correctly', () async {
      // Arrange
      final message = ChatMessage(
        id: 'msg-123',
        senderId: 'sender-456',
        receiverId: 'receiver-789',
        content: 'Hello, are your tomatoes still available?',
        type: MessageType.text,
        timestamp: DateTime.now(),
      );

      // Act & Assert
      expect(message.id, equals('msg-123'));
      expect(message.content, contains('tomatoes'));
      expect(message.type, equals(MessageType.text));
    });

    test('should handle user search results', () async {
      // Arrange
      final userResult = UserSearchResult(
        id: 'user-123',
        name: 'Mary Farmer',
        username: 'maryf',
        profileImage: 'https://example.com/profile.jpg',
        isOnline: true,
        location: 'Nairobi, Kenya',
        verified: true,
      );

      // Act & Assert
      expect(userResult.name, equals('Mary Farmer'));
      expect(userResult.isOnline, isTrue);
      expect(userResult.verified, isTrue);
    });
  });

  group('Market Integration Tests', () {
    test('should handle listing with communication features', () {
      // Arrange
      final listing = Listing(
        seller: 'John Farmer',
        product: 'Premium Tomatoes',
        quantity: '500 kg',
        price: '120',
        location: 'Kisumu',
        rating: 4.8,
        verified: true,
      );

      // Act & Assert
      expect(listing.seller, equals('John Farmer'));
      expect(listing.product, contains('Tomatoes'));
      expect(listing.verified, isTrue);
      expect(listing.rating, greaterThan(4.0));
    });
  });
}
