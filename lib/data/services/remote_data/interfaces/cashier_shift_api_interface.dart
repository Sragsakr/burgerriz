/// Interface for Cashier Shift related API operations
abstract class CashierShiftApiInterface {
  /// Start a new cashier shift
  Future<int?> startShift();

  /// Check if there is an opened shift
  Future<bool> isHaveOpenedShift();
}
