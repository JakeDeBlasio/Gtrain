import 'package:cloud_firestore/cloud_firestore.dart';

import 'user_role.dart';

class AppUser {
  const AppUser({
    required this.id,
    required this.name,
    required this.building,
    required this.account,
    required this.email,
    required this.templateIds,
    required this.role,
    this.supervisorId,
    this.defaultBuilding,
    this.defaultAccount,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String name;
  final String building;
  final String account;
  final String email;
  final List<String> templateIds;
  final UserRole role;
  final String? supervisorId; // User ID of the supervisor
  final String? defaultBuilding; // User's preferred default location
  final String? defaultAccount;  // User's preferred default account
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory AppUser.empty() => const AppUser(
        id: '',
        name: '',
        building: '',
        account: '',
        email: '',
        templateIds: [],
        role: UserRole.user,
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
      role: UserRole.fromString(map['role'] as String?),
      supervisorId: map['supervisorId'] as String?,
      defaultBuilding: map['defaultBuilding'] as String?,
      defaultAccount: map['defaultAccount'] as String?,
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
      'role': role.toStorageString(),
      'supervisorId': supervisorId,
      'defaultBuilding': defaultBuilding,
      'defaultAccount': defaultAccount,
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
    UserRole? role,
    String? supervisorId,
    String? defaultBuilding,
    String? defaultAccount,
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
      role: role ?? this.role,
      supervisorId: supervisorId ?? this.supervisorId,
      defaultBuilding: defaultBuilding ?? this.defaultBuilding,
      defaultAccount: defaultAccount ?? this.defaultAccount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
