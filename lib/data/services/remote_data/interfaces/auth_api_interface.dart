import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Interface for authentication-related API operations
abstract class AuthApiInterface {
  /// Authenticate user with username and password
  Future<(String token, int userId)> authenticateWithCredentials({
    required String username,
    required String password,
    required WidgetRef ref,
  });

  /// Authenticate user with PIN code
  Future<(String token, int userId)> authenticateWithPinCode({
    required String pinCode,
    required WidgetRef ref,
        bool isSupervisor = false,

  });

  /// Check if the current user is a supervisor
  Future<bool> checkIsSupervisor({
    required String token,
  });

  /// Logout the current user
  Future<void> logout();
}
