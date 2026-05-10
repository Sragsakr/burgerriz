class KdsDevice {
  final String id;
  final String name;
  final String ip;
  final List<String> selectedCategories;

  KdsDevice({
    required this.id,
    required this.name,
    required this.ip,
    required this.selectedCategories,
  });

  factory KdsDevice.fromJson(Map<String, dynamic> json) {
    return KdsDevice(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      ip: json['ip'] ?? '',
      selectedCategories: List<String>.from(json['selectedCategories'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'ip': ip,
      'selectedCategories': selectedCategories,
    };
  }

  KdsDevice copyWith({
    String? id,
    String? name,
    String? ip,
    List<String>? selectedCategories,
  }) {
    return KdsDevice(
      id: id ?? this.id,
      name: name ?? this.name,
      ip: ip ?? this.ip,
      selectedCategories: selectedCategories ?? this.selectedCategories,
    );
  }

  @override
  String toString() {
    return 'KdsDevice(id: $id, name: $name, ip: $ip, selectedCategories: $selectedCategories)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is KdsDevice &&
        other.id == id &&
        other.name == name &&
        other.ip == ip &&
        other.selectedCategories.toString() == selectedCategories.toString();
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        ip.hashCode ^
        selectedCategories.hashCode;
  }
}
