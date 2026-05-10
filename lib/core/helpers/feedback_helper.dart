import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kiosk_point_of_sale/data/services/remote_data/service_locator.dart';

/// Helper class for feedback-related operations
class FeedbackHelper {
  /// Send a feedback request using the feedback API service
  ///
  /// Example usage:
  /// ```dart
  /// final result = await FeedbackHelper.sendFeedback(
  ///   ref,
  ///   phoneNumber: '+96651717173',
  ///   branchId: 'BRANCH-1SA',
  ///   shiftId: 'SHIFT-1SA',
  ///   responseChannel: 'Whatsapp',
  /// );
  ///
  /// if (result != null) {
  ///   print('Feedback sent successfully: $result');
  /// } else {
  ///   print('Failed to send feedback');
  /// }
  /// ```
  static Future<String?> sendFeedback(
    WidgetRef ref, {
    required String phoneNumber,
  }) async {
    try {
      final feedbackService = ref.read(feedbackApiServiceProvider);
      return await feedbackService.sendFeedbackRequest(
        phoneNumber: phoneNumber,
      );
    } catch (e) {
      print('Error in FeedbackHelper.sendFeedback: $e');
      return null;
    }
  }
}
