class DeviceConfigModel {
  int? id;
  String tenantId;
  String? tenantIdZatca;
  String? usernameZatca;
  String? passwordZatca;
  String storeNumber;
  String deviceNumber;
  String? publicKey;
  String? privateKey;
  String companyName;
  String address;
  String vat;
  String? crNumber;
  String? terminalId;
  String? predefinedSequence;
  String? logo;
  String? storeCode;
  String? feedmenaAccountId;
  String? feedmenaAuthKey;
  String? zigsAccountId;
  String? zigsAuthKey;

  DeviceConfigModel({
    this.id,
    required this.tenantId,
    this.tenantIdZatca,
    this.usernameZatca,
    this.passwordZatca,
    required this.storeNumber,
    required this.deviceNumber,
    this.publicKey,
    this.privateKey,
    required this.companyName,
    required this.address,
    required this.vat,
    this.crNumber,
    required this.terminalId,
    this.predefinedSequence,
    this.logo,
    this.storeCode,
    this.feedmenaAccountId,
    this.feedmenaAuthKey,
    this.zigsAccountId,
    this.zigsAuthKey,
  });

  factory DeviceConfigModel.fromJson(Map<String, dynamic> json) {
    return DeviceConfigModel(
      id: json['id'],
      tenantId: json['tenant_id'],
      tenantIdZatca: json['tenant_id_zatca'],
      usernameZatca: json['username_zatca'],
      passwordZatca: json['password_zatca'],
      storeNumber: json['store_number'],
      deviceNumber: json['device_number'],
      publicKey: json['public_key'],
      privateKey: json['private_key'],
      companyName: json['company_name'],
      address: json['address'],
      vat: json['vat'],
      crNumber: json['cr_number'],
      terminalId: json['terminal_id'],
      logo: json['logo'],
      predefinedSequence: json['predefined_sequence'],
      storeCode: json['store_code'],
      feedmenaAccountId: json['feedmena_account_id'],
      feedmenaAuthKey: json['feedmena_auth_key'],
      zigsAccountId: json['zigs_account_id'],
      zigsAuthKey: json['zigs_auth_key'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tenant_id': tenantId,
      'tenant_id_zatca': tenantIdZatca,
      'username_zatca': usernameZatca,
      'password_zatca': passwordZatca,
      'store_number': storeNumber,
      'device_number': deviceNumber,
      'public_key': publicKey,
      'private_key': privateKey,
      'company_name': companyName,
      'address': address,
      'vat': vat,
      'cr_number': crNumber,
      'terminal_id': terminalId,
      'predefined_sequence': predefinedSequence,
      'logo': logo,
      'store_code': storeCode,
      'feedmena_account_id': feedmenaAccountId,
      'feedmena_auth_key': feedmenaAuthKey,
      'zigs_account_id': zigsAccountId,
      'zigs_auth_key': zigsAuthKey,
    };
  }
}
