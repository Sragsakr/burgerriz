/// Interface for feedback-related API operations
abstract class FeedbackApiInterface {
  /// Send a feedback request to the API
  ///
  /// [phoneNumber] - The customer's phone number
  ///
  /// Returns the response body as a string if successful, null otherwise
  Future<String?> sendFeedbackRequest({
    required String phoneNumber,
  });
}
