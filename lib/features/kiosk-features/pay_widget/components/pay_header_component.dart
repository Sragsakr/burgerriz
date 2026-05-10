import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kiosk_point_of_sale/core/extentions/app_extentions.dart';
import 'package:kiosk_point_of_sale/core/flutter_flow/flutter_flow_theme.dart';
import 'package:kiosk_point_of_sale/core/helpers/responsive_helper.dart';
import 'package:kiosk_point_of_sale/main.dart';
import 'package:kiosk_point_of_sale/providers/payment_breakdown_provider.dart';
import 'package:kiosk_point_of_sale/features/kiosk-features/entry_widget/entry_widget.dart';
import 'package:kiosk_point_of_sale/features/kiosk-features/menu_widget/menu_widget.dart';

class PayHeaderComponent extends ConsumerWidget {
  final bool isBack;
  const PayHeaderComponent({super.key, this.isBack = true});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(reportGroupThemeProvider);

    return Container(
      width: double.infinity,
      padding: EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
      child: Column(
        children: [
          // Back button (top-left, aligned start)
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: IconButton(
              onPressed: () { 
                if (isBack) {
                           context.go(MenuWidget.routePath);
                } else {
                           navKey.currentState!.context.pushReplacementNamed(EntryWidget.routeName);
        
                }
              },
              icon: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: FlutterFlowTheme.of(context).primaryText,
                size: ResponsiveHelper.getResponsiveSize(context, 24.0),
              ),
            ),
          ),

          SizedBox(height: ResponsiveHelper.getResponsiveSize(context, 80.0)),

          // Store logo (centered)
          Image.asset(
            theme.logoAsset,
            height: ResponsiveHelper.getResponsiveSize(
              context,
              theme.isSteakHouseBrand ? 200.0 : 100.0,
            ),
            fit: theme.isSteakHouseBrand ? BoxFit.contain : BoxFit.cover,
          ),
        ],
      ),
    );
  }
}
