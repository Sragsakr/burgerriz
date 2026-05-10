import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:kiosk_point_of_sale/core/helpers/app_dialogs.dart';
import 'package:kiosk_point_of_sale/core/helpers/app_language_helper.dart';
import 'package:kiosk_point_of_sale/core/helpers/helper_functions.dart';
import 'package:kiosk_point_of_sale/core/helpers/responsive_helper.dart';
import 'package:kiosk_point_of_sale/data/models/promotions/models/promotion_codes_fb_model.dart';
import 'package:kiosk_point_of_sale/data/models/promotions/models/promotion_context.dart';
import 'package:kiosk_point_of_sale/data/models/promotions/models/promotion_invoice.dart';
import 'package:kiosk_point_of_sale/data/models/promotions/models/promotion_vm.dart';
import 'package:kiosk_point_of_sale/data/models/promotions/models/promotions_fB_table_model.dart';
import 'package:kiosk_point_of_sale/data/models/promotions/tables/promotion_codes_fb_table.dart';
import 'package:kiosk_point_of_sale/data/models/promotions/tables/promotions_fB_table_table.dart';
import 'package:kiosk_point_of_sale/data/models/sales_models/sales_invoice.dart';
import 'package:kiosk_point_of_sale/data/models/sales_models/sales_items_model.dart';
import 'package:kiosk_point_of_sale/main.dart';
import 'package:kiosk_point_of_sale/providers/payment_breakdown_provider.dart';
import 'package:kiosk_point_of_sale/repository/promotions/enums/promotion_template_type.dart';
import 'package:kiosk_point_of_sale/repository/promotions/enums/promotion_types.dart';
import 'package:kiosk_point_of_sale/repository/promotions/promotion_handler_factory.dart';

class PromotionsServices {
  static final PromotionsServices _instance = PromotionsServices._();

  PromotionsServices._();

  static PromotionsServices get instance => _instance;

  // 1. Get all automatic active offers (Automatic template type)
  Future<List<PromotionCodesFBModel>> getAutomaticActiveOffers() async {
    final allPromotions = await PromotionsFBTable.getAll();
    final allPromotionCodes = await PromotionCodesFBTable.getAll();
    final automaticPromotions = allPromotions
        .where((p) => p.isShowInPlugIn && p.templateType == PromotionTemplateType.auto.value)
        .toList();

    final validCodes = allPromotionCodes.where((code) => _isCodeActiveAndValid(code)).toList();
    // Join: for each valid code, find its promotion and return the code if it matches
    final offers = <PromotionCodesFBModel>[];

    for (final code in validCodes) {
      dPrint("validCodes IDS From Services: ${validCodes.map((e) => e.promotionFBId)}");
      final promo = automaticPromotions.firstWhereOrNull((p) {
        dPrint("p.id: ${p.id} , code.promotionFBId: ${code.promotionFBId}");

        return p.id == code.promotionFBId;
      });
      dPrint("promo From Services: ${promo?.toJson()}");
      if (promo != null) offers.add(code);
    }
    dPrint("validCodes From Services: ${validCodes.map((e) => e.toJson())}");
    dPrint("AutomaticPromotions From Services: ${automaticPromotions.map((e) => e.name)}");
    dPrint("AllPromotionCodes From Services: ${allPromotionCodes.map((e) => e.id)}");
    dPrint("########1${offers.map((e) => e.toJson())}");
    dPrint("########2${validCodes.map((e) => e.toJson())}");
    dPrint("########3${automaticPromotions.map((e) => e.toJson())}");
    return offers;
  }

  // 2. Get all active button offers (Button template type)
  Future<List<PromotionVM>> getActiveOffers() async {
    final allPromotions = await PromotionsFBTable.getAll();
    final allPromotionCodes = await PromotionCodesFBTable.getAll();
    final buttonPromotions = allPromotions
        .where((p) => p.isShowInPlugIn && p.templateType == PromotionTemplateType.button.value)
        .toList();
    dPrint("###buttonPromotions: ${buttonPromotions.map((e) => e.toJson())}");
    final validCodes = allPromotionCodes.where((code) => _isCodeActiveAndValid(code)).toList();
    final offers = <PromotionVM>[];
    for (final code in validCodes) {
      final promo = buttonPromotions.firstWhereOrNull((p) => p.id == code.promotionFBId);

      if (promo != null) {
        final codeModel = await getPromotionById(promo.id);
        offers.add(PromotionVM(
          promotionCodeId: code.id,
          promotionCode: code.code ?? '',
          name: promo.name,
          promotionFB: promo,
          codeModel: codeModel,
        ));
      }
    }
    return offers;
  } // 2. Get all active button offers (Code template type)

  Future<List<PromotionVM>> getActiveOffersCodes() async {
    final allPromotions = await PromotionsFBTable.getAll();
    final allPromotionCodes = await PromotionCodesFBTable.getAll();
    final buttonPromotions = allPromotions
        .where((p) => p.isShowInPlugIn && p.templateType == PromotionTemplateType.code.value)
        .toList();
    final validCodes = allPromotionCodes.where((code) => _isCodeActiveAndValid(code)).toList();
    final offers = <PromotionVM>[];
    for (final code in validCodes) {
      final promo = buttonPromotions.firstWhereOrNull((p) => p.id == code.promotionFBId);

      if (promo != null) {
        final codeModel = await getPromotionById(promo.id);
        offers.add(PromotionVM(
          promotionCodeId: code.id,
          promotionCode: code.code ?? '',
          name: promo.name,
          promotionFB: promo,
          codeModel: codeModel,
        ));
      }
    }
    return offers;
  }

