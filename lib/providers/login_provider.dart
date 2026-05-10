import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthModel {
  final String username;
  final String password;
  final String pinCode;
  final String tenantId;

  AuthModel({
    this.username = '',
    this.password = '',
    this.pinCode = '',
    this.tenantId = '',
  });

  AuthModel copyWith({
    String? tenantId,
    String? username,
    String? password,
    String? pinCode,
  }) {
    return AuthModel(
      tenantId: tenantId ?? this.tenantId,
      username: username ?? this.username,
      password: password ?? this.password,
      pinCode: pinCode ?? this.pinCode,
    );
  }
}

// Now the usage becomes cleaner:
final authProvider = StateProvider<AuthModel>((ref) {
  return AuthModel();
});
