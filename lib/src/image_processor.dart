import 'dart:typed_data';
import 'package:image/image.dart' as img;

/// Utility class for processing images before passing them to the TFLite model.
class ImageProcessor {
  /// Resizes and normalizes an image for the TFLite model.
  ///
  /// [imageBytes] The raw bytes of the image.
  /// [inputSize] The expected input size of the model (e.g., 224 for 224x224).
  /// [mean] The mean value for normalization (usually 127.5).
  /// [std] The standard deviation for normalization (usually 127.5).
  static Float32List processImage(
    Uint8List imageBytes, {
    int inputSize = 224,
    double mean = 127.5,
    double std = 127.5,
  }) {
    // Decode the image
    img.Image? image = img.decodeImage(imageBytes);
    if (image == null) throw Exception("Failed to decode image");

    // Resize the image to the model's input size
    img.Image resizedImage = img.copyResize(
      image,
      width: inputSize,
      height: inputSize,
    );

    // Create a Float32List to hold the normalized pixel values
    // Most TFLite models expect input in [1, inputSize, inputSize, 3] shape
    var input = Float32List(1 * inputSize * inputSize * 3);
    var buffer = Float32List.view(input.buffer);

    int pixelIndex = 0;
    for (int y = 0; y < inputSize; y++) {
      for (int x = 0; x < inputSize; x++) {
        var pixel = resizedImage.getPixel(x, y);

        // Normalize R, G, B values
        // image package pixel values are often accessed via .r, .g, .b (newer versions)
        // or via bitwise operations in older versions.
        // In image 4.x, we use pixel.r, pixel.g, pixel.b
        buffer[pixelIndex++] = (pixel.r - mean) / std;
        buffer[pixelIndex++] = (pixel.g - mean) / std;
        buffer[pixelIndex++] = (pixel.b - mean) / std;
      }
    }

    return input;
  }
}
