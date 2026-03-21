import 'package:cloud_firestore/cloud_firestore.dart';

class TrainingAssignment {
  const TrainingAssignment({
    required this.id,
    required this.userId,
    required this.trainingId,
    required this.source,
    required this.assignedAt,
    required this.dueAt,
    this.templateId,
    this.completedAt,
    this.updatedAt,
  });

  final String id;
  final String userId;
  final String trainingId;
  final String source;
  final String? templateId;
  final DateTime assignedAt;
  final DateTime dueAt;
  final DateTime? completedAt;
  final DateTime? updatedAt;

  factory TrainingAssignment.fromMap(String id, Map<String, dynamic> map) {
    DateTime convert(dynamic value) {
      if (value is Timestamp) return value.toDate();
      return value as DateTime? ?? DateTime.now();
    }

    DateTime? convertNullable(dynamic value) {
      if (value is Timestamp) return value.toDate();
      return value as DateTime?;
    }

    return TrainingAssignment(
      id: id,
      userId: (map['userId'] ?? '') as String,
      trainingId: (map['trainingId'] ?? '') as String,
      source: (map['source'] ?? 'manual') as String,
      templateId: map['templateId'] as String?,
      assignedAt: convert(map['assignedAt']),
      dueAt: convert(map['dueAt']),
      completedAt: convertNullable(map['completedAt']),
      updatedAt: convertNullable(map['updatedAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'trainingId': trainingId,
      'source': source,
      'templateId': templateId,
      'assignedAt': assignedAt,
      'dueAt': dueAt,
      'completedAt': completedAt,
      'updatedAt': updatedAt,
    };
  }

  bool get isOverdue => dueAt.isBefore(DateTime.now());

  TrainingAssignment copyWith({
    String? id,
    String? userId,
    String? trainingId,
    String? source,
    String? templateId,
    DateTime? assignedAt,
    DateTime? dueAt,
    DateTime? completedAt,
    DateTime? updatedAt,
  }) {
    return TrainingAssignment(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      trainingId: trainingId ?? this.trainingId,
      source: source ?? this.source,
      templateId: templateId ?? this.templateId,
      assignedAt: assignedAt ?? this.assignedAt,
      dueAt: dueAt ?? this.dueAt,
      completedAt: completedAt ?? this.completedAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
