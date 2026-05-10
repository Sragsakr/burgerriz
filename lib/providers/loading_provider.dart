// providers/loading_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoadingNotifier extends StateNotifier<double> {
  LoadingNotifier() : super(0.0);

  void updateProgress(double value) {
    state = value;
  }

  void reset() {
    state = 0.0;
  }
}

final loadingProvider = StateNotifierProvider<LoadingNotifier, double>((ref) {
  return LoadingNotifier();
});

//Sync staus
final isSyncSuccessProvider = StateProvider<bool>((ref) => false);
//Zatca staus
final zatcaProvider = StateProvider<bool>((ref) => false);
