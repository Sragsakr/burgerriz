import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_printer/flutter_bluetooth_printer_library.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kiosk_point_of_sale/core/flutter_flow/flutter_flow_theme.dart';
import 'package:kiosk_point_of_sale/core/helpers/app_language_helper.dart';
import 'package:kiosk_point_of_sale/core/helpers/login_helpers.dart';
import 'package:kiosk_point_of_sale/core/helpers/responsive_helper.dart';
import 'package:kiosk_point_of_sale/data/models/sales_models/sales_invoice.dart';
import 'package:kiosk_point_of_sale/data/models/store/device_info_model.dart';
import 'package:kiosk_point_of_sale/repository/sales_orders_repository.dart';
import 'package:kiosk_point_of_sale/features/shared-features/Cashier/cashier_widget.dart';
import 'package:kiosk_point_of_sale/features/shared-features/Orders/order_card.dart';
import 'package:kiosk_point_of_sale/features/shared-features/admin/admin_widget.dart';

import '../../../core/services/printing_services/drago/drago_printer_controller.dart';
import '../../../data/services/local_data/device/device_info_table.dart';

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

class OrdersScreen extends ConsumerStatefulWidget {
  static String routeName = 'Orders';
  static String routePath = '/orders';
  final bool isAdmin;

  const OrdersScreen({super.key, required this.isAdmin});

  @override
  ConsumerState<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends ConsumerState<OrdersScreen> {
  SalesInvoice? selectedInvoice;
  ReceiptController? controller;
  String? address;
  DeviceConfigModel? deviceConfigModel;
  List<SalesInvoice> invoices = [];
  TextEditingController searchController = TextEditingController();
  String searchQuery = '';
  bool isSearching = false;
  final Debouncer _debouncer = Debouncer(milliseconds: 200);

  @override
  void initState() {
    DragoPrinterController.scan();

    getDeviceInfo();
    setInvoices();
    super.initState();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<SaleType?> getSaleType() async {
    SaleType? saleType;
    List<SaleType> saleTypes = await generateSaleTypeList();
    setState(() {
      saleType = saleTypes.firstWhere(
          (element) =>
              element.saleTypeId == selectedInvoice?.salesOrderModel.saleTypeId,
          orElse: () =>
              SaleType(saleTypeId: 0, nameAr: '', nameEn: '', saleNature: 0));
    });
    return saleType;
  }

  getDeviceInfo() async {
    setState(() {
      DeviceConfigTable.getDeviceInfo().then((value) {
        deviceConfigModel = value;
      });
    });
  }

  void setInvoices() {
    SalesOrdersRepositoryImpl()
        .getAllOrdersFromDataBase(forScreen: true)
        .then((value) {
      setState(() {
        invoices = value;
      });
    });
  }

  void _performSearch(String value) {
    setState(() {
      searchQuery = value;
      isSearching = value.isNotEmpty;
    });
    if (isSearching) {
      final repo = SalesOrdersRepositoryImpl();
      final Future<List<SalesInvoice>> searchFuture = widget.isAdmin
          ? repo.searchOrdersByReceiptNumberAndDate(value)
          : repo.searchOrdersByReceiptNumberAndShiftAndDate(value);
      searchFuture.then((result) {
        setState(() {
          invoices = result;
        });
      });
    } else {
      setInvoices();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(context),
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
                          setInvoices();
                        },
                      )
                    : null,
              ),
              onChanged: (value) {
                _debouncer.run(() => _performSearch(value));
              },
            ),
          ),
          Expanded(child: buildInvoices()),
        ],
      ),
    );
  }

  Widget buildInvoices() {
    if (isSearching) {
      if (invoices.isEmpty) {
        return Center(
          child: Text(translator(arText: 'لا يوجد طلبات', enText: 'No Orders')),
        );
      } else {
        return ListView.builder(
          itemCount: invoices.length,
          itemBuilder: (context, index) {
            final order = invoices[index];
            return OrderCard(
              order: order,
              isAdmin: widget.isAdmin,
              onRefund: () {
                setState(() {});
              },
            );
          },
        );
      }
    } else {
      return FutureBuilder<List<SalesInvoice>>(
        future: widget.isAdmin
            ? SalesOrdersRepositoryImpl()
                .getAllOrdersFromDataBaseByDate(forScreen: true)
            : SalesOrdersRepositoryImpl()
                .getAllOrdersFromDataBaseByShiftAndDate(forScreen: true),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text("Error: ${snapshot.error}"),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text(
                  translator(arText: 'لا يوجد طلبات', enText: 'No Orders')),
            );
          } else {
            final orders = snapshot.data!;
            return ListView.builder(
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];
                return OrderCard(
                  order: order,
                  isAdmin: widget.isAdmin,
                  onRefund: () {
                    setState(() {});
                  },
                );
              },
            );
          }
        },
      );
    }
  }

  AppBar buildAppBar(BuildContext context) {
    return AppBar(
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
            translator(arText: 'الطلبات', enText: 'Orders'),
            // 'POS',
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
          context.go(
              widget.isAdmin ? AdminWidget.routePath : CashierWidget.routePath);
          context.pop();
        },
      ),
    );
  }
}