  // 3. Get promotion by code (case-insensitive, trimmed)
  Future<PromotionCodesFBModel?> getPromotionByCode(String code) async {
    final allPromotionCodes = await PromotionCodesFBTable.getAll();
    final allPromotions = await PromotionsFBTable.getAll();
    final matchingCode = allPromotionCodes.firstWhereOrNull((promotionCode) {
      final codeValue = promotionCode.code;
      if (codeValue == null) return false;
      return codeValue.trim().toLowerCase() == code.trim().toLowerCase();
    });
    if (matchingCode == null) return null;
    final associatedPromotion = allPromotions.firstWhereOrNull(
      (promotion) => promotion.id == matchingCode.promotionFBId && promotion.isShowInPlugIn,
    );
    if (associatedPromotion == null) return null;
    return matchingCode;
  }

  // 4. Get promotion by id
  Future<PromotionCodesFBModel?> getPromotionById(int id) async {
    final allPromotionCodes = await PromotionCodesFBTable.getAll();
    final promo = allPromotionCodes.firstWhereOrNull((p) => p.id == id);
    return promo;
  }

  // 5. Apply promotion automatically (main logic)
  Future<PromotionInvoice> applyPromotionAutomatically(SalesInvoice saleTransactionVM) async {
    dPrint('🎁 === applyPromotionAutomatically START ===');
    dPrint('📊 Input invoice subtotal: ${saleTransactionVM.salesOrderModel.subTotal}');

    // Log initial product state
    dPrint('📦 Initial product state:');
    for (final item in saleTransactionVM.salesOrderItems) {
      dPrint('   - ${item.productNameEn}: Price=${item.price}, Quantity=${item.quantity}');
    }

    PromotionInvoice promotionRes = PromotionInvoice(saleTransactionVM);
    dPrint('📋 Created initial promotion invoice');

    final automaticActiveOffers = await getAutomaticActiveOffers();

    final allPromotionCodes = await PromotionCodesFBTable.getAll();
    final allPromotions = await PromotionsFBTable.getAll();

    dPrint('📦 Loaded data:');
    dPrint('   - Automatic active offers: ${automaticActiveOffers.length}');
    dPrint('   - All promotion codes: ${allPromotionCodes.length}');
    dPrint('   - All promotions: ${allPromotions.length}');

    // Log details of automatic offers
    for (int i = 0; i < automaticActiveOffers.length; i++) {
      final offer = automaticActiveOffers[i];
      final promotionFB = allPromotions.firstWhereOrNull((p) => p.id == offer.promotionFBId);
      dPrint(
          '   📋 Automatic offer ${i + 1}: ${offer.code} -> ${promotionFB?.name ?? 'Unknown'} (Type: ${promotionFB?.promotionType}) - ${promotionFB?.toJson()}');
    }

    PromotionCodesFBModel? getPromotionByIdLocal(int? id) {
      if (id == null) return null;
      return allPromotionCodes.firstWhereOrNull((p) => p.id == id);
    }

    PromotionsFBTableModel? getPromotionFBById(int? id) {
      if (id == null) return null;
      return allPromotions.firstWhereOrNull((p) => p.id == id);
    }

    // 1. Check if order-level promotion is still valid
    dPrint('🔍 Step 1: Checking order-level promotion validity...');
    int orderPromotionsApplied = 0;

    if (saleTransactionVM.salesOrderModel.promotionId != null &&
        !automaticActiveOffers.any((p) => p.id == saleTransactionVM.salesOrderModel.promotionId)) {
      dPrint(
          '⚠️  Order-level promotion ${saleTransactionVM.salesOrderModel.promotionId} not in active offers');

      final promotionCode = getPromotionByIdLocal(saleTransactionVM.salesOrderModel.promotionId);
      if (promotionCode != null) {
        dPrint('✅ Found promotion code: ${promotionCode.code}');

        final promotionFB = getPromotionFBById(promotionCode.promotionFBId);
        if (promotionFB != null) {
          dPrint('✅ Found promotion FB: ${promotionFB.name}');
          dPrint('🔄 Testing order-level promotion...');

          // Get current total before applying this promotion
          // final currentPrices = saleTransactionVM.calculateInvoicePrices();
          // final currentTotal =
          //     (currentPrices.subTotalAfterDiscount + currentPrices.vatAfterDiscount)
          //         .roundToDouble();
          // dPrint('💰 Current total before promotion: $currentTotal');

          // Test the promotion before applying it (like manual promotions)
          final tempResult = await applyPromotion(promotionCode, promotionFB, saleTransactionVM);

          // Calculate the total amount after promotion (including VAT and all calculations)
          final finalPrices = tempResult.salesTransaction.calculateInvoicePricesForTesting();
          final totalAfterPromotion =
              (finalPrices.subTotalAfterDiscount + finalPrices.vatAfterDiscount).roundToDouble();

          dPrint('💰 Total after promotion: $totalAfterPromotion');
          dPrint('   - Subtotal after discount: ${finalPrices.subTotalAfterDiscount}');
          dPrint('   - VAT after discount: ${finalPrices.vatAfterDiscount}');

          if (totalAfterPromotion >= 0) {
            dPrint(
                '✅ Order-level promotion ${promotionFB.name} - total is positive or zero, applying');
            promotionRes = tempResult;
            if (promotionRes.notMatch) {
              dPrint('❌ Order-level promotion not match - marking as not valid');
              promotionRes.notValidPromotion = true;
            } else {
              dPrint('✅ Order-level promotion applied successfully');
              orderPromotionsApplied++;
            }
          } else {
            dPrint(
                '⚠️  Skipping order-level promotion ${promotionFB.name} as it would make total negative: $totalAfterPromotion');
            promotionRes.notValidPromotion = true;
          }
        } else {
          dPrint('❌ Promotion FB not found for ID: ${promotionCode.promotionFBId}');
        }
      } else {
        dPrint(
            '❌ Promotion code not found for ID: ${saleTransactionVM.salesOrderModel.promotionId}');
      }
    } else {
      dPrint('✅ Order-level promotion is still valid or no promotion exists');
    }

    dPrint('📊 Order-level promotions summary:');
    dPrint('   - Order promotions applied: $orderPromotionsApplied');

    // 2. Check if item-level promotions are still valid
    dPrint('🔍 Step 2: Checking item-level promotions validity...');
    int itemPromotionsChecked = 0;
    int itemPromotionsApplied = 0;

    for (final item in promotionRes.salesTransaction.salesOrderItems) {
      if (item.promotionId != null && !automaticActiveOffers.any((p) => p.id == item.promotionId)) {
        itemPromotionsChecked++;
        dPrint('⚠️  Item ${item.productNameEn} promotion ${item.promotionId} not in active offers');

        final promotionCode = getPromotionByIdLocal(item.promotionId);
        if (promotionCode != null) {
          dPrint('✅ Found item promotion code: ${promotionCode.code}');

          final promotionFB = getPromotionFBById(promotionCode.promotionFBId);
          if (promotionFB != null) {
            dPrint('✅ Found item promotion FB: ${promotionFB.name}');
            dPrint('🔄 Testing item-level promotion...');

            // Test the promotion before applying it (like manual promotions)
            final tempResult =
                await applyPromotion(promotionCode, promotionFB, promotionRes.salesTransaction);

            // Calculate the total amount after promotion (including VAT and all calculations)
            final finalPrices = tempResult.salesTransaction.calculateInvoicePrices();
            final totalAfterPromotion =
                (finalPrices.subTotalAfterDiscount + finalPrices.vatAfterDiscount).roundToDouble();

            dPrint('💰 Total after promotion: $totalAfterPromotion');
            dPrint('   - Subtotal after discount: ${finalPrices.subTotalAfterDiscount}');
            dPrint('   - VAT after discount: ${finalPrices.vatAfterDiscount}');

            if (totalAfterPromotion >= 0) {
              dPrint(
                  '✅ Item-level promotion ${promotionFB.name} - total is positive or zero, applying');
              promotionRes = tempResult;
              if (promotionRes.notMatch) {
                dPrint('❌ Item-level promotion not match - marking as not valid');
                promotionRes.notValidPromotion = true;
              } else {
                dPrint('✅ Item-level promotion applied successfully');
                itemPromotionsApplied++;
              }
            } else {
              dPrint(
                  '⚠️  Skipping item-level promotion ${promotionFB.name} as it would make total negative: $totalAfterPromotion');
              promotionRes.notValidPromotion = true;
            }
          } else {
            dPrint('❌ Item promotion FB not found for ID: ${promotionCode.promotionFBId}');
          }
        } else {
          dPrint('❌ Item promotion code not found for ID: ${item.promotionId}');
        }
      }
    }

    dPrint('📊 Item promotions summary:');
    dPrint('   - Items checked: $itemPromotionsChecked');
    dPrint('   - Items applied: $itemPromotionsApplied');

    // 3. Prepare excluded types (InvoiceAmount, GiftVoucher, DisCountVoucher)
    dPrint('🔍 Step 3: Preparing excluded promotion types...');
    final excludedTypes = [
      PromotionType.invoiceAmount.intValue,
      PromotionType.giftVoucher.intValue,
      PromotionType.disCountVoucher.intValue
    ];
    dPrint('📋 Excluded types: $excludedTypes');

    final subtotal = double.tryParse(saleTransactionVM.salesOrderModel.subTotal) ?? 0.0;
    dPrint('💰 Subtotal for promotion matching: $subtotal');

    // 4. Try best-offer candidates in order; apply the first that can be applied
    dPrint('🔍 Step 4: Trying best-offer candidates (InvoiceAmount/GiftVoucher/DisCountVoucher)');
    PromotionCodesFBModel? appliedBestOffer;

    // Candidates that meet the same requirement set (excludedTypes)
    final bestOfferCandidates = automaticActiveOffers
        .where((o) => excludedTypes.contains(getPromotionFBById(o.promotionFBId)?.promotionType))
        .toList();

    // Split by threshold relation to subtotal, then order:
    // - <= subtotal: larger invoiceAmount first
    // - >  subtotal: smaller invoiceAmount first (fallbacks)
    final bestOfferLTE = bestOfferCandidates
        .where((o) => (getPromotionFBById(o.promotionFBId)?.invoiceAmount ?? 0) <= subtotal)
        .toList()
      ..sort((a, b) => (getPromotionFBById(b.promotionFBId)?.invoiceAmount ?? 0)
          .compareTo(getPromotionFBById(a.promotionFBId)?.invoiceAmount ?? 0));

    final bestOfferGT = bestOfferCandidates
        .where((o) => (getPromotionFBById(o.promotionFBId)?.invoiceAmount ?? 0) > subtotal)
        .toList()
      ..sort((a, b) => (getPromotionFBById(a.promotionFBId)?.invoiceAmount ?? 0)
          .compareTo(getPromotionFBById(b.promotionFBId)?.invoiceAmount ?? 0));

    final orderedCandidates = <PromotionCodesFBModel>[
      ...bestOfferLTE,
      ...bestOfferGT,
    ];
    List<PromotionsFBTableModel?> names = [];
    for (var s in orderedCandidates) {
      final promo = await s.promotionsFB;
      names.add(promo);
    }
    dPrint('Best offer candidates : ${names.map((e) => e?.toJson().toString() ?? '')} ');
    for (final offer in orderedCandidates) {
      final offerFB = getPromotionFBById(offer.promotionFBId);
      if (offerFB == null) {
        continue;
      }

      dPrint('🔄 Testing best-offer candidate: ${offerFB.name} (Amount: ${offerFB.invoiceAmount})');
      final testPromoInvoice = await PromotionsServices.instance.applyPromotion(
        offer,
        offerFB,
        promotionRes.salesTransaction,
      );
      dPrint('💰 testPromoInvoice: ${testPromoInvoice.notMatch}');

      final totalItemsPromotionValue = testPromoInvoice.salesTransaction.salesOrderItems
          .map((e) => e.promotionValue ?? 0)
          .reduce((value, element) => value + element);
      final promtionValue =
          (testPromoInvoice.salesTransaction.salesOrderModel.promotionValue ?? 0) +
              totalItemsPromotionValue;
      if (promtionValue > 0) {
        dPrint('✅ Best-offer candidate applied: ${offerFB.name}');
        promotionRes = testPromoInvoice;
        appliedBestOffer = offer;
        break;
      } else {
        dPrint('⚠️  Candidate not applicable, trying next...');
      }
    }

    // 5. Get all other automatic offers (not excluded types)
    dPrint('🔍 Step 5: Getting other automatic offers...');
    final promotions = automaticActiveOffers
        .where((o) => !excludedTypes.contains(getPromotionFBById(o.promotionFBId)?.promotionType))
        .toList();

    dPrint('📦 Other automatic offers found: ${promotions.length}');

    // Do not add appliedBestOffer to the queue; it was already applied above
    if (appliedBestOffer != null) {
      dPrint('✅ Best offer already applied earlier: ${appliedBestOffer.id}');
    }

    dPrint('📊 Total promotions to apply: ${promotions.length}');

    // Log which promotions will be processed
    for (int i = 0; i < promotions.length; i++) {
      final promotionCode = promotions[i];
      final promotionFB = getPromotionFBById(promotionCode.promotionFBId);
      dPrint(
          '   🎯 Will process: ${promotionCode.code} -> ${promotionFB?.name ?? 'Unknown'} (Type: ${promotionFB?.promotionType} - ${promotionCode.id})');
    }

    if (promotions.isNotEmpty) {
      dPrint('🔄 Step 6: Applying all promotions...');
      int appliedCount = 0;
      int skippedCount = 0;

      for (final promotionCode in promotions) {
        final promotionFB = getPromotionFBById(promotionCode.promotionFBId);

        if (promotionFB != null) {
          dPrint(
              '🎯 Processing automatic promotion: ${promotionFB.name} (Type: ${promotionFB.promotionType})');

          // Get current total before applying this promotion
          final currentPrices = promotionRes.salesTransaction.calculateInvoicePrices();
          final currentTotal =
              (currentPrices.subTotalAfterDiscount + currentPrices.vatAfterDiscount)
                  .roundToDouble();
          dPrint('💰 Current total before promotion: $currentTotal');

          // Test the promotion before applying it (like manual promotions)
          final tempResult =
              await applyPromotion(promotionCode, promotionFB, promotionRes.salesTransaction);

          // Calculate the total amount after promotion (including VAT and all calculations)
          final finalPrices = tempResult.salesTransaction.calculateInvoicePrices();
          final totalAfterPromotion =
              (finalPrices.subTotalAfterDiscount + finalPrices.vatAfterDiscount).roundToDouble();

          dPrint('💰 Total after promotion: $totalAfterPromotion');
          dPrint('   - Subtotal after discount: ${finalPrices.subTotalAfterDiscount}');
          dPrint('   - VAT after discount: ${finalPrices.vatAfterDiscount}');

          if (totalAfterPromotion >= 0) {
            dPrint(
                '✅ Automatic promotion ${promotionFB.name} - total is positive or zero, applying');
            promotionRes = tempResult;
            appliedCount++;
            dPrint('✅ Promotion ${promotionFB.name} applied ($appliedCount/${promotions.length})');

            // Log details of each product after promotion
            dPrint('📦 Product details after promotion:');
            for (final item in promotionRes.salesTransaction.salesOrderItems) {
              dPrint(
                  '   - ${item.productNameEn}: Price=${item.price}, Promotion=${item.promotionAmount}, Value=${item.promotionValue}');
            }
          } else {
            dPrint(
                '⚠️  Skipping automatic promotion ${promotionFB.name} as it would make total negative: $totalAfterPromotion');
            dPrint('🔄 Keeping previous state without this promotion');
            skippedCount++;
          }
        } else {
          dPrint('❌ Promotion FB not found for code: ${promotionCode.code}');
        }
      }

      dPrint('📈 Automatic promotions application completed:');
      dPrint('   - Applied: $appliedCount');
      dPrint('   - Skipped: $skippedCount');
      dPrint('   - Total processed: ${appliedCount + skippedCount}');
    } else {
      dPrint('⚠️  No promotions to apply');
    }

    dPrint('🎉 === applyPromotionAutomatically END ===');

    // Final check: Ensure the total after all automatic promotions is not negative
    final finalPrices = promotionRes.salesTransaction.calculateInvoicePrices();
    final finalTotal =
        (finalPrices.subTotalAfterDiscount + finalPrices.vatAfterDiscount).roundToDouble();

    dPrint('📊 Final total after all automatic promotions: $finalTotal');
    dPrint('   - Subtotal after discount: ${finalPrices.subTotalAfterDiscount}');
    dPrint('   - VAT after discount: ${finalPrices.vatAfterDiscount}');

    if (finalTotal < 0) {
      dPrint('⚠️  WARNING: Final total is negative after automatic promotions!');
      dPrint('🔄 Removing ALL automatic promotions and returning clean invoice');

      // Create a clean invoice without any promotions
      final cleanInvoice = removeAllPromotionsFromInvoice(saleTransactionVM);
      cleanInvoice.notValidPromotion = true;

      dPrint('✅ Clean invoice created without any promotions');
      final cleanPrices = cleanInvoice.salesTransaction.calculateInvoicePrices();
      final cleanTotal =
          (cleanPrices.subTotalAfterDiscount + cleanPrices.vatAfterDiscount).roundToDouble();
      dPrint('📊 Clean invoice total: $cleanTotal');

      return cleanInvoice;
    }

    dPrint('📊 Final result:');
    dPrint('   - Not match: ${promotionRes.notMatch}');
    dPrint('   - Not valid promotion: ${promotionRes.notValidPromotion}');
    dPrint('   - Final subtotal: ${promotionRes.salesTransaction.salesOrderModel.subTotal}');

    return promotionRes;
  }

