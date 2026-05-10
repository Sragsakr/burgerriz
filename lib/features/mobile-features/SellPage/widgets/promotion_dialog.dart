import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kiosk_point_of_sale/core/helpers/app_language_helper.dart';
import 'package:kiosk_point_of_sale/core/helpers/helper_functions.dart';
import 'package:kiosk_point_of_sale/core/services/order_services/free_item_service.dart';
import 'package:kiosk_point_of_sale/data/models/promotions/models/promotion_vm.dart';
import 'package:kiosk_point_of_sale/data/models/promotions/tables/promotions_fB_table_table.dart';
import 'package:kiosk_point_of_sale/data/models/sales_models/sales_invoice.dart';
import 'package:kiosk_point_of_sale/providers/cart_provider.dart';
import 'package:kiosk_point_of_sale/providers/order_summary_provider.dart';
import 'package:kiosk_point_of_sale/providers/payment_breakdown_provider.dart';
import 'package:kiosk_point_of_sale/providers/promotion_provider.dart';
import 'package:kiosk_point_of_sale/repository/promotions/enums/promotion_value_type.dart';
import 'package:kiosk_point_of_sale/repository/promotions/promotions_services.dart';

// final appliedPromotionsDialogProvider =
//     StateProvider<List<PromotionVM>>((ref) => []);
final promotionDialogMessageProvider = StateProvider<String?>((ref) => null);
final promotionDialogCodeProvider = StateProvider<String>((ref) => '');

class PromotionDialog extends ConsumerStatefulWidget {
  final List<PromotionVM> availableOffers;
  final List<PromotionVM> initialAppliedPromotions;
  final void Function(List<PromotionVM> appliedPromotions) onConfirm;

  const PromotionDialog({
    super.key,
    required this.availableOffers,
    required this.initialAppliedPromotions,
    required this.onConfirm,
  });

  @override
  ConsumerState<PromotionDialog> createState() => _PromotionDialogState();
}

class _PromotionDialogState extends ConsumerState<PromotionDialog> {
  final TextEditingController codeController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appliedPromotions = ref.watch(appliedPromotionsProvider);
    final message = ref.watch(promotionDialogMessageProvider);
    final code = ref.watch(promotionDialogCodeProvider);
    final cartItems = ref.watch(cartProvider);

    // Keep controller in sync with provider (but don't recreate it)
    if (codeController.text != code) {
      codeController.value = TextEditingValue(
        text: code,
        selection: TextSelection.collapsed(offset: code.length),
      );
    }

