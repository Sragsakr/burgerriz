import 'package:kiosk_point_of_sale/data/models/cart_item.dart';
import 'package:kiosk_point_of_sale/data/models/sync_product/sync_product_model.dart';

SyncProduct syncProductStubFromCartItem(CartItem item) {
  final id = int.tryParse(item.productId) ?? 0;
  final categoryId = int.tryParse(item.categoryId) ?? 0;
  return SyncProduct(
    id: id,
    tenantId: 0,
    productCategoryId: categoryId,
    itemCode: item.itemCode,
    nameEn: item.nameEn,
    nameAr: item.nameAr,
    imageId: item.imageUrl.isNotEmpty ? item.imageUrl : null,
    isExclusive: item.inclusive,
    allowDecimal: item.allowDecimal,
  );
}
