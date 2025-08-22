import 'package:flutter_quill/flutter_quill.dart' as quill;

class TimestampedNote {
  TimestampedNote({
    required this.milliseconds,
    required this.document,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  final int milliseconds;
  final quill.Document document;
  final DateTime createdAt;

  String get plainText => document.toPlainText();

  Map<String, dynamic> toJson() {
    return {
      'milliseconds': milliseconds,
      'delta': document.toDelta().toJson(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  static TimestampedNote fromJson(Map<String, dynamic> json) {
    final dynamic deltaJson = json['delta'];
    final quill.Document doc = quill.Document.fromJson(deltaJson as List<dynamic>);
    return TimestampedNote(
      milliseconds: json['milliseconds'] as int,
      document: doc,
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
    );
  }
}