    // Initialize appliedPromotions only once
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (appliedPromotions.isEmpty &&
          widget.initialAppliedPromotions.isNotEmpty) {
        ref.read(appliedPromotionsProvider.notifier).state =
            List.from(widget.initialAppliedPromotions);
      }
    });

    double getPromotionValue(int? valueType, double? value, double subtotal) {
      if (valueType == PromotionIValueType.discountPercentage.value) {
        return ((value ?? 0) / 100) * subtotal;
      } else if (valueType == PromotionIValueType.specificValue.value) {
        return value ?? 0;
      } else {
        return value ?? 0;
      }
    }

    Future<void> applyOffer(PromotionVM offer, SalesInvoice invoice) async {
      if (appliedPromotions
          .any((p) => p.promotionCodeId == offer.promotionCodeId)) {
        ref.read(promotionDialogMessageProvider.notifier).state =
            'Offer already applied';
        Future.delayed(const Duration(seconds: 2), () {
          ref.read(promotionDialogMessageProvider.notifier).state = null;
        });
        return;
      }
      ref.read(promotionDialogMessageProvider.notifier).state =
          'Checking promotion...';
      try {
        if (cartItems.isEmpty) {
          ref.read(promotionDialogMessageProvider.notifier).state =
              'Please add items to the cart before applying a promotion.';
          Future.delayed(const Duration(seconds: 2), () {
            ref.read(promotionDialogMessageProvider.notifier).state = null;
          });
          return;
        }
        final codeModel = await PromotionsServices.instance
            .getPromotionById(offer.promotionCodeId);
        if (codeModel == null) {
          ref.read(promotionDialogMessageProvider.notifier).state =
              'Promotion not found';
          return;
        }
        final allPromos = await PromotionsFBTable.getAll();
        final fbModel = allPromos.firstWhere(
          (p) => p.id == codeModel.promotionFBId,
          orElse: () => allPromos.isNotEmpty
              ? allPromos.first
              : throw Exception('No promotions found'),
        );

        final promoInvoice = await PromotionsServices.instance.applyPromotion(
          codeModel,
          fbModel,
          invoice,
        );
        dPrint('💰 testPromoInvoice: ${promoInvoice.notMatch}');
        if (promoInvoice.notMatch) {
          ref.read(promotionDialogMessageProvider.notifier).state =
              'This offer cannot be applied to your order';
          Future.delayed(const Duration(seconds: 3), () {
            ref.read(promotionDialogMessageProvider.notifier).state = null;
          });
          return;
        }
        if (promoInvoice.notValidPromotion) {
          ref.read(promotionDialogMessageProvider.notifier).state =
              'This promotion is not valid';
          Future.delayed(const Duration(seconds: 3), () {
            ref.read(promotionDialogMessageProvider.notifier).state = null;
          });
          return;
        }
        if (promoInvoice.isUsed) {
          ref.read(promotionDialogMessageProvider.notifier).state =
              'This promotion has already been used';
          Future.delayed(const Duration(seconds: 3), () {
            ref.read(promotionDialogMessageProvider.notifier).state = null;
          });
          return;
        }
        try {
          final testPromoInvoice =
              await PromotionsServices.instance.applyPromotion(
            codeModel,
            fbModel,
            invoice,
          );
          dPrint('💰 testPromoInvoice: ${testPromoInvoice.notMatch}');

          final testPrices = testPromoInvoice.salesTransaction
              .calculateInvoicePricesForTesting();

          final testTotal =
              (testPrices.subTotalAfterDiscount + testPrices.vatAfterDiscount)
                  .roundToTwoDecimals();
          dPrint("testTotal: $testTotal");
          if (testTotal < 0) {
            ref.read(promotionDialogMessageProvider.notifier).state =
                'This promotion would make the total negative (${testTotal.toStringAsFixed(2)})';
            Future.delayed(const Duration(seconds: 1), () {
              ref.read(promotionDialogMessageProvider.notifier).state = null;
            });
            return;
          }
        } catch (e) {
          print('Error testing promotion total: $e');
        }
        ref.read(appliedPromotionsProvider.notifier).state = [
          ...appliedPromotions,
          offer
        ];
        ref.read(promotionDialogMessageProvider.notifier).state =
            'Promotion applied successfully!';
        Future.delayed(const Duration(seconds: 1), () {
          ref.read(promotionDialogMessageProvider.notifier).state = null;
        });
        ref.read(appliedPromotionsProvider.notifier).state =
            List.from(ref.read(appliedPromotionsProvider));
      } catch (e) {
        ref.read(promotionDialogMessageProvider.notifier).state =
            'Error applying promotion: ${e.toString()}';
        Future.delayed(const Duration(seconds: 1), () {
          ref.read(promotionDialogMessageProvider.notifier).state = null;
        });
      }
    }

    void removePromotion(PromotionVM promo) {
      dPrint('🎁 Removing promotion: ${promo.promotionCodeId}');

      // FIRST: Reset free item selection values for cart items related to the removed promotion
      final cartNotifier = ref.read(cartProvider.notifier);
      final currentCart = ref.read(cartProvider);

      dPrint('🎁 Current cart items: ${currentCart.length}');

      // Get the order summary to find which sales items have this promotion
      final orderSummary = ref.read(orderSummaryProvider);
      final salesItemsWithPromotion = orderSummary
          .value?.salesInvoice.salesOrderItems
          .where((item) => item.promotionCodeId == promo.promotionCodeId)
          .toList();

      dPrint(
          '🎁 Sales items with promotion ${promo.promotionCodeId}: ${salesItemsWithPromotion?.length ?? 0}');

      // Find cart items that correspond to the sales items with this promotion
      for (int i = 0; i < currentCart.length; i++) {
        final cartItem = currentCart[i];

        dPrint(
            '🎁 Checking cart item $i: ${cartItem.nameEn} (${cartItem.productId}, unit: ${cartItem.unitId})');
        dPrint(
            '🎁 Cart item free item state: ${cartItem.freeItemSelectionState}');
        dPrint(
            '🎁 Cart item selected free product: ${cartItem.selectedFreeProductName}');

        // Check if this cart item corresponds to a sales item with the promotion being removed
        final correspondingSalesItem =
            salesItemsWithPromotion?.firstWhereOrNull(
          (salesItem) =>
              salesItem.productId == cartItem.productId &&
              salesItem.unitOfMeasureId == cartItem.unitId.toString(),
        );

        dPrint(
            '🎁 Corresponding sales item found: ${correspondingSalesItem != null}');

        // If this cart item has the promotion being removed, reset its free item values
        if (correspondingSalesItem != null) {
          dPrint(
              '🎁 Resetting free item values for cart item $i BEFORE removing promotion');

          // Clear the specific cart item's free item state from FreeItemService
          FreeItemService.clearFreeItemStateByCartIndex(i);

          // Reset all free item selection values in the cart item
          cartNotifier.updateFreeItemDetails(
            i,
            null, // Reset freeItemSelectionState to null
            selectedFreeProductId: null,
            selectedFreeProductName: null,
            selectedFreeProductNameAr: null,
            selectedFreeProductQuantity: null,
            selectedFreeProductPrice: null,
            selectedFreeItemId: null,
            isPromotionDuplicated: null,
          );

          dPrint('🎁 Free item values reset for cart item $i');
        }
      }

      // SECOND: Now remove the promotion from applied promotions
      ref.read(appliedPromotionsProvider.notifier).state = appliedPromotions
          .where((p) => p.promotionCodeId != promo.promotionCodeId)
          .toList();
      ref.read(appliedPromotionsProvider.notifier).state =
          List.from(ref.read(appliedPromotionsProvider));

      ref.read(promotionDialogMessageProvider.notifier).state =
          'Promotion removed';

      // Add a small delay to verify cart items after promotion removal
      Future.delayed(const Duration(milliseconds: 100), () {
        dPrint('🎁 Cart items after promotion removal:');
        final updatedCart = ref.read(cartProvider);
        for (int i = 0; i < updatedCart.length; i++) {
          final cartItem = updatedCart[i];
          dPrint('🎁 Cart item $i: ${cartItem.nameEn}');
          dPrint(
              '🎁   - freeItemSelectionState: ${cartItem.freeItemSelectionState}');
          dPrint(
              '🎁   - selectedFreeProductName: ${cartItem.selectedFreeProductName}');
        }
      });

      Future.delayed(const Duration(seconds: 2), () {
        ref.read(promotionDialogMessageProvider.notifier).state = null;
      });
    }

    Future<void> applyCode(String code, SalesInvoice invoice) async {
      final offers = await PromotionsServices.instance.getActiveOffersCodes();
      final offer = offers.firstWhereOrNull(
        (o) => o.promotionCode.toLowerCase() == code.toLowerCase(),
      );
      if (offer == null) {
        ref.read(promotionDialogMessageProvider.notifier).state =
            'Invalid promotion code';
        Future.delayed(const Duration(seconds: 2), () {
          ref.read(promotionDialogMessageProvider.notifier).state = null;
        });
        return;
      }
      await applyOffer(offer, invoice);
      ref.read(promotionDialogCodeProvider.notifier).state = '';
      codeController.clear();
    }

    final orderSummaryAsync = ref.watch(orderSummaryProvider);
    return orderSummaryAsync.when(
      skipLoadingOnReload: true,
      data: (orderSummary) {
        return buildDialog(message, applyOffer, applyCode, appliedPromotions,
            removePromotion, context, orderSummary.salesInvoice);
      },
      loading: () => Center(
        child: CircularProgressIndicator(),
      ),
      error: (error, stack) {
        dPrint("Stack Trace: $stack");
        return Text(translator(arText: "جاري التحميل", enText: "loading ..."));
      },
    );
  }

  Dialog buildDialog(
    String? message,
    Future<void> Function(PromotionVM offer, SalesInvoice invoice) applyOffer,
    Future<void> Function(String code, SalesInvoice invoice) applyCode,
    List<PromotionVM> appliedPromotions,
    void Function(PromotionVM promo) removePromotion,
    BuildContext context,
    SalesInvoice invoice,
  ) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (message != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    message,
                    style: const TextStyle(color: Colors.orange),
                  ),
                ),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Available Offers",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 8),
              ...widget.availableOffers.map((offer) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: OutlinedButton(
                      onPressed: () => applyOffer(offer, invoice),
                      child: Text(offer.name),
                    ),
                  )),
              const Divider(height: 32),
              Row(
                children: [
                  Expanded(
                    child: PromotionCodeTextField(
                      controller: codeController,
                      onApply: (value) {
                        return applyCode(value, invoice);
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () async {
                      if (codeController.text.isNotEmpty) {
                        await applyCode(codeController.text.trim(), invoice);
                      }
                    },
                    child: const Text("Apply"),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Applied promotions",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              ...appliedPromotions.map((promo) => Card(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    child: ListTile(
                      dense: true,
                      title: Text(promo.name),
                      subtitle: Text('Code: \\${promo.promotionCode}'),
                      trailing: IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => removePromotion(promo),
                      ),
                    ),
                  )),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Back'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PromotionCodeTextField extends ConsumerStatefulWidget {
  final TextEditingController controller;
  final Future<void> Function(String code) onApply;

  const PromotionCodeTextField({
    super.key,
    required this.controller,
    required this.onApply,
  });

  @override
  ConsumerState<PromotionCodeTextField> createState() =>
      _PromotionCodeTextFieldState();
}

class _PromotionCodeTextFieldState
    extends ConsumerState<PromotionCodeTextField> {
  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      decoration: const InputDecoration(
        labelText: "Enter promotion code",
        border: OutlineInputBorder(),
        isDense: true,
        contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      ),
      onChanged: (val) =>
          ref.read(promotionDialogCodeProvider.notifier).state = val,
      onSubmitted: (val) async {
        if (val.isNotEmpty) await widget.onApply(val.trim());
      },
    );
  }
}
