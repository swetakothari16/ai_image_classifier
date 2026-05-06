import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'classifier_model.dart';
import 'image_processor.dart';

/// The main class for running image classification using TFLite.
class AiImageClassifier {
  Interpreter? _interpreter;
  List<String>? _labels;

  /// Returns true if the model and labels are loaded.
  bool get isLoaded => _interpreter != null && _labels != null;

  /// Loads the TFLite model and labels from assets.
  ///
  /// [modelPath] Path to the .tflite file in assets.
  /// [labelsPath] Path to the labels.txt file in assets.
  Future<void> loadModel({
    required String modelPath,
    required String labelsPath,
    InterpreterOptions? options,
  }) async {
    try {
      _interpreter = await Interpreter.fromAsset(modelPath, options: options);
      
      final labelsData = await rootBundle.loadString(labelsPath);
      _labels = labelsData.split('\n').where((s) => s.isNotEmpty).toList();
      
      debugPrint("Model and labels loaded successfully.");
    } catch (e) {
      debugPrint("Error loading model: $e");
      rethrow;
    }
  }

  /// Classifies an image from raw bytes.
  ///
  /// [imageBytes] The bytes of the image to classify.
  /// [topK] Number of top results to return.
  Future<List<Classification>> classifyImage(
    Uint8List imageBytes, {
    int topK = 5,
    int inputSize = 224,
    double mean = 127.5,
    double std = 127.5,
  }) async {
    if (!isLoaded) {
      throw Exception("Model not loaded. Call loadModel() first.");
    }

    // 1. Preprocess image
    final input = ImageProcessor.processImage(
      imageBytes,
      inputSize: inputSize,
      mean: mean,
      std: std,
    );

    // 2. Prepare output buffer
    // MobileNet usually has 1001 or 1000 classes.
    // We get the shape from the interpreter.
    var outputShape = _interpreter!.getOutputTensors().first.shape;
    
    // Create output list based on shape [1, num_classes]
    var output = List<double>.filled(outputShape.last, 0).reshape(outputShape);

    // 3. Run inference
    _interpreter!.run(input.reshape([1, inputSize, inputSize, 3]), output);

    // 4. Post-process results
    List<double> probabilities = List<double>.from(output[0]);
    List<Classification> results = [];

    for (int i = 0; i < probabilities.length; i++) {
      if (i < _labels!.length) {
        results.add(Classification(
          label: _labels![i],
          confidence: probabilities[i],
          index: i,
        ));
      }
    }

    // Sort by confidence descending
    results.sort((a, b) => b.confidence.compareTo(a.confidence));

    return results.take(topK).toList();
  }

  /// Classifies an image from a file path.
  Future<List<Classification>> classifyImagePath(
    String path, {
    int topK = 5,
    int inputSize = 224,
    double mean = 127.5,
    double std = 127.5,
  }) async {
    final bytes = await File(path).readAsBytes();
    return classifyImage(
      bytes,
      topK: topK,
      inputSize: inputSize,
      mean: mean,
      std: std,
    );
  }

  /// Closes the interpreter and releases resources.
  void dispose() {
    _interpreter?.close();
    _interpreter = null;
    _labels = null;
  }
}
