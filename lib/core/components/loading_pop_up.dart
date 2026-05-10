import 'package:flutter/material.dart';
import 'package:kiosk_point_of_sale/core/assets/app_assets.dart';
import 'package:kiosk_point_of_sale/core/helpers/responsive_helper.dart';
import 'package:percent_indicator/percent_indicator.dart';

class LoadingPopupWidget extends StatefulWidget {
  final double progress;

  const LoadingPopupWidget({
    super.key,
    required this.progress,
  });

  @override
  State<LoadingPopupWidget> createState() => LoadingPopupWidgetState();
}

class LoadingPopupWidgetState extends State<LoadingPopupWidget> {
  double progress = 0.0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: const AlignmentDirectional(0.0, 0.0),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: const BoxConstraints(
          maxWidth: 530.0,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: const [
            BoxShadow(
              blurRadius: 3.0,
              color: Color(0x33000000),
              offset: Offset(0.0, 1.0),
            )
          ],
          borderRadius: BorderRadius.circular(24.0),
          border: Border.all(
            color: Colors.grey[200]!,
            width: 1.0,
          ),
        ),
        child: IntrinsicHeight(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Logo
              Container(
                width: 120.0,
                height: 70.0,
                padding:
                    const EdgeInsetsDirectional.fromSTEB(0.0, 10.0, 0.0, 0.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Image.asset(
                    AppAssets.newLogo,
                    width: 462.0,
                    height: 200.0,
                    fit: BoxFit.fill,
                  ),
                ),
              ),
              const Divider(
                thickness: 2.0,
                color: Color(0xFFAF2A26),
              ),
              // Progress Bar
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(
                    24.0, 16.0, 24.0, 16.0),
                child: LinearPercentIndicator(
                  percent: progress,
                  lineHeight: 32.0,
                  animation: true,
                  animateFromLastPercent: true,
                  progressColor: const Color(0xFF045CB6),
                  backgroundColor: const Color(0xFFD8D8D8),
                  center: Text(
                    '${(progress * 100).toStringAsFixed(0)}%',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize:
                          ResponsiveHelper.getResponsiveFontSize(context, 20),
                      fontFamily: 'Outfit',
                    ),
                  ),
                  barRadius: const Radius.circular(16.0),
                  padding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
