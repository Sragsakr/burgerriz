import 'package:kiosk_point_of_sale/core/enums/environment_enums.dart';
import 'package:kiosk_point_of_sale/main.dart';

class InstallOptionModel {
  final String name;
  final String nameLoalized;
  final String value;

  InstallOptionModel(
      {required this.name, required this.nameLoalized, required this.value});
}

final context = navKey.currentState!.context;

List<InstallOptionModel> languageOptions = [
  InstallOptionModel(name: 'Arabic', nameLoalized: 'العربية', value: 'ar'),
  InstallOptionModel(name: 'English', nameLoalized: 'الإنجليزية', value: 'en'),
];
List<InstallOptionModel> versionOptions = [
  InstallOptionModel(name: 'v1', nameLoalized: 'v1', value: 'v1'),
  InstallOptionModel(name: 'v2', nameLoalized: 'v2', value: 'v2'),
];
List<InstallOptionModel> loginMethodOptions = [
  // InstallOptionModel(
  //     name: 'User Name  and Password',
  //     nameLoalized: 'اسم المستخدم وكلمة المرور',
  //     value: 'username'),
  InstallOptionModel(
      name: 'Pin Code', nameLoalized: 'رمز PIN', value: 'pinCode'),
];
List<InstallOptionModel> naturalOptions = [
  InstallOptionModel(
      name: 'Local Host',
      nameLoalized: 'محلي',
      value: Environment.LocalHost.name.toString()),
  InstallOptionModel(
      name: 'Production',
      nameLoalized: 'إنتاج',
      value: Environment.Production.name.toString()),
  InstallOptionModel(
      name: 'Staging',
      nameLoalized: 'تحضير',
      value: Environment.Staging.name.toString()),
  InstallOptionModel(
      name: 'Testing',
      nameLoalized: 'اختبار',
      value: Environment.Testing.name.toString()),
  InstallOptionModel(
      name: 'Developing',
      nameLoalized: 'تطوير',
      value: Environment.Developing.name.toString()),
];
List<InstallOptionModel> timeZoneOptions = [
  InstallOptionModel(name: '3', nameLoalized: '3', value: '3'),
  InstallOptionModel(name: '2', nameLoalized: '2', value: '2'),
  InstallOptionModel(name: '1', nameLoalized: '1', value: '1'),
  InstallOptionModel(name: '0', nameLoalized: '0', value: '0'),
  InstallOptionModel(name: '-1', nameLoalized: '-1', value: '-1'),
  InstallOptionModel(name: '-2', nameLoalized: '-2', value: '-2'),
  InstallOptionModel(name: '-3', nameLoalized: '-3', value: '-3'),
];