  // Helper method to filter out items with 100% promotion (should not be included in new promotions)
  List<SalesItemsModel> _filterEligibleItemsForPromotion(List<SalesItemsModel> items) {
    return items.where((item) {
      final itemQuantity = double.tryParse(item.quantity) ?? 1;
      final itemPrice = double.tryParse(item.price) ?? 0.0;
      final priceWithoutTax = item.isExclusive ? itemPrice : itemPrice / 1.15;
      ;

      final itemSubTotal = itemQuantity * priceWithoutTax;
      final isFullPromotion = itemSubTotal == item.promotionValue;
      dPrint(
          "Item IS isFullPromotion $isFullPromotion priceWithoutTax $priceWithoutTax itemSubTotal $itemSubTotal promotionAmount: ${item.promotionValue}");

      // Exclude items that already have 100% promotion (promotionAmount = 100)
      // final hasFullPromotion =
      //     item.promotionAmount != null && item.promotionAmount == 100.0;
      if (isFullPromotion) {
        dPrint(
            '🚫 Excluding item "${item.productNameEn}" from promotion calculations (already has 100% promotion)');
      }
      return !isFullPromotion;
    }).toList();
  }

  // 6. Apply a single promotion (core logic)
  Future<PromotionInvoice> applyPromotion(
    PromotionCodesFBModel promotionCode,
    PromotionsFBTableModel promotionFB,
    SalesInvoice saleTransactionVM,
  ) async {
    dPrint("applyPromotion SalesInvoice1  ${promotionCode.code}: ${saleTransactionVM.toJson()}");
    // Create a copy to avoid modifying the original SalesInvoice
    final salesTransactionCopy = saleTransactionVM.copy();

    dPrint("applyPromotion SalesInvoice2  ${promotionCode.code}: ${salesTransactionCopy.toJson()}");
    // Store original items to restore later
    final originalItems = List<SalesItemsModel>.from(salesTransactionCopy.salesOrderItems);

    // Filter out items with 100% promotion before applying new promotions
    final eligibleItems = _filterEligibleItemsForPromotion(salesTransactionCopy.salesOrderItems);
    salesTransactionCopy.salesOrderItems = eligibleItems;

    dPrint('📊 Original items: ${originalItems.length}, Eligible items: ${eligibleItems.length}');

    final promotionInvoice = PromotionInvoice(salesTransactionCopy);
    try {
      // Check if promotion is already used
      // if (!isReturn &&
      //     !(promotionCode.multi) &&
      //     await PromotionHelpers.isPromotionUsed(promotionCode, promotionFB,
      //         saleTransactionVM.salesOrderModel.customerPhone)) {
      //   promotionInvoice.isUsed = true;
      //   return promotionInvoice;
      // }
      // Get the appropriate handler
      final context = PromotionContext(promotionCode, salesTransactionCopy);
      final handler = PromotionHandlerFactory.getHandler(promotionFB.promotionType);
      dPrint(
          "#####handler$handler  ${promotionFB.id} ${promotionFB.name} ${promotionCode.code} ${promotionFB.promotionType}");
      if (handler != null) {
        dPrint(
            'DEBUG: Manual promo handler sees items: ${context.saleTrans.salesOrderItems.length}');
        final result = await handler.apply(context);

        // Restore original items (including those with 100% promotion) to the result
        result.salesTransaction.salesOrderItems = originalItems;
        dPrint(
            '🔄 Restored original items: ${originalItems.length} (including ${originalItems.length - eligibleItems.length} items with 100% promotion)');

        return result;
      }

      // Restore original items even if no handler is found
      promotionInvoice.salesTransaction.salesOrderItems = originalItems;
      return promotionInvoice;
    } catch (e, t) {
      dPrint('❌ ERROR in applyPromotion: $e');
      dPrint('📋 Stack trace: $t');
      rethrow;
    }
  }

