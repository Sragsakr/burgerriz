import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kiosk_point_of_sale/core/flutter_flow/flutter_flow_theme.dart';
import 'package:kiosk_point_of_sale/core/helpers/app_language_helper.dart';
import 'package:kiosk_point_of_sale/core/helpers/responsive_helper.dart';
import 'package:kiosk_point_of_sale/data/models/sales_models/sales_invoice.dart';
import 'package:kiosk_point_of_sale/repository/sales_orders_repository.dart';
import 'package:kiosk_point_of_sale/features/shared-features/Orders/order_card.dart';
import 'package:kiosk_point_of_sale/features/shared-features/admin/admin_widget.dart';

// Debouncer utility
class Debouncer {
  final int milliseconds;
  VoidCallback? action;
  Timer? _timer;

  Debouncer({required this.milliseconds});

  run(VoidCallback action) {
    if (_timer != null) {
      _timer!.cancel();
    }
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }
}

class RedundScreen extends ConsumerStatefulWidget {
  static String routeName = 'Refunds';
  static String routePath = '/refunds';
  const RedundScreen({super.key});

  @override
  ConsumerState<RedundScreen> createState() => _RedundScreenState();
}

class _RedundScreenState extends ConsumerState<RedundScreen> {
  TextEditingController searchController = TextEditingController();
  String searchQuery = '';
  bool isSearching = false;
  List<SalesInvoice> refunds = [];
  final Debouncer _debouncer = Debouncer(milliseconds: 400);

  @override
  void initState() {
    super.initState();
    loadRefunds();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void loadRefunds() {
    SalesOrdersRepositoryImpl().getAllRefundOrdersFromDataBase().then((value) {
      setState(() {
        refunds = value;
      });
    });
  }

  void _performSearch(String value) {
    setState(() {
      searchQuery = value;
      isSearching = value.isNotEmpty;
    });
    if (isSearching) {
      // For refunds, we'll search in the existing refunds list
      // since refunds are already filtered by isRefund = 1
      final filteredRefunds = refunds
          .where((refund) =>
              refund.salesOrderModel.receiptNumber?.contains(value) == true ||
              refund.salesOrderModel.orderNumber.contains(value) == true)
          .toList();
      setState(() {
        refunds = filteredRefunds;
      });
    } else {
      loadRefunds();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: Icon(
              Icons.language,
              size: ResponsiveHelper.getResponsiveSize(
                context,
                24,
              ),
            ),
            onPressed: () async {
              await switchAppLanguage(ref, context);
            },
          ),
        ],
        centerTitle: true,
        elevation: 0.8,
        flexibleSpace: FlexibleSpaceBar(
          title: Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(2.0, 0.0, 0.0, 0.0),
            child: Text(
              translator(arText: 'المرتجعات', enText: 'Refunds'),
              style: FlutterFlowTheme.of(context).headlineSmall.override(
                    fontFamily: 'Outfit',
                    color: FlutterFlowTheme.of(context).gray600,
                  ),
            ),
          ),
          centerTitle: true,
          expandedTitleScale: 1.0,
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_rounded,
            color: Theme.of(context).colorScheme.primary,
            size: 30.0,
          ),
          onPressed: () {
            context.go(AdminWidget.routePath);
            context.pop();
          },
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: translator(
                    arText: 'ابحث برقم الفاتورة',
                    enText: 'Search by Receipt Number'),
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
                suffixIcon: searchQuery.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear),
                        onPressed: () {
                          searchController.clear();
                          setState(() {
                            searchQuery = '';
                            isSearching = false;
                          });
                          loadRefunds();
                        },
                      )
                    : null,
              ),
              onChanged: (value) {
                _debouncer.run(() => _performSearch(value));
              },
            ),
          ),
          Expanded(
            child: isSearching
                ? _buildRefundsList(refunds)
                : FutureBuilder<List<SalesInvoice>>(
                    future: SalesOrdersRepositoryImpl()
                        .getAllRefundOrdersFromDataBase(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(
                          child: Text("Error: ${snapshot.error}"),
                        );
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Center(
                          child: Text(translator(
                              arText: ' لا توجد مرتجعات',
                              enText: 'No Refunds')),
                        );
                      } else {
                        final orders = snapshot.data!;
                        return _buildRefundsList(orders);
                      }
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildRefundsList(List<SalesInvoice> refundsList) {
    if (refundsList.isEmpty) {
      return Center(
        child:
            Text(translator(arText: ' لا توجد مرتجعات', enText: 'No Refunds')),
      );
    }
    return ListView.builder(
      itemCount: refundsList.length,
      itemBuilder: (context, index) {
        final order = refundsList[index];
        return OrderCard(order: order, isAdmin: true, onRefund: () {});
      },
    );
  }
}
