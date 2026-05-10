class CodingPatternSettingsModel {
  final int startValue;
  final int incrementValue;
  final String prefix;
  final String suffix;
  final int lastGeneratedValue;

  const CodingPatternSettingsModel({
    required this.startValue,
    required this.incrementValue,
    required this.prefix,
    required this.suffix,
    required this.lastGeneratedValue,
  });

  factory CodingPatternSettingsModel.fromMap(Map<String, dynamic> map) {
    return CodingPatternSettingsModel(
      startValue: map['startValue'] is int
          ? map['startValue'] as int
          : int.tryParse(map['startValue']?.toString() ?? '0') ?? 0,
      incrementValue: map['incrementvalue'] is int
          ? map['incrementvalue'] as int
          : int.tryParse(map['incrementvalue']?.toString() ?? '0') ?? 0,
      prefix: map['prefix']?.toString() ?? '',
      suffix: map['suffix']?.toString() ?? '',
      lastGeneratedValue: map['lastGeneratedValue'] is int
          ? map['lastGeneratedValue'] as int
          : int.tryParse(map['lastGeneratedValue']?.toString() ?? '0') ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'startValue': startValue,
      'incrementvalue': incrementValue,
      'prefix': prefix,
      'suffix': suffix,
      'lastGeneratedValue': lastGeneratedValue,
    };
  }
}
