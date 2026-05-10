class CustomerAddressModel {
  int? tableId;
  final int id;
  final String city;
  final String customerId;
  final String address;
  final String? link;
  final int deliveryZoneId;
  final String? zoneName;
  final String? zoneNameId;
  final int deliveryStreetId;
  final String? streetName;
  final String? streetNameId;
  final bool isSelected;

  CustomerAddressModel({
    this.tableId,
    required this.id,
    required this.city,
    required this.customerId,
    required this.address,
    this.link,
    required this.deliveryZoneId,
    this.zoneName,
    this.zoneNameId,
    required this.deliveryStreetId,
    this.streetName,
    this.streetNameId,
    required this.isSelected,
  });

  // Factory method to create a CustomerAddressModel object from JSON
  factory CustomerAddressModel.fromMap(Map<String, dynamic> json) {
    return CustomerAddressModel(
      tableId: json['tableId'],
      id: json['id'] ?? 0,
      city: json['city'] ?? '',
      customerId: json['customerId'] ?? '',
      address: json['address'] ?? '',
      link: json['link'],
      deliveryZoneId: json['deliveryZoneId'] ?? 0,
      zoneName: json['zoneName'],
      zoneNameId: json['zoneNameId'],
      deliveryStreetId: json['deliveryStreetId'] ?? 0,
      streetName: json['streetName'],
      streetNameId: json['streetNameId'],
      isSelected: json['isSelected'] ?? false,
    );
  }

  // Method to convert a CustomerAddressModel object to JSON
  Map<String, dynamic> toMap() {
    return {
      if (tableId != null) 'tableId': tableId,
      'id': id,
      'city': city,
      'customerId': customerId,
      'address': address,
      'link': link,
      'deliveryZoneId': deliveryZoneId,
      'zoneName': zoneName,
      'zoneNameId': zoneNameId,
      'deliveryStreetId': deliveryStreetId,
      'streetName': streetName,
      'streetNameId': streetNameId,
      'isSelected': isSelected ? 1 : 0,
    };
  }

  // Method to convert to map for database operations
  Map<String, dynamic> toDbMap() {
    return {
      if (tableId != null) 'tableId': tableId,
      'id': id,
      'city': city,
      'customerId': customerId,
      'address': address,
      'link': link,
      'deliveryZoneId': deliveryZoneId,
      'zoneName': zoneName,
      'zoneNameId': zoneNameId,
      'deliveryStreetId': deliveryStreetId,
      'streetName': streetName,
      'streetNameId': streetNameId,
      'isSelected': isSelected ? 1 : 0,
    };
  }

  // Factory method to create from database map
  factory CustomerAddressModel.fromDbMap(Map<String, dynamic> json) {
    return CustomerAddressModel(
      tableId: json['tableId'],
      id: json['id'] ?? 0,
      city: json['city'] ?? '',
      customerId: json['customerId'] ?? '',
      address: json['address'] ?? '',
      link: json['link'],
      deliveryZoneId: json['deliveryZoneId'] ?? 0,
      zoneName: json['zoneName'],
      zoneNameId: json['zoneNameId'],
      deliveryStreetId: json['deliveryStreetId'] ?? 0,
      streetName: json['streetName'],
      streetNameId: json['streetNameId'],
      isSelected: json['isSelected'] == 1,
    );
  }

  CustomerAddressModel copyWith({
    int? tableId,
    int? id,
    String? city,
    String? customerId,
    String? address,
    String? link,
    int? deliveryZoneId,
    String? zoneName,
    String? zoneNameId,
    int? deliveryStreetId,
    String? streetName,
    String? streetNameId,
    bool? isSelected,
  }) {
    return CustomerAddressModel(
      tableId: tableId ?? this.tableId,
      id: id ?? this.id,
      city: city ?? this.city,
      customerId: customerId ?? this.customerId,
      address: address ?? this.address,
      link: link ?? this.link,
      deliveryZoneId: deliveryZoneId ?? this.deliveryZoneId,
      zoneName: zoneName ?? this.zoneName,
      zoneNameId: zoneNameId ?? this.zoneNameId,
      deliveryStreetId: deliveryStreetId ?? this.deliveryStreetId,
      streetName: streetName ?? this.streetName,
      streetNameId: streetNameId ?? this.streetNameId,
      isSelected: isSelected ?? this.isSelected,
    );
  }
} 