import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// State class for ads page view
class AdsPageViewState {
  final int currentPageIndex;
  final PageController pageController;
  final Timer? autoPlayTimer;

  const AdsPageViewState({
    this.currentPageIndex = 0,
    required this.pageController,
    this.autoPlayTimer,
  });

  AdsPageViewState copyWith({
    int? currentPageIndex,
    PageController? pageController,
    Timer? autoPlayTimer,
  }) {
    return AdsPageViewState(
      currentPageIndex: currentPageIndex ?? this.currentPageIndex,
      pageController: pageController ?? this.pageController,
      autoPlayTimer: autoPlayTimer ?? this.autoPlayTimer,
    );
  }
}

// Notifier for ads page view
class AdsPageViewNotifier extends StateNotifier<AdsPageViewState> {
  AdsPageViewNotifier()
      : super(AdsPageViewState(pageController: PageController(initialPage: 0)));

  /// Updates the current page index
  void updatePageIndex(int index) {
    state = state.copyWith(currentPageIndex: index);
  }

  /// Starts the auto-play feature
  void startAutoPlay(int totalPages,
      {Duration interval = const Duration(seconds: 3)}) {
    stopAutoPlay(); // Ensure no duplicate timers are running

    final timer = Timer.periodic(interval, (timer) {
      final nextPageIndex = (state.currentPageIndex + 1) % totalPages;
      if (state.pageController.positions.isNotEmpty) {
        state.pageController.animateToPage(
          nextPageIndex,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });

    state = state.copyWith(autoPlayTimer: timer);
  }

  /// Stops the auto-play feature
  void stopAutoPlay() {
    state.autoPlayTimer?.cancel();
    state = state.copyWith(autoPlayTimer: null);
  }

  @override
  void dispose() {
    stopAutoPlay(); // Clean up the timer when the notifier is disposed
    state.pageController.dispose();
    super.dispose();
  }
}

// Provider for ads page view
final adsPageViewProvider =
    StateNotifierProvider<AdsPageViewNotifier, AdsPageViewState>((ref) {
  return AdsPageViewNotifier();
});