  // Helper: Check if a promotion code is active and valid for current date/time
  bool _isCodeActiveAndValid(PromotionCodesFBModel code) {
    final now = DateTime.now();
    final nowTime = TimeOfDay(hour: now.hour, minute: now.minute);
    if (code.isActive != true) return false;
    if (code.isTiming == true) {
      if (code.fromTime == null || code.toTime == null) return false;
      final fromParts = (code.fromTime as String).split(':').map(int.parse).toList();
      final toParts = (code.toTime as String).split(':').map(int.parse).toList();
      final from = TimeOfDay(hour: fromParts[0], minute: fromParts.length > 1 ? fromParts[1] : 0);
      final to = TimeOfDay(hour: toParts[0], minute: toParts.length > 1 ? toParts[1] : 0);
      return (nowTime.compareTo(from) >= 0) && (nowTime.compareTo(to) <= 0);
    } else {
      if (code.fromDate == null || code.toDate == null) return false;

      var fromDate = code.fromDate;
      var toDate = code.toDate;
      if (fromDate == null || toDate == null) return false;
      dPrint("toDate1 ${toDate.hour}, ${toDate.minute}, ${toDate.second},");

      if (toDate.hour == 0 && toDate.minute == 0) {
        dPrint("toDate2 ${toDate.hour}, ${toDate.minute}, ${toDate.second},");
        toDate = toDate.add(Duration(hours: 23, minutes: 59));
        dPrint("toDate3 ${toDate.hour}, ${toDate.minute}, ${toDate.second},");
      }
      dPrint("_isCodeActiveAndValid: now: $now, fromDate: ${fromDate}, toDate: ${toDate}");
      bool isValid = (fromDate.isBefore(now) || fromDate.isAtSameMomentAs(now)) &&
          (toDate.isAfter(now) || toDate.isAtSameMomentAs(now));
      dPrint("_isCodeActiveAndValid: isValid: $isValid");
      return isValid;
    }
  }

// Helper : Remove a specific Promotion From Invoice or Item
  PromotionInvoice removePromotionFromInvoiceItems(
    int promotionId,
    SalesInvoice saleTransactionVM,
  ) {
    final promotionInvoice = PromotionInvoice(saleTransactionVM);
    for (final item in saleTransactionVM.salesOrderItems) {
      if (item.promotionId == promotionId) {
        item.promotionId = null;
        item.promotionCode = null;
        item.promotionType = null;
        item.promotionValue = null;
        item.promotionAmount = null;
        item.freeItemSelectionState = null;
        item.selectedFreeProductId = null;
        item.selectedFreeProductName = null;
        item.selectedFreeProductNameAr = null;
        item.selectedFreeProductQuantity = null;
        item.selectedFreeProductPrice = null;
        item.selectedFreeItemId = null;
        item.isPromotionDuplicated = null;
      }
    }
    return promotionInvoice;
  }

