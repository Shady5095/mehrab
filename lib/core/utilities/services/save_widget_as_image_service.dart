import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';

class SaveWidgetAsImageService {
  static Future<Uint8List> takeScreenshot({
    double pixelRatio = 3.0,
    required GlobalKey globalKey,
    double cropAmount = 0, // Crop amount in logical pixels (before scaling)
  }) async {
    final boundary =
        globalKey.currentContext?.findRenderObject() as RenderRepaintBoundary;

    // Capture the widget as an image
    final ui.Image originalImage = await boundary.toImage(
      pixelRatio: pixelRatio,
    );

    // Get original dimensions
    final int originalWidth = originalImage.width;
    final int originalHeight = originalImage.height;

    // Calculate crop values in actual pixels (scaled by pixel ratio)
    final int cropPixels = (cropAmount * pixelRatio).toInt();

    // Ensure the crop amount doesn't exceed the image size
    final int newWidth = (originalWidth - cropPixels * 2).clamp(
      1,
      originalWidth,
    );
    final int newHeight = (originalHeight - cropPixels * 2).clamp(
      1,
      originalHeight,
    );

    // Create a new image with transparent background
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(
      recorder,
      Rect.fromPoints(
        const Offset(0, 0),
        Offset(newWidth.toDouble(), newHeight.toDouble()),
      ),
    );

    // Make the background transparent by drawing with a fully transparent color
    canvas.drawColor(
      Colors.white,
      ui.BlendMode.srcOver,
    ); // Transparent background

    // Draw the cropped portion of the original image
    final srcRect = Rect.fromLTWH(
      cropPixels.toDouble(), // Start cropping from the left
      cropPixels.toDouble(), // Start cropping from the top
      newWidth.toDouble(), // New width after cropping
      newHeight.toDouble(), // New height after cropping
    );

    final destRect = Rect.fromLTWH(
      0,
      0,
      newWidth.toDouble(),
      newHeight.toDouble(),
    );

    canvas.drawImageRect(originalImage, srcRect, destRect, Paint());

    // Convert to an image
    final croppedImage = await recorder.endRecording().toImage(
      newWidth,
      newHeight,
    );

    // Convert to Uint8List
    final byteData = await croppedImage.toByteData(
      format: ui.ImageByteFormat.png,
    );
    return byteData!.buffer.asUint8List();
  }

  static Future<String> saveImage(Uint8List bytes) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    String path = '';
    try {
      final Directory root = await getTemporaryDirectory();
      final String directoryPath = '${root.path}/Learnovia';
      // Create the directory if it doesn't exist
      await Directory(directoryPath).create(recursive: true);
      final String filePath = '$directoryPath/$timestamp.jpg';
      final file = await File(filePath).writeAsBytes(bytes);
      path = file.path;
    } catch (e) {
      debugPrint(e.toString());
    }
    return path;
  }
}
