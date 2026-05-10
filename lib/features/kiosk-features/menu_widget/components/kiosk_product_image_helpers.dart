import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:kiosk_point_of_sale/core/assets/app_assets.dart';
import 'package:kiosk_point_of_sale/core/config/api_config.dart';
import 'package:kiosk_point_of_sale/data/models/sync_product/sync_product_model.dart';

Widget buildSyncProductImage(SyncProduct product, {double? width, double? height}) {
  return CachedNetworkImage(
    width: width ?? double.infinity,
    height: height,
    imageUrl: '${ApiConfig.baseUrl ?? ''}/Images/${product.imageUrl}',
    fit: BoxFit.cover,
    placeholder: (context, url) => const Center(
      child: CircularProgressIndicator(
        color: Colors.white,
        strokeWidth: 2,
        backgroundColor: Colors.grey,
        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
      ),
    ),
    errorWidget: (context, url, error) => Image.asset(
      AppAssets.productImagePlaceholder,
      fit: BoxFit.cover,
      width: width ?? double.infinity,
      height: height,
    ),
  );
}

Widget buildImage(String imageUrl, {double? width, double? height}) {
  return CachedNetworkImage(
    width: width,
    height: height,
    imageUrl: '${ApiConfig.baseUrl}/Images/$imageUrl',
    fit: BoxFit.cover,
    placeholder: (context, url) => const Center(
      child: CircularProgressIndicator(
        color: Colors.white,
        strokeWidth: 2,
        backgroundColor: Colors.white,
        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
      ),
    ),
    errorWidget: (context, url, error) => Image.asset(
      AppAssets.productImagePlaceholder,
      fit: BoxFit.cover,
      width: width ?? double.infinity,
      height: height,
    ),
  );
}
