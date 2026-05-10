import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

Future<Uint8List?> convertPdfToImage(String pdfPath) async {
  try {
    // Load the PDF file as bytes
    final File pdfFile = File(pdfPath);
    final Uint8List pdfBytes = await pdfFile.readAsBytes();

    // Rasterize the first page of the PDF at 300 DPI (high quality)
    final Stream<PdfRaster> pdfRasterStream =
        Printing.raster(pdfBytes, dpi: 300);

    // Convert the stream into a list of images
    List<Uint8List> imageList = [];

    await for (final PdfRaster raster in pdfRasterStream) {
      final img = await raster.toPng();
      imageList.add(img); // Convert rasterized page to PNG (Uint8List)
    }

    // Return the first page as Uint8List
    return imageList.isNotEmpty ? imageList.first : null;
  } catch (e) {
    print('Error converting PDF to image: $e');
    return null;
  }
}

class ShowPdf extends StatelessWidget {
  const ShowPdf({super.key});

  Future<File> fileBuilder() async {
    Directory? externalDir = await getApplicationDocumentsDirectory();
    String downloadsPath = '${externalDir.path}/downloads';

    // Load and process the PDF file
    final File pdfFile = File('$downloadsPath/cashier_report.pdf');

    return pdfFile;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text(' Invoice PDF'),
        ),
        backgroundColor: Colors.grey,
        body: FutureBuilder(
            future: fileBuilder(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return SfPdfViewer.file(snapshot.data!);
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            }));
  }
}
