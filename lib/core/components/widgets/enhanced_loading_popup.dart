import 'package:flutter/material.dart';
import 'package:kiosk_point_of_sale/core/helpers/responsive_helper.dart';
import 'package:lottie/lottie.dart';
import 'package:kiosk_point_of_sale/core/assets/app_assets.dart';

class EnhancedLoadingPopup extends StatefulWidget {
  final String? message;
  final ValueNotifier<double>? progressNotifier;
  final ValueNotifier<String>? stepNotifier;
  final bool isLottie;
  final VoidCallback? onComplete;

  const EnhancedLoadingPopup({
    super.key,
    this.message,
    this.progressNotifier,
    this.stepNotifier,
    this.isLottie = false,
    this.onComplete,
  });

  @override
  State<EnhancedLoadingPopup> createState() => _EnhancedLoadingPopupState();
}

class _EnhancedLoadingPopupState extends State<EnhancedLoadingPopup>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _lottieController;
  late AnimationController _pulseController;
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _logoOpacityAnimation;
  late Animation<double> _fadeInAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    // Logo animation controller - single forward animation
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // Lottie animation controller
    _lottieController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    // Pulse animation controller for subtle logo animation
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    // Logo scale animation - simplified to avoid sequence issues
    _logoScaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: Curves.elasticOut,
    ));

    // Pulse animation for subtle logo movement
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    // Logo opacity animation
    _logoOpacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: Curves.easeInOut,
    ));

    // Overall fade in animation
    _fadeInAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: Curves.easeInOut,
    ));

    // Start animations
    _logoController.forward();
    _lottieController.repeat();
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _logoController.dispose();
    _lottieController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFFAF2A26).withOpacity(0.7),
              const Color(0xFF8B1A1A).withOpacity(0.5),
              const Color(0xFF6B0F0F).withOpacity(0.3),
            ],
          ),
        ),
        child: AnimatedBuilder(
          animation: _fadeInAnimation,
          builder: (context, child) {
            return Opacity(
              opacity: _fadeInAnimation.value,
              child: child,
            );
          },
          child: Center(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.85,
              constraints: const BoxConstraints(
                maxWidth: 400,
                maxHeight: 600,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo with enhanced animation
                  AnimatedBuilder(
                    animation:
                        Listenable.merge([_logoController, _pulseController]),
                    builder: (context, child) {
                      // Ensure animation values are within valid range
                      final scaleValue =
                          (_logoScaleAnimation.value * _pulseAnimation.value)
                              .clamp(0.1, 2.0);
                      final opacityValue =
                          _logoOpacityAnimation.value.clamp(0.0, 1.0);

                      return Transform.scale(
                        scale: scaleValue,
                        child: Opacity(
                          opacity: opacityValue,
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Image.asset(
                              AppAssets.newLogo,
                              width: MediaQuery.of(context).size.width * 0.4,
                              height: MediaQuery.of(context).size.height * 0.08,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 30),

                  // Lottie animation
                  if (widget.isLottie)
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Lottie.asset(
                          'assets/global/print_json.json',
                          width: MediaQuery.of(context).size.width * 0.6,
                          height: MediaQuery.of(context).size.height * 0.3,
                          controller: _lottieController,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),

                  const SizedBox(height: 20),

                  // Progress indicator
                  if (widget.progressNotifier != null)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: ValueListenableBuilder<double>(
                        valueListenable: widget.progressNotifier!,
                        builder: (context, progress, child) {
                          return Column(
                            children: [
                              // Enhanced Progress bar with animation
                              Container(
                                height: 12,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(6),
                                  color: Colors.white.withOpacity(0.2),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.3),
                                    width: 1,
                                  ),
                                ),
                                child: Stack(
                                  children: [
                                    // Background shimmer effect
                                    AnimatedBuilder(
                                      animation: _pulseController,
                                      builder: (context, child) {
                                        return Container(
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(6),
                                            gradient: LinearGradient(
                                              colors: [
                                                Colors.white.withOpacity(0.1),
                                                Colors.white.withOpacity(0.05),
                                                Colors.white.withOpacity(0.1),
                                              ],
                                              stops: [
                                                _pulseController.value * 0.5,
                                                _pulseController.value,
                                                (_pulseController.value + 0.5) %
                                                    1.0,
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                    // Progress fill
                                    AnimatedContainer(
                                      duration:
                                          const Duration(milliseconds: 300),
                                      curve: Curves.easeInOut,
                                      width: MediaQuery.of(context).size.width *
                                          0.65 *
                                          progress,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(6),
                                        gradient: LinearGradient(
                                          colors: [
                                            const Color(0xFF4CAF50),
                                            const Color(0xFF66BB6A),
                                            const Color(0xFF81C784),
                                          ],
                                          begin: Alignment.centerLeft,
                                          end: Alignment.centerRight,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: const Color(0xFF4CAF50)
                                                .withOpacity(0.5),
                                            blurRadius: 8,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                    ),
                                    // Progress indicator dot
                                    if (progress > 0)
                                      AnimatedContainer(
                                        duration:
                                            const Duration(milliseconds: 300),
                                        curve: Curves.easeInOut,
                                        margin: EdgeInsets.only(
                                          left: (MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.65 *
                                                  progress) -
                                              6,
                                        ),
                                        child: Container(
                                          width: 12,
                                          height: 12,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            shape: BoxShape.circle,
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black
                                                    .withOpacity(0.3),
                                                blurRadius: 4,
                                                offset: const Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                          child: Center(
                                            child: Container(
                                              width: 6,
                                              height: 6,
                                              decoration: const BoxDecoration(
                                                color: Color(0xFF4CAF50),
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 10),

                              // Enhanced Progress percentage with animation
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(15),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.2),
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.check_circle,
                                      color: progress >= 1.0
                                          ? const Color(0xFF4CAF50)
                                          : Colors.white.withOpacity(0.7),
                                      size: 16,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      '${(progress * 100).toStringAsFixed(0)}%',
                                      style: TextStyle(
                                        color: progress >= 1.0
                                            ? const Color(0xFF4CAF50)
                                            : Colors.white,
                                        fontSize: ResponsiveHelper
                                            .getResponsiveFontSize(context, 16),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),

                  // Step indicator
                  if (widget.stepNotifier != null)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      child: ValueListenableBuilder<String>(
                        valueListenable: widget.stepNotifier!,
                        builder: (context, step, child) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  color: Colors.white.withOpacity(0.8),
                                  size: 16,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    step,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: ResponsiveHelper
                                          .getResponsiveFontSize(context, 14),
                                      fontWeight: FontWeight.w500,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),

                  // Message
                  if (widget.message != null)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      child: Text(
                        widget.message!,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: ResponsiveHelper.getResponsiveFontSize(
                              context, 16),
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                  // Fallback loading indicator
                  if (widget.progressNotifier == null && !widget.isLottie)
                    Container(
                      padding: const EdgeInsets.all(20),
                      child: const CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 3,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
