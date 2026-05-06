# AI Image Classifier
A Flutter package for easy on-device image classification using TensorFlow Lite models.

## Features
- Load TFLite models from assets.
- Classify images from bytes or file paths.
- Automatic image preprocessing (resizing and normalization).
- Works with common classification models like MobileNet, ResNet, etc.

## Getting Started

### 1. Add Dependencies
Add `ai_image_classifier` to your `pubspec.yaml`:
```yaml
dependencies:
  ai_image_classifier:
    git:
      url: https://github.com/swetakothari16/ai_image_classifier.git
```

### 2. Add Model and Labels
Place your `.tflite` model and `labels.txt` in your assets folder and register them:
```yaml
flutter:
  assets:
    - assets/models/mobilenet_v1.tflite
    - assets/models/labels.txt
```

### 3. Usage

```dart
import 'package:ai_image_classifier/ai_image_classifier.dart';

final classifier = AiImageClassifier();

// Load model
await classifier.loadModel(
  modelPath: 'assets/models/mobilenet_v1.tflite',
  labelsPath: 'assets/models/labels.txt',
);

// Classify image from path
List<Classification> results = await classifier.classifyImagePath(imagePath);

// Print results
for (var res in results) {
  print("${res.label}: ${(res.confidence * 100).toStringAsFixed(1)}%");
}

// Dispose when done
classifier.dispose();
```

## How to get a sample model?
You can download a pre-trained MobileNet model from TensorFlow Hub:
1. Go to [TensorFlow Hub MobileNet](https://tfhub.dev/s?q=mobilenet%20tflite).
2. Download the `.tflite` file.
3. Use the ImageNet labels provided in the example app's `labels.txt`.

## License
MIT
