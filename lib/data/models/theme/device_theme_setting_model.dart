class DeviceThemeSettingModel {
  final int id;
  final String pageName;
  final bool isActive;
  final String? backgoundColor;
  final String? forgroundColor;
  final String? fontColor;
  final double? fontSize;
  final String? fontFamily;

  const DeviceThemeSettingModel({
    required this.id,
    required this.pageName,
    required this.isActive,
    required this.backgoundColor,
    required this.forgroundColor,
    required this.fontColor,
    required this.fontSize,
    required this.fontFamily,
  });

  factory DeviceThemeSettingModel.fromMap(Map<String, dynamic> map) {
    return DeviceThemeSettingModel(
      id: (map['id'] as num?)?.toInt() ?? 0,
      pageName: map['pageName']?.toString() ?? '',
      isActive: map['isActive'] == true,
      backgoundColor: map['backgoundColor']?.toString(),
      forgroundColor: map['forgroundColor']?.toString(),
      fontColor: map['fontColor']?.toString(),
      fontSize: (map['fontSize'] as num?)?.toDouble(),
      fontFamily: map['fontFamily']?.toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'pageName': pageName,
      'isActive': isActive,
      'backgoundColor': backgoundColor,
      'forgroundColor': forgroundColor,
      'fontColor': fontColor,
      'fontSize': fontSize,
      'fontFamily': fontFamily,
    };
  }
}
