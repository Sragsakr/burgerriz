import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kiosk_point_of_sale/data/models/promotions/models/promotion_vm.dart';

final appliedPromotionsProvider = StateProvider<List<PromotionVM>>((ref) => []);

/// Incremented after background sync refreshes promotion SQLite tables so UI can rebuild.
final promotionCatalogRevisionProvider = StateProvider<int>((ref) => 0);
