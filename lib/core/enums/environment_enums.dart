import 'package:kiosk_point_of_sale/core/helpers/app_pref.dart';

enum Environment {
  LocalHost,
  Production,
  Staging,
  Testing,
  Developing,
}

extension ServiceTypeExtension on Environment {
  int get value {
    switch (this) {
      case Environment.LocalHost:
        return 100;
      case Environment.Production:
        return 0;
      case Environment.Staging:
        return 1;
      case Environment.Testing:
        return 2;
      case Environment.Developing:
        return 3;
    }
  }

  Future<String> getV1BaseUrl() async {
    final String ip = await AppPreferences().getIp();

    switch (this) {
      case Environment.LocalHost:
        return ip;
      case Environment.Production:
        return "https://posapi.posmena.com";
      case Environment.Staging:
        return "https://stagingapi.posmena.com";
      case Environment.Testing:
        return "https://uatapi.posmena.com";
      case Environment.Developing:
        return "https://devapi.posmena.com";
    }
  }

  Future<String> getV2BaseUrl() async {
    final String ip = await AppPreferences().getIp();

    switch (this) {
      case Environment.LocalHost:
        return ip;
      case Environment.Production:
        return "https://food-api.posmena.com";
      case Environment.Staging:
        return "https://staging.food-api.posmena.com";
      case Environment.Testing:
        return "https://uat.food-api.posmena.com";
      case Environment.Developing:
        return "https://devapi.posmena.com";
    }
  }

  String get name {
    switch (this) {
      case Environment.LocalHost:
        return 'LocalHost';
      case Environment.Production:
        return 'Production';
      case Environment.Staging:
        return 'Staging';
      case Environment.Testing:
        return 'Testing';
      case Environment.Developing:
        return 'Developing';
    }
  }
}

Environment getEnvType(String name) {
  switch (name) {
    case 'LocalHost':
      return Environment.LocalHost;
    case 'Production':
      return Environment.Production;
    case 'Staging':
      return Environment.Staging;
    case 'Testing':
      return Environment.Testing;
    case 'Developing':
      return Environment.Developing;
    default:
      return Environment.Production;
  }
}
