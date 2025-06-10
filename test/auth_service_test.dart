import 'package:flutter_test/flutter_test.dart';
import 'package:agrimatrix/services/auth_service.dart';

void main() {
  group('AuthService Tests', () {
    test('isGuest should be true initially', () {
      final authService = AuthService();
      expect(authService.isGuest, true);
    });

    test('currentUser should be null initially', () {
      final authService = AuthService();
      expect(authService.currentUser, null);
    });
  });
}
