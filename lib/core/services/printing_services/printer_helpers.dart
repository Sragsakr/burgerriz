import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:kiosk_point_of_sale/main.dart';
import 'package:image/image.dart' as img;
import 'package:pdf/widgets.dart' as pw;

class PrinterHelpers {
  static Future<Uint8List?> createImageFromRepaintBoundary(
    GlobalKey boundaryKey, {
    double? pixelRatio,
    Size? imageSize,
  }) async {
    assert(
      boundaryKey.currentContext?.findRenderObject() is RenderRepaintBoundary,
    );
    final RenderRepaintBoundary boundary =
        boundaryKey.currentContext?.findRenderObject() as RenderRepaintBoundary;
    final BoxConstraints constraints = boundary.constraints;
    double? outputRatio = pixelRatio;
    if (imageSize != null) {
      outputRatio = imageSize.width / constraints.maxWidth;
    }
    final ui.Image image = await boundary.toImage(
      pixelRatio:
          outputRatio ?? MediaQueryData.fromView(ui.window).devicePixelRatio,
    );
    final ByteData? byteData = await image.toByteData(
      format: ui.ImageByteFormat.png,
    );
    final Uint8List? imageData = byteData?.buffer.asUint8List();
    return imageData;
  }

  static Future<ui.Image> createImageFromWidget(Widget widget,
      {Duration? wait, Size? logicalSize, Size? imageSize}) async {
    var cxt = navKey.currentState!.context;
// Create a repaint boundary to capture the image
    final repaintBoundary = RenderRepaintBoundary();

// Calculate logicalSize and imageSize if not provided
    logicalSize ??= View.of(cxt).physicalSize / View.of(cxt).devicePixelRatio;
    imageSize ??= View.of(cxt).physicalSize;

// Ensure logicalSize and imageSize have the same aspect ratio
    assert(logicalSize.aspectRatio == imageSize.aspectRatio,
        'logicalSize and imageSize must not be the same');

// Create the render tree for capturing the widget as an image
    final renderView = RenderView(
      view: View.of(cxt),
      child: RenderPositionedBox(
          alignment: Alignment.center, child: repaintBoundary),
      configuration: const ViewConfiguration(
        logicalConstraints: BoxConstraints(),
        devicePixelRatio: 1,
      ),
    );

    final pipelineOwner = PipelineOwner();
    final buildOwner = BuildOwner(focusManager: FocusManager());

    pipelineOwner.rootNode = renderView;
    renderView.prepareInitialFrame();

// Attach the widget's render object to the render tree
    final rootElement = RenderObjectToWidgetAdapter<RenderBox>(
        container: repaintBoundary,
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: widget,
        )).attachToRenderTree(buildOwner);

    buildOwner.buildScope(rootElement);

// Delay if specified
    if (wait != null) {
      await Future.delayed(wait);
    }

// Build and finalize the render tree
    buildOwner
      ..buildScope(rootElement)
      ..finalizeTree();

// Flush layout, compositing, and painting operations
    pipelineOwner
      ..flushLayout()
      ..flushCompositingBits()
      ..flushPaint();

// Capture the image and convert it to byte data
    final image = await repaintBoundary.toImage(
        pixelRatio: imageSize.width / logicalSize.width);
    return image;
//     final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
//
// // Return the image data as Uint8List
//     return byteData?.buffer.asUint8List();
  }

  static Future<pw.Image> createPWImageFromWidget(
    Widget widget, {
    Duration? wait,
    Size? logicalSize,
    Size? imageSize,
  }) async {
    final RenderRepaintBoundary repaintBoundary = RenderRepaintBoundary();
    var cxt = navKey.currentState!.context;

    logicalSize ??= View.of(cxt).physicalSize / View.of(cxt).devicePixelRatio;
    imageSize ??= View.of(cxt).physicalSize;

    final RenderView renderView = RenderView(
      view: ui.window,
      child: RenderPositionedBox(
        alignment: Alignment.center,
        child: repaintBoundary,
      ),
      configuration: const ViewConfiguration(
        logicalConstraints: BoxConstraints(),
        devicePixelRatio: 1,
      ),
    );

    final PipelineOwner pipelineOwner = PipelineOwner();
    final BuildOwner buildOwner = BuildOwner(focusManager: FocusManager());

    pipelineOwner.rootNode = renderView;
    renderView.prepareInitialFrame();

    final RenderObjectToWidgetElement<RenderBox> rootElement =
        RenderObjectToWidgetAdapter<RenderBox>(
      container: repaintBoundary,
      child: widget,
    ).attachToRenderTree(buildOwner);

    buildOwner.buildScope(rootElement);

    if (wait != null) {
      await Future<void>.delayed(wait);
    }

    buildOwner.buildScope(rootElement);
    buildOwner.finalizeTree();

    pipelineOwner.flushLayout();
    pipelineOwner.flushCompositingBits();
    pipelineOwner.flushPaint();

    final ui.Image image = await repaintBoundary.toImage(pixelRatio: 3);
    ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    Uint8List pngBytes = byteData!.buffer.asUint8List();
    return pw.Image(pw.MemoryImage(pngBytes));
  }

  static Future<pw.Image> fromUiImageToPwImage(ui.Image uiImage) async {
    ByteData? byteData =
        await uiImage.toByteData(format: ui.ImageByteFormat.png);
    Uint8List pngBytes = byteData!.buffer.asUint8List();
    return pw.Image(pw.MemoryImage(pngBytes));
  }

  static Future<img.Image> convertFlutterUiToImage(ui.Image uiImage) async {
    final uiBytes = await uiImage.toByteData();

    final image = img.Image.fromBytes(
      width: uiImage.width,
      height: uiImage.height,
      bytes: uiBytes!.buffer,
      numChannels: 4,
    );

    return image;
  }
}
