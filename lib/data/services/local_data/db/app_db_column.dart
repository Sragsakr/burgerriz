class DbColumn {
  String columnName;
  String columnType;
  int isPrimary; // 1 إذا كان مفتاحًا أساسيًا
  int? isUnique; // 1 إذا كان مفتاحًا أساسيًا
  String?
      foreignKey; // لدعم المفاتيح الأجنبية (null إذا لم يكن مفتاحًا أجنبيًا)

  DbColumn({
    required this.columnName,
    required this.columnType,
    required this.isPrimary,
    this.foreignKey,
    this.isUnique,
  });

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({'name': columnName});
    result.addAll({'type': columnType});
    result.addAll({'pk': isPrimary});
    if (foreignKey != null) {
      result.addAll({'foreignKey': foreignKey});
    }
    if (isUnique != null) {
      result.addAll({'isUnique': isUnique});
    }

    return result;
  }

  factory DbColumn.fromMap(map) {
    return DbColumn(
      columnName: map['name'] ?? '',
      columnType: map['type'] ?? '',
      isPrimary: map['pk']?.toInt() ?? 0,
      foreignKey: map['foreignKey'],
      isUnique: map['isUnique'],
    );
  }

  @override
  String toString() =>
      '(columnName: $columnName, columnType: $columnType, isPrimary: $isPrimary, foreignKey: $foreignKey)';
}