  // Helper : Remove a specific Promotion From Invoice
  PromotionInvoice removePromotionFromInvoice(
    int promotionId,
    SalesInvoice saleTransactionVM,
  ) {
    final promotionInvoice = PromotionInvoice(saleTransactionVM);
    if (saleTransactionVM.salesOrderModel.promotionId == promotionId) {
      promotionInvoice.salesTransaction.salesOrderModel.promotionId = null;
      promotionInvoice.salesTransaction.salesOrderModel.promotionCode = null;
      promotionInvoice.salesTransaction.salesOrderModel.promotionType = null;
      promotionInvoice.salesTransaction.salesOrderModel.promotionValue = null;
      promotionInvoice.salesTransaction.salesOrderModel.promotionAmount = null;
    }
    return promotionInvoice;
  }

  // Helper : Remove ALL promotions from invoice and items
  PromotionInvoice removeAllPromotionsFromInvoice(SalesInvoice saleTransactionVM) {
    dPrint('🗑️  Removing ALL promotions from invoice...');

    final promotionInvoice = PromotionInvoice(saleTransactionVM);

    // Remove order-level promotion
    promotionInvoice.salesTransaction.salesOrderModel.promotionId = null;
    promotionInvoice.salesTransaction.salesOrderModel.promotionCode = null;
    promotionInvoice.salesTransaction.salesOrderModel.promotionType = null;
    promotionInvoice.salesTransaction.salesOrderModel.promotionValue = null;
    promotionInvoice.salesTransaction.salesOrderModel.promotionAmount = null;

    // Remove item-level promotions
    int itemsCleared = 0;
    for (final item in promotionInvoice.salesTransaction.salesOrderItems) {
      if (item.promotionId != null) {
        item.promotionId = null;
        item.promotionCode = null;
        item.promotionType = null;
        item.promotionValue = null;
        item.promotionAmount = null;
        item.freeItemSelectionState = null;
        item.selectedFreeProductId = null;
        item.selectedFreeProductName = null;
        item.selectedFreeProductNameAr = null;
        item.selectedFreeProductQuantity = null;
        item.selectedFreeProductPrice = null;
        item.selectedFreeItemId = null;
        item.isPromotionDuplicated = null;
        itemsCleared++;
      }
    }

    dPrint('✅ Removed promotions from order level and $itemsCleared items');
    return promotionInvoice;
  }

