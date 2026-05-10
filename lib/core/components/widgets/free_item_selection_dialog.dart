import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kiosk_point_of_sale/core/helpers/app_language_helper.dart';
import 'package:kiosk_point_of_sale/core/helpers/responsive_helper.dart';
import 'package:kiosk_point_of_sale/data/models/sales_models/sales_items_model.dart';
import 'package:kiosk_point_of_sale/data/models/sync_product/sync_product_model.dart';

class FreeItemSelectionDialog extends ConsumerStatefulWidget {
  final SalesItemsModel salesItem;
  final List<SyncProduct> freeProducts;
  final Map<SyncProduct, Map<String, dynamic>> freeProductsWithDetails;

  const FreeItemSelectionDialog({
    super.key,
    required this.salesItem,
    required this.freeProducts,
    required this.freeProductsWithDetails,
  });

  @override
  ConsumerState<FreeItemSelectionDialog> createState() => _FreeItemSelectionDialogState();
}

class _FreeItemSelectionDialogState extends ConsumerState<FreeItemSelectionDialog> {
  SyncProduct? selectedProduct;
  double selectedQuantity = 1.0;

  @override
  Widget build(BuildContext context) {
    final isLandscape = ResponsiveHelper.isTablet(context);

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 8,
      child: Container(
        width: isLandscape ? 600 : MediaQuery.of(context).size.width * 0.9,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFAF2A26), Color(0xFFD32F2F)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.card_giftcard_rounded,
                      color: Colors.white,
                      size: ResponsiveHelper.isMobile(context) ? 24 : 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      translator(arText: "اختر منتج مجاني", enText: "Select Free Item"),
                      style: TextStyle(
                        fontFamily: 'Inter Tight',
                        color: Colors.white,
                        fontSize: ResponsiveHelper.isMobile(context) ? 16 : 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close_rounded, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            Flexible(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFFAF2A26).withOpacity(0.1),
                            const Color(0xFFAF2A26).withOpacity(0.05),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFFAF2A26).withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.local_offer_rounded, color: Color(0xFFAF2A26), size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              translator(arText: widget.salesItem.productNameAr, enText: widget.salesItem.productNameEn),
                              style: TextStyle(color: Colors.grey[700], fontSize: 11),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Flexible(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: widget.freeProducts.length,
                        itemBuilder: (context, index) {
                          final product = widget.freeProducts[index];
                          final details = widget.freeProductsWithDetails[product];
                          final isSelected = selectedProduct?.productId == product.productId;
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedProduct = product;
                                selectedQuantity = details?['quantity'] ?? 1;
                              });
                            },
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected ? const Color(0xFFAF2A26) : Colors.grey.shade300,
                                  width: isSelected ? 2 : 1,
                                ),
                              ),
                              child: Text(
                                translator(arText: product.nameAr, enText: product.nameEn),
                                style: TextStyle(
                                  color: isSelected ? const Color(0xFFAF2A26) : Colors.grey[800],
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: Text(translator(arText: "إلغاء", enText: "Cancel")),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: selectedProduct != null ? () => _confirmSelection(context) : null,
                            child: Text(translator(arText: "تأكيد ", enText: "Confirm")),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmSelection(BuildContext context) async {
    if (selectedProduct == null) return;
    // need to fined the details of the key that id equals the selected product id
    final selectedKey =
        widget.freeProductsWithDetails.keys.firstWhere((key) => key.productId == selectedProduct?.productId);
    final details = widget.freeProductsWithDetails[selectedKey];

    if (details == null) return;
    try {
      await widget.salesItem.selectFreeProduct(
        product: selectedProduct!,
        quantity: details['quantity']?.toDouble() ?? 0.0,
        price: details['price']?.toDouble() ?? 0.0,
        freeItemId: details['freeItemId'],
        isPromotionDuplicated: false,
      );
      Navigator.of(context).pop(true);
    } catch (_) {
      Navigator.of(context).pop(false);
    }
  }
}
