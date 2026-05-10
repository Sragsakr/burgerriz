/// Interface for Plugin Sync Log API operations
abstract class PluginSyncLogApiInterface {
  /// Creates a new plugin sync log entry
  ///

  /// [date] - The date and time of the sync log (ISO 8601 format)
  ///
  /// Returns the integer ID of the newly created log entry
  Future<void> createPluginSyncLog({
    required String date,
  });
}