  /// Helper: Apply all automatic and manual promotions to an invoice
  Future<PromotionInvoice> applyAllPromotionsToInvoice(
      SalesInvoice saleTransactionVM, List<PromotionVM> manualPromos,
      {bool skipAutomaticPromotions = false}) async {
    dPrint('🎁 === applyAllPromotionsToInvoice START ===');
    dPrint('📊 Manual promotions count: ${manualPromos.length}');
    dPrint('⚙️  Skip automatic promotions: $skipAutomaticPromotions');

    try {
      PromotionInvoice result = PromotionInvoice(saleTransactionVM);

      // Apply automatic promotions first (unless skipped)
      if (!skipAutomaticPromotions) {
        dPrint('🔄 Applying automatic promotions...');
        result = await applyPromotionAutomatically(saleTransactionVM);
      } else {
        dPrint('⏭️  Skipping automatic promotions as requested');
      }
      dPrint("result :1 ${result.salesTransaction.toJson()}");
      // Apply manual promotions
      if (manualPromos.isNotEmpty) {
        dPrint('🎯 Applying manual promotions...');
        final promoNotTotalInvoice =
            manualPromos.where((e) => e.promotionFB?.isTotalInvoice != true).toList();
        final promoOnTotalInvoice =
            manualPromos.where((e) => e.promotionFB?.isTotalInvoice == true).toList();
        manualPromos = [
          ...promoNotTotalInvoice,
          ...promoOnTotalInvoice,
        ];
        for (final promo in manualPromos) {
          dPrint('🎁 Processing manual promotion: ${promo.promotionCodeId}');
          dPrint("result :2 ${result.salesTransaction.toJson()}");
          // Get current total before applying this promotion
          final currentPrices = result.salesTransaction.calculateInvoicePrices();
          final currentTotal =
              (currentPrices.subTotalAfterDiscount + currentPrices.vatAfterDiscount)
                  .roundToDouble();
          dPrint('💰 Current total before promotion: $currentTotal');

          final codeModel = await getPromotionById(promo.promotionCodeId);
          if (codeModel != null) {
            dPrint('✅ Found promotion code model: ${codeModel.code}');

            final promotionFB = await PromotionsFBTable.getByPromotionId(codeModel.promotionFBId);
            if (promotionFB != null) {
              dPrint('✅ Found promotion FB: ${promotionFB.name}');
              dPrint("result :3 ${result.salesTransaction.toJson()}");
              final tempResult =
                  await applyPromotion(codeModel, promotionFB, result.salesTransaction);
              dPrint('💰 TempResult promotion : ${tempResult.notValidPromotion}');
              dPrint('💰 TempResult promotion : ${tempResult.notMatch}');

              // Calculate the total amount after promotion (including VAT and all calculations)
              final finalPrices = tempResult.salesTransaction.calculateInvoicePrices();
              final totalAfterPromotion =
                  (finalPrices.subTotalAfterDiscount + finalPrices.vatAfterDiscount)
                      .roundToDouble();

              dPrint('💰 Total after promotion: $totalAfterPromotion');
              dPrint('   - Subtotal after discount: ${finalPrices.subTotalAfterDiscount}');
              dPrint('   - VAT after discount: ${finalPrices.vatAfterDiscount}');

              if (totalAfterPromotion >= 0) {
                dPrint('✅ Promotion ${promo.promotionCode} - total is positive or zero, applying');
                result = tempResult;
                dPrint("result :4 ${result.salesTransaction.toJson()}");
              } else {
                dPrint(
                    '⚠️  Skipping manual promotion ${promo.promotionCode} as it would make total negative: $totalAfterPromotion');
              }
            } else {
              dPrint('❌ Promotion FB not found for ID: ${codeModel.promotionFBId}');
            }
          } else {
            dPrint('❌ Promotion code model not found for code: ${promo.promotionCode}');
          }
        }
      } else {
        dPrint('📭 No manual promotions to apply');
      }

      // Calculate final prices
      dPrint('🧮 Calculating final invoice prices...');
      final finalPrices = result.salesTransaction.calculateInvoicePrices();
      final finalTotal =
          (finalPrices.subTotalAfterDiscount + finalPrices.vatAfterDiscount).roundToDouble();

      dPrint('📊 Final calculation results:');
      dPrint('   - Subtotal after discount: ${finalPrices.subTotalAfterDiscount}');
      dPrint('   - VAT after discount: ${finalPrices.vatAfterDiscount}');
      dPrint('   - Promotion amount: ${finalPrices.promotionAmount}');
      dPrint('   - Promotion value: ${finalPrices.promotionValue}');
      dPrint('   - Final total: $finalTotal');

      // Check if final total is negative (not zero)
      if (finalTotal < 0) {
        dPrint('⚠️  WARNING: Final total is negative after all promotions!');
        dPrint('🔄 Removing ALL promotions (automatic and manual) and returning clean invoice');

        // Create a clean invoice without any promotions
        final cleanInvoice = removeAllPromotionsFromInvoice(saleTransactionVM);
        cleanInvoice.notValidPromotion = true;

        dPrint('✅ Clean invoice created without any promotions');
        final cleanPrices = cleanInvoice.salesTransaction.calculateInvoicePrices();
        final cleanTotal =
            (cleanPrices.subTotalAfterDiscount + cleanPrices.vatAfterDiscount).roundToDouble();
        dPrint('📊 Clean invoice total: $cleanTotal');

        return cleanInvoice;
      }

      dPrint('✅ === applyAllPromotionsToInvoice END ===');
      return result;
    } catch (e, t) {
      dPrint('❌ ERROR in applyAllPromotionsToInvoice: $e');
      dPrint('📋 Stack trace: $t');
      rethrow;
    }
  }

