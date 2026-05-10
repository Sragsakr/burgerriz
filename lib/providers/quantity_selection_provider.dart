import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Holds the quantity pre-set by the numeric keypad before a menu item tap.
///
/// Consume-once pattern: [useQuantity] atomically reads the value (defaulting
/// to 1 when 0) and resets the state to 0 so subsequent taps start fresh.
class QuantitySelectionNotifier extends StateNotifier<int> {
  QuantitySelectionNotifier() : super(0);

  void setQuantity(int quantity) {
    state = quantity > 0 ? quantity : 0;
  }

  /// Returns current quantity (1 if unset) and immediately resets to 0.
  int useQuantity() {
    final value = state == 0 ? 1 : state;
    state = 0;
    return value;
  }

  void reset() => state = 0;
}

final quantitySelectionProvider =
    StateNotifierProvider<QuantitySelectionNotifier, int>(
  (ref) => QuantitySelectionNotifier(),
);
