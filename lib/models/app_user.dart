import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  const AppUser({
    required this.id,
    required this.name,
    required this.building,
    required this.account,
    required this.email,
    required this.templateIds,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String name;
  final String building;
  final String account;
  final String email;
  final List<String> templateIds;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory AppUser.empty() => const AppUser(
        id: '',
        name: '',
        building: '',
        account: '',
        email: '',
        templateIds: [],
      );

  factory AppUser.fromMap(String id, Map<String, dynamic> map) {
    DateTime? convert(dynamic value) {
      if (value is Timestamp) return value.toDate();
      return value as DateTime?;
    }

    return AppUser(
      id: id,
      name: (map['name'] ?? '') as String,
      building: (map['building'] ?? '') as String,
      account: (map['account'] ?? '') as String,
      email: (map['email'] ?? '') as String,
      templateIds: List<String>.from(map['templateIds'] ?? const []),
      createdAt: convert(map['createdAt']),
      updatedAt: convert(map['updatedAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'building': building,
      'account': account,
      'email': email,
      'templateIds': templateIds,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  AppUser copyWith({
    String? id,
    String? name,
    String? building,
    String? account,
    String? email,
    List<String>? templateIds,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AppUser(
      id: id ?? this.id,
      name: name ?? this.name,
      building: building ?? this.building,
      account: account ?? this.account,
      email: email ?? this.email,
      templateIds: templateIds ?? this.templateIds,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