  static PromotionInvoice _recalculateInvoiceTotals(PromotionInvoice promotionInvoice) {
    double orderSubTotal = 0;
    double orderTax = 0;
    const double taxRate = 0.15; // 15% VAT

    for (var item in promotionInvoice.salesTransaction.salesOrderItems) {
      double itemPrice = double.tryParse(item.price) ?? 0;
      double quantity = double.tryParse(item.quantity) ?? 1;
      double discount = item.discount ?? 0;
      double loyaltyDiscount = item.loyaltyDiscount ?? 0;
      double promotionValue = item.promotionValue ?? 0;
      double additionalAllowns = item.additionalAllowns ?? 0;

      // Calculate price without tax (per unit)
      double priceWithoutTax = item.isExclusive ? itemPrice : itemPrice / (1 + taxRate);

      // Calculate vatBeforeDiscount (per unit)
      double vatBeforeDiscount =
          item.isExclusive ? itemPrice * taxRate : itemPrice - priceWithoutTax;

      // Calculate totals for all quantity
      double totalPriceWithoutTax = priceWithoutTax * quantity;
      double totalVatBeforeDiscount = vatBeforeDiscount * quantity;

      double itemDiscount = (discount * quantity) + loyaltyDiscount + promotionValue;

      // Calculate the final price after all discounts
      double finalPriceWithoutTax = totalPriceWithoutTax - itemDiscount;

      // Calculate tax on the final discounted price (not on original price minus discount)
      double newItemTax = (finalPriceWithoutTax * taxRate).roundToTwoDecimals();

      dPrint(
          "🔢 Item: ${item.productNameEn} - Original: $totalPriceWithoutTax, Discount: $itemDiscount, Final: $finalPriceWithoutTax, Tax: $newItemTax");
      dPrint("#####itemTotal3$newItemTax");
      double priceIncludeVAT = (itemPrice * quantity) + additionalAllowns + totalVatBeforeDiscount;
      double itemTotal = finalPriceWithoutTax + newItemTax;
      // dPrint("#####itemTotal$itemTotal");
      item.vatBeforeDiscount = totalVatBeforeDiscount.roundToTwoDecimals();
      item.tax = newItemTax.roundToTwoDecimals().toStringAsFixed(2);
      item.priceIncludeVAT = priceIncludeVAT.roundToTwoDecimals();
      item.total = itemTotal.roundToTwoDecimals().toStringAsFixed(2);

      orderSubTotal += finalPriceWithoutTax.roundToTwoDecimals();
      orderTax += newItemTax.roundToTwoDecimals();
    }
    dPrint("#####itemTotal$orderSubTotal");
    dPrint("#####itemTotal3$orderTax");
    dPrint("🔢 Precision check - orderSubTotal: $orderSubTotal, orderTax: $orderTax");

    // Round both subtotal and tax to ensure consistent calculation
    double roundedOrderSubTotal = orderSubTotal.roundToTwoDecimals();
    double roundedOrderTax = orderTax.roundToTwoDecimals();
    double orderTotal = (roundedOrderSubTotal + roundedOrderTax).roundToTwoDecimals();

    dPrint(
        "🔢 Final calculation - SubTotal: $roundedOrderSubTotal, Tax: $roundedOrderTax, Total: $orderTotal");

    promotionInvoice.salesTransaction.salesOrderModel.subTotal =
        roundedOrderSubTotal.toStringAsFixed(2);
    promotionInvoice.salesTransaction.salesOrderModel.tax = roundedOrderTax.toStringAsFixed(2);
    promotionInvoice.salesTransaction.salesOrderModel.totalAmount = orderTotal.toStringAsFixed(2);

    return promotionInvoice;
  }
}

