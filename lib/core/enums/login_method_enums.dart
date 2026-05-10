enum LoginMethod {
  userName,
  pinCode,

}

extension ServiceTypeExtension on LoginMethod {
  int get value {
    switch (this) {
      case LoginMethod.userName:
        return 0;
      case LoginMethod.pinCode:
        return 1;
      }
  }



  String get name {
    switch (this) {
      case LoginMethod.userName:
        return 'username';
      case LoginMethod.pinCode:
        return 'pinCode';
      }
  }
}

LoginMethod getLoginMethod(String name) {
  switch (name) {
    case 'username':
      return LoginMethod.userName;
    case 'pinCode':
      return LoginMethod.pinCode;

    default:
      return LoginMethod.userName;
  }
}
