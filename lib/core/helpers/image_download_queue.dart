

class ImageDownloadQueue {
  static final ImageDownloadQueue _instance = ImageDownloadQueue._internal();

  factory ImageDownloadQueue() => _instance;

  ImageDownloadQueue._internal();

  final Map<String, Future<void>> _queue = {};

  Future<void> addToQueue(String productId, String imageUrl) async {
    if (!_queue.containsKey(productId)) {
      _queue[productId] = _downloadAndSaveImage(productId, imageUrl);
    }
    return _queue[productId];
  }

  Future<void> _downloadAndSaveImage(String productId, String imageUrl) async {
    // try {
    //   final file = await ImageFileHelper.downloadAndSaveImage(imageUrl);
    //   if (file != null) {
    //     var product = await MenuItemsTable.getProductById(productId);
    //     if (product == null) return;
    //     await MenuItemsTable.updateWithQuery(
    //         product: product, query: 'imagePath');
    //     dPrint(
    //         'Image downloaded and saved for product $productId: ${file.path}');
    //   }
    // } catch (e) {
    //   dPrint('Error downloading image for product $productId: $e');
    // } finally {
    //   _queue.remove(productId);
    // }
  }
}