// Helper class for time comparison (since Flutter's TimeOfDay is not imported)
class TimeOfDay {
  final int hour;
  final int minute;

  TimeOfDay({required this.hour, required this.minute});

  int compareTo(TimeOfDay other) {
    if (hour != other.hour) return hour.compareTo(other.hour);
    return minute.compareTo(other.minute);
  }
}

removePromotionDialog(PromotionInvoice promotionInvoice) {
  showAppDialog(
    context: navKey.currentState!.context,
    barrierDismissible: true,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        title: Row(
          children: [
            const Icon(Icons.warning, color: Colors.orange, size: 28),
            const SizedBox(width: 10),
            Text(
              translator(arText: "يرجى الملاحظة", enText: "Please Note"),
              style: TextStyle(
                color: Colors.orange,
                fontWeight: FontWeight.bold,
                fontSize: ResponsiveHelper.getResponsiveFontSize(context, 18),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              translator(
                  arText: "العناصر التالية تحتاج إلى اهتمام:",
                  enText: "The following items need attention:"),
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 10),
            Text(
              translator(
                  arText: "قيمة الخصم أكبر من المبلغ الإجمالي للخصم سيتم إزالته",
                  enText: "Discount Value greater than total amount Discount will be removed"),
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              translator(arText: "موافق", enText: "OK"),
              style: TextStyle(
                fontSize: ResponsiveHelper.getResponsiveFontSize(context, 16),
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
          ),
        ],
      );
    },
  );
}
