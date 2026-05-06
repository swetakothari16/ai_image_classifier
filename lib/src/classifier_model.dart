/// Represents a single classification result from the AI model.
class Classification {
  /// The label assigned by the model (e.g., "dog", "cat").
  final String label;

  /// The confidence score of the prediction (between 0.0 and 1.0).
  final double confidence;

  /// The index of the label in the labels file.
  final int index;

  Classification({
    required this.label,
    required this.confidence,
    required this.index,
  });

  @override
  String toString() => 'Classification(label: $label, confidence: ${confidence.toStringAsFixed(2)})';

  /// Converts the classification result to a map.
  Map<String, dynamic> toJson() {
    return {
      'label': label,
      'confidence': confidence,
      'index': index,
    };
  }
}
