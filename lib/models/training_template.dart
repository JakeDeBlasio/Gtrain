import 'package:cloud_firestore/cloud_firestore.dart';

class TrainingTemplate {
  const TrainingTemplate({
    required this.id,
    required this.name,
    required this.description,
    required this.trainingIds,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String name;
  final String description;
  final List<String> trainingIds;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory TrainingTemplate.empty() => const TrainingTemplate(
        id: '',
        name: '',
        description: '',
        trainingIds: [],
      );

  factory TrainingTemplate.fromMap(String id, Map<String, dynamic> map) {
    DateTime? convert(dynamic value) {
      if (value is Timestamp) return value.toDate();
      return value as DateTime?;
    }

    return TrainingTemplate(
      id: id,
      name: (map['name'] ?? '') as String,
      description: (map['description'] ?? '') as String,
      trainingIds: List<String>.from(map['trainingIds'] ?? const []),
      createdAt: convert(map['createdAt']),
      updatedAt: convert(map['updatedAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'trainingIds': trainingIds,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  TrainingTemplate copyWith({
    String? id,
    String? name,
    String? description,
    List<String>? trainingIds,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TrainingTemplate(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      trainingIds: trainingIds ?? this.trainingIds,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
