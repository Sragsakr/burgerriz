import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kiosk_point_of_sale/features/kiosk-features/menu_widget/components/kiosk_product_image_helpers.dart';
import 'package:kiosk_point_of_sale/core/components/widgets/currency_display_widget.dart';
import 'package:kiosk_point_of_sale/core/components/widgets/product_selection_widget.dart';
import 'package:kiosk_point_of_sale/core/extentions/app_extentions.dart';
import 'package:kiosk_point_of_sale/core/flutter_flow/flutter_flow_icon_button.dart';
import 'package:kiosk_point_of_sale/core/flutter_flow/flutter_flow_theme.dart';
import 'package:kiosk_point_of_sale/core/flutter_flow/flutter_flow_util.dart';
import 'package:kiosk_point_of_sale/core/helpers/app_language_helper.dart';
import 'package:kiosk_point_of_sale/data/models/sync_product/sync_product_model.dart';

import 'products_details_model.dart';

export 'products_details_model.dart';

class ProductsDetailsWidget extends ConsumerStatefulWidget {
  final SyncProduct product;

  const ProductsDetailsWidget({
    super.key,
    required this.product,
  });

  @override
  ConsumerState<ProductsDetailsWidget> createState() =>
      _ProductsDetailsWidgetState();
}

class _ProductsDetailsWidgetState extends ConsumerState<ProductsDetailsWidget> {
  late ProductsDetailsModel _model;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ProductsDetailsModel());
  }

  @override
  void dispose() {
    _model.maybeDispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
      appBar: AppBar(
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        automaticallyImplyLeading: false,
        title: AutoSizeText(
          translator(
            arText: 'تفاصيل المنتج',
            enText: 'Product Details',
          ),
          maxLines: 1,
          minFontSize: 16,
          stepGranularity: 1,
          overflow: TextOverflow.ellipsis,
          style: FlutterFlowTheme.of(context).headlineMedium.override(
                fontFamily: 'Inter Tight',
                color: FlutterFlowTheme.of(context).primaryText,
                fontSize: 22.0,
              ),
        ),
        actions: [
          FlutterFlowIconButton(
            borderColor: Colors.transparent,
            borderRadius: 30.0,
            borderWidth: 1.0,
            buttonSize: 60.0,
            icon: Icon(
              Icons.close,
              color: FlutterFlowTheme.of(context).primaryText,
              size: 30.0,
            ),
            onPressed: () async {
              Navigator.of(context).pop();
            },
          ),
        ],
        centerTitle: false,
        elevation: 2.0,
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Padding(
              key: const Key('product_image'),
              padding: EdgeInsets.all(8.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: buildSyncProductImage(widget.product,
                    height: context.height * 0.2, width: context.width * 0.90),
              ),
            ),
            // Product Info Container
            Padding(
              padding: EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
              child: Container(
                width: double.infinity,
                height: context.height * 0.05,
                decoration: BoxDecoration(
                  color: FlutterFlowTheme.of(context).secondaryBackground,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        width: context.width * 0.45,
                        child: AutoSizeText(
                          translator(
                              arText: widget.product.nameAr,
                              enText: widget.product.nameEn),
                          maxLines: 3,
                          minFontSize: 12,
                          stepGranularity: 1,
                          overflow: TextOverflow.ellipsis,
                          style: FlutterFlowTheme.of(context)
                              .headlineMedium
                              .override(
                                font: GoogleFonts.interTight(
                                  fontWeight: FlutterFlowTheme.of(context)
                                      .headlineMedium
                                      .fontWeight,
                                  fontStyle: FlutterFlowTheme.of(context)
                                      .headlineMedium
                                      .fontStyle,
                                ),
                                color: FlutterFlowTheme.of(context).primaryText,
                                fontSize: 18.0,
                                letterSpacing: 0.0,
                                fontWeight: FontWeight.bold,
                                fontStyle: FlutterFlowTheme.of(context)
                                    .headlineMedium
                                    .fontStyle,
                              ),
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(
                                0.0, 6.0, 0.0, 0.0),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8.0),
                              child: const CurrencyDisplayWidget(
                                width: 47.5,
                                height: 44.04,
                              ),
                            ),
                          ),
                          AutoSizeText(
                            widget.product.unitOfMeasures.isNotEmpty
                                ? widget.product.unitOfMeasures.first.price
                                    .toStringAsFixed(2)
                                : '0.00',
                            maxLines: 1,
                            minFontSize: 20,
                            stepGranularity: 1,
                            overflow: TextOverflow.ellipsis,
                            style:
                                FlutterFlowTheme.of(context).bodySmall.override(
                                      font: GoogleFonts.inter(
                                        fontWeight: FontWeight.bold,
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .bodySmall
                                            .fontStyle,
                                      ),
                                      color: Color(0xFFAF2A26),
                                      fontSize: 40.0,
                                      letterSpacing: 0.0,
                                      fontWeight: FontWeight.bold,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .bodySmall
                                          .fontStyle,
                                    ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // ===== PRODUCT SELECTION SECTIONS =====
            ProductSelectionWidget(
              product: widget.product,
            ),
          ],
        ),
      ),
    );
  }
}
