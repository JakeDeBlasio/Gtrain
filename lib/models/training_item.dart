import 'package:cloud_firestore/cloud_firestore.dart';

enum RenewalMode { byCompletion, fixedDate }

extension RenewalModeParsing on RenewalMode {
  String get wireValue => switch (this) {
        RenewalMode.byCompletion => 'by_completion',
        RenewalMode.fixedDate => 'fixed_date',
      };

  String get label => switch (this) {
        RenewalMode.byCompletion => 'By completion date',
        RenewalMode.fixedDate => 'On fixed date',
      };

  static RenewalMode fromWireValue(String value) {
    return switch (value) {
      'fixed_date' => RenewalMode.fixedDate,
      _ => RenewalMode.byCompletion,
    };
  }
}

class TrainingItem {
  const TrainingItem({
    required this.id,
    required this.title,
    required this.description,
    required this.renewalIntervalMonths,
    required this.renewalMode,
    required this.documentName,
    required this.documentUrl,
    required this.documentPath,
    this.fixedMonth,
    this.fixedDay,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String title;
  final String description;
  final int renewalIntervalMonths;
  final RenewalMode renewalMode;
  final int? fixedMonth;
  final int? fixedDay;
  final String? documentName;
  final String? documentUrl;
  final String? documentPath;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory TrainingItem.empty() => const TrainingItem(
        id: '',
        title: '',
        description: '',
        renewalIntervalMonths: 12,
        renewalMode: RenewalMode.byCompletion,
        documentName: null,
        documentUrl: null,
        documentPath: null,
      );

  factory TrainingItem.fromMap(String id, Map<String, dynamic> map) {
    DateTime? convert(dynamic value) {
      if (value is Timestamp) return value.toDate();
      return value as DateTime?;
    }

    return TrainingItem(
      id: id,
      title: (map['title'] ?? '') as String,
      description: (map['description'] ?? '') as String,
      renewalIntervalMonths: (map['renewalIntervalMonths'] ?? 12) as int,
      renewalMode: RenewalModeParsing.fromWireValue(
        (map['renewalMode'] ?? 'by_completion') as String,
      ),
      fixedMonth: map['fixedMonth'] as int?,
      fixedDay: map['fixedDay'] as int?,
      documentName: map['documentName'] as String?,
      documentUrl: map['documentUrl'] as String?,
      documentPath: map['documentPath'] as String?,
      createdAt: convert(map['createdAt']),
      updatedAt: convert(map['updatedAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'renewalIntervalMonths': renewalIntervalMonths,
      'renewalMode': renewalMode.wireValue,
      'fixedMonth': fixedMonth,
      'fixedDay': fixedDay,
      'documentName': documentName,
      'documentUrl': documentUrl,
      'documentPath': documentPath,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  TrainingItem copyWith({
    String? id,
    String? title,
    String? description,
    int? renewalIntervalMonths,
    RenewalMode? renewalMode,
    int? fixedMonth,
    int? fixedDay,
    String? documentName,
    String? documentUrl,
    String? documentPath,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TrainingItem(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      renewalIntervalMonths: renewalIntervalMonths ?? this.renewalIntervalMonths,
      renewalMode: renewalMode ?? this.renewalMode,
      fixedMonth: fixedMonth ?? this.fixedMonth,
      fixedDay: fixedDay ?? this.fixedDay,
      documentName: documentName ?? this.documentName,
      documentUrl: documentUrl ?? this.documentUrl,
      documentPath: documentPath ?? this.documentPath,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
