import 'dart:async';

import 'package:flutter/material.dart';

import '../constants/entry_constants.dart';
import 'entry_page_indicator.dart';
import 'entry_slide.dart';

/// Optimized widget for the main page view with slides
class EntryPageView extends StatefulWidget {
  final PageController pageController;
  final VoidCallback? onButtonPressed;
  bool show;

  EntryPageView({
    super.key,
    required this.pageController,
    this.onButtonPressed,
    this.show = true,
  });

  @override
  State<EntryPageView> createState() => _EntryPageViewState();
}

class _EntryPageViewState extends State<EntryPageView> with TickerProviderStateMixin {
  Timer? _autoPlayTimer;
  bool _isUserInteracting = false;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize fade animation for smooth transitions
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    // Start auto-play once the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fadeController.forward();
      _startAutoPlay();
    });
  }

  @override
  void didUpdateWidget(EntryPageView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.show != oldWidget.show) {
      if (widget.show) {
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          _autoPlayTimer?.cancel();
          await Future.delayed(const Duration(seconds: 1));
          _startAutoPlay();
        });
      } else {
        _stopAutoPlay();
      }
    }
  }

  void _startAutoPlay() {
    if (!widget.show || _isUserInteracting) return;

    _autoPlayTimer?.cancel();
    _autoPlayTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!widget.pageController.hasClients || _isUserInteracting) return;

      final totalPages = EntryConstants.slides.length;
      if (totalPages <= 1) return;

      final currentPage = widget.pageController.page?.round() ?? 0;
      final nextPage = (currentPage + 1) % totalPages;

      widget.pageController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 1000),
        curve: Curves.linear,
      );
    });
  }

  void _stopAutoPlay() {
    _autoPlayTimer?.cancel();
    _autoPlayTimer = null;
  }

  void _onUserInteraction() {
    _isUserInteracting = true;
    _stopAutoPlay();

    // Resume auto-play after user stops interacting
    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        _isUserInteracting = false;
        _startAutoPlay();
      }
    });
  }

  @override
  void dispose() {
    _autoPlayTimer?.cancel();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Stack(
          children: [
            // Optimized PageView with better performance
            NotificationListener<ScrollNotification>(
              onNotification: (notification) {
                if (notification is ScrollStartNotification) {
                  _onUserInteraction();
                }
                return false;
              },
              child: PageView.builder(
                controller: widget.pageController,
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: EntryConstants.slides.length,
                itemBuilder: (context, index) {
                  return AnimatedBuilder(
                    animation: widget.pageController,
                    builder: (context, child) {
                      final slideData = EntryConstants.slides[index];
                      return EntrySlide(
                        slideData: slideData,
                        onButtonPressed: widget.onButtonPressed,
                        show: widget.show,
                      );
                    },
                  );
                },
              ),
            ),

            // if (EntryConstants.slides.length > 1)
            //   EntryPageIndicator(
            //     pageController: widget.pageController,
            //     pageCount: EntryConstants.slides.length,
            //     onDotClicked: (index) async {
            //       _onUserInteraction();
            //       await widget.pageController.animateToPage(
            //         index,
            //         duration: const Duration(milliseconds: 600),
            //         curve: Curves.easeInOutCubic,
            //       );
            //     },
            //   ),
          ],
        ),
      ),
    );
  }
}
