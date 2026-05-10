import 'dart:convert';

class CashierShift {
  int? id;
  int? cashierShiftId;
  int? endOfDayID;
  String? startOfDayTiming;
  String? endOfDayTiming;
  String? date;
  int status;
  int syncStatus;
  int dayStatus;
  int cashierStatus;
  bool isValid;
  bool canLogin;
  String? startOfDayDate;
  String? endOfDayDate;
  bool isActiveEndOfDay;
  int? tableId; // New optional field
  CashierShift({
    this.id,
    this.cashierShiftId,
    this.endOfDayID,
    this.startOfDayTiming,
    this.endOfDayTiming,
    this.date,
    required this.status,
    required this.syncStatus,
    required this.dayStatus,
    required this.cashierStatus,
    required this.isValid,
    required this.canLogin,
    this.startOfDayDate,
    this.endOfDayDate,
    required this.isActiveEndOfDay,
    this.tableId, // New optional field
  });

  /// **Factory constructor to create an object from a Map (SQLite)**
  factory CashierShift.fromMap(Map<String, dynamic> json) => CashierShift(
        id: json["id"],
        cashierShiftId: json["cashierShiftId"],
        endOfDayID: json["endOfDayID"],
        startOfDayTiming: json["startOfDayTiming"],
        endOfDayTiming: json["endOfDayTiming"],
        date: json["date"],
        status: json["status"],
        syncStatus: json["syncStatus"],
        dayStatus: json["dayStatus"],
        cashierStatus: json["cashierStatus"],
        isValid: json["isValid"] == 1, // SQLite stores bool as int (1/0)
        canLogin: json["canLogin"] == 1,
        startOfDayDate: json["startOfDayDate"],
        endOfDayDate: json["endOfDayDate"],
        isActiveEndOfDay: json["isActiveEndOfDay"] == 1,
        tableId: json["tableId"], // New field
      );

  /// **Convert the object to a Map (for SQLite)**
  Map<String, dynamic> toMap() => {
        "id": id,
        "cashierShiftId": cashierShiftId,
        "endOfDayID": endOfDayID,
        "startOfDayTiming": startOfDayTiming,
        "endOfDayTiming": endOfDayTiming,
        "date": date,
        "status": status,
        "syncStatus": syncStatus,
        "dayStatus": dayStatus,
        "cashierStatus": cashierStatus,
        "isValid": isValid ? 1 : 0, // Convert bool to int
        "canLogin": canLogin ? 1 : 0,
        "startOfDayDate": startOfDayDate,
        "endOfDayDate": endOfDayDate,
        "isActiveEndOfDay": isActiveEndOfDay ? 1 : 0,
        "tableId": tableId, // New field
      };

  /// **Factory constructor to create an object from a JSON string**
  factory CashierShift.fromJson(Map<String, dynamic> json) => CashierShift(
        id: json["id"],
        cashierShiftId: json["cashierShiftId"],
        endOfDayID: json["endOfDayID"],
        startOfDayTiming: json["startOfDayTiming"],
        endOfDayTiming: json["endOfDayTiming"],
        date: json["date"],
        status: json["status"],
        syncStatus: json["syncStatus"],
        dayStatus: json["dayStatus"],
        cashierStatus: json["cashierStatus"],
        isValid: json["isValid"], // SQLite stores bool as int (1/0)
        canLogin: json["canLogin"],
        startOfDayDate: json["startOfDayDate"],
        endOfDayDate: json["endOfDayDate"],
        isActiveEndOfDay: json["isActiveEndOfDay"],
        tableId: json["tableId"], // New field
      );

  /// **Convert the object to a JSON string**
  String toJson() => json.encode(toMap());
}
