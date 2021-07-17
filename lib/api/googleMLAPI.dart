import 'dart:io';

// import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';

class googleMLAPI {
  static Future<String> recogniseText(File imageFile) async {
    final inputImage = InputImage.fromFile(imageFile);
    final textDetector = GoogleMlKit.vision.textDetector();
    try {
      final RecognisedText recognisedText =
          await textDetector.processImage(inputImage);
      await textDetector.close();

      String text = extractText(recognisedText);
      return text.isEmpty ? 'No text found in the image' : text;
    } catch (error) {
      return error.toString();
    }
  }

  static extractText(RecognisedText recognisedText) {
    // String text = recognisedText.text;
    dynamic res = '';
    for (TextBlock block in recognisedText.blocks) {
      // final Rect rect = block.rect;
      // final List<Offset> cornerPoints = block.cornerPoints;
      // final String text = block.text;
      // final List<String> languages = block.recognizedLanguages;

      for (TextLine line in block.lines) {
        // Same getters as TextBlock
        for (TextElement word in line.elements) {
          res = res + word.text + ' ';
        }
        res = res + '\n';
      }
    }
    return res;
  }
}
