import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:ai_image_classifier/src/image_processor.dart';

void main() {
  group('ImageProcessor Tests', () {
    test('processImage should return correct buffer size', () {
      // Create a dummy image (10x10 red square)
      final dummyImage = img.Image(width: 10, height: 10);
      for (var pixel in dummyImage) {
        pixel.r = 255;
        pixel.g = 0;
        pixel.b = 0;
      }
      final imageBytes = Uint8List.fromList(img.encodePng(dummyImage));

      const inputSize = 224;
      final result = ImageProcessor.processImage(
        imageBytes,
        inputSize: inputSize,
      );

      // Expected size: 1 * 224 * 224 * 3 channels
      expect(result.length, 1 * inputSize * inputSize * 3);
    });

    test('processImage normalization should work correctly', () {
      // Create a pure white pixel image
      final dummyImage = img.Image(width: 1, height: 1);
      dummyImage.setPixelRgb(0, 0, 255, 255, 255);
      final imageBytes = Uint8List.fromList(img.encodePng(dummyImage));

      const inputSize = 1; // Simplify for testing
      // mean=127.5, std=127.5
      // (255 - 127.5) / 127.5 = 1.0
      final result = ImageProcessor.processImage(
        imageBytes,
        inputSize: inputSize,
        mean: 127.5,
        std: 127.5,
      );

      expect(result[0], closeTo(1.0, 0.001)); // Red channel
      expect(result[1], closeTo(1.0, 0.001)); // Green channel
      expect(result[2], closeTo(1.0, 0.001)); // Blue channel
    });

    test('processImage with dark image should return negative normalized values', () {
      // Create a pure black pixel image
      final dummyImage = img.Image(width: 1, height: 1);
      dummyImage.setPixelRgb(0, 0, 0, 0, 0);
      final imageBytes = Uint8List.fromList(img.encodePng(dummyImage));

      const inputSize = 1;
      // (0 - 127.5) / 127.5 = -1.0
      final result = ImageProcessor.processImage(
        imageBytes,
        inputSize: inputSize,
        mean: 127.5,
        std: 127.5,
      );

      expect(result[0], closeTo(-1.0, 0.001));
    });
  });
}
