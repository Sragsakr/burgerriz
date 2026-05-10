class AuthenticationRequest {
  final String usernameOrEmailAddress;
  final String password;

  AuthenticationRequest({
    required this.usernameOrEmailAddress,
    required this.password,
  });

  Map<String, dynamic> toMap() {
    return {
      "UserNameOrEmailAddress": usernameOrEmailAddress,
      "Password": password,
    };
  }
}
