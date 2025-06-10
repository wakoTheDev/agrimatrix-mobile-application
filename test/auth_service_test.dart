import 'package:flutter_test/flutter_test.dart';
import 'package:agrimatrix/services/auth_service.dart';

void main() {
  group('AuthService Tests', () {
    test('AuthService initializes correctly', () {
      final authService = AuthService();
      expect(authService, isNotNull);
    });
  });
}
