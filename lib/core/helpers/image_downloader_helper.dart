import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

class ImageFileHelper {
  static Future<String> get _directoryPath async {
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/product_images';
    await Directory(path).create(recursive: true);
    return path;
  }

  static Future<String> getImagePath(String imageUrl) async {
    final directory = await _directoryPath;
    return '$directory/${imageUrl.replaceAll('/', '_')}';
  }

  static Future<File?> downloadAndSaveImage(String imageUrl) async {
    try {
      final response = await http.get(Uri.parse('https://uatapi.posmena.com/Images/$imageUrl'));

      if (response.statusCode == 200) {
        final imagePath = await getImagePath(imageUrl);
        final file = File(imagePath);
        await file.writeAsBytes(response.bodyBytes);
        print('Image saved to: $imagePath');
        return file;
      }
    } catch (e) {
      print('Error downloading/saving image: $e');
    }
    return null;
  }
}
