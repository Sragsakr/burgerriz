import 'package:flutter/material.dart';
import 'package:kiosk_point_of_sale/core/assets/app_assets.dart';
import 'package:kiosk_point_of_sale/core/helpers/responsive_helper.dart';
import 'package:lottie/lottie.dart';

class LoadingPopupForPrint extends StatefulWidget {
  final String? message;
  final ValueNotifier<double>? progressNotifier; // NEW
  final bool isLottie;
  const LoadingPopupForPrint({
    super.key,
    this.message,
    this.progressNotifier,
    this.isLottie = false,
  });

  @override
  State<LoadingPopupForPrint> createState() => _LoadingPopupForPrintState();
}

class _LoadingPopupForPrintState extends State<LoadingPopupForPrint>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    // Create a curved animation for smooth scaling
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.5), // Scale up
        weight: 1,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.5, end: 1.0), // Scale down
        weight: 1,
      ),
    ]).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    // Rotation animation
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isLottie) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(
            AppAssets.newLogo,
            width: MediaQuery.of(context).size.width * 0.5,
            height: MediaQuery.of(context).size.height * 0.1,
          ),
          Lottie.asset('assets/global/print_json.json',
              width: MediaQuery.of(context).size.width * 0.5,
              height: MediaQuery.of(context).size.height * 0.5),
          if (widget.message != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Text(
                widget.message!,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: ResponsiveHelper.getResponsiveFontSize(context, 20),
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      );
    }
    return Material(
      color: Colors.transparent,
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        color: const Color.fromARGB(255, 0, 0, 0).withOpacity(0.8),
        child: Center(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (_, child) {
              return Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.001)
                  ..scale(_scaleAnimation.value),
                child: child,
              );
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  AppAssets.newLogo,
                  width: MediaQuery.of(context).size.width * 0.5,
                  height: MediaQuery.of(context).size.height * 0.1,
                ),
                if (widget.message != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Text(
                      widget.message!,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize:
                            ResponsiveHelper.getResponsiveFontSize(context, 20),
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                if (widget.progressNotifier != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30.0),
                    child: ValueListenableBuilder<double>(
                      valueListenable: widget.progressNotifier!,
                      builder: (context, progress, child) {
                        return Column(
                          children: [
                            LinearProgressIndicator(
                              value: progress,
                              backgroundColor: Colors.grey,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.blue),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              '${(progress * 100).toStringAsFixed(0)}%',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize:
                                    ResponsiveHelper.getResponsiveFontSize(
                                        context, 16),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  )
                else

                  /// need to add a loading animation here
                  const CircularProgressIndicator(
                    color: Colors.white,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
