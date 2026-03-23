import 'package:flutter/foundation.dart';

import '../models/app_user.dart';
import '../models/user_role.dart';
import '../repositories/training_repository.dart';

class AuthService extends ChangeNotifier {
  AuthService({TrainingRepository? trainingRepository})
      : _trainingRepository = trainingRepository ?? TrainingRepository() {
    // Initialize with mock user for development
    _initializeMockUser();
  }

  final TrainingRepository _trainingRepository;
  AppUser? _currentUser;

  AppUser? get currentUser => _currentUser;

  UserRole? get currentUserRole => _currentUser?.role;

  bool get isLoggedIn => _currentUser != null;

  bool get isAdmin => _currentUser?.role == UserRole.admin;

  /// Initialize with a mock admin user for development
  void _initializeMockUser() {
    _currentUser = AppUser(
      id: 'mock-admin-user',
      name: 'Admin User',
      building: 'HQ',
      account: 'Admin Account',
      email: 'admin@gtrain.local',
      templateIds: [],
      role: UserRole.admin,
      defaultBuilding: 'HQ',
      defaultAccount: 'Admin Account',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    notifyListeners();
  }

  /// Set the current user (used after login)
  void setCurrentUser(AppUser user) {
    _currentUser = user;
    notifyListeners();
  }

  /// Update user's default building and account
  Future<void> updateUserDefaults({
    required String building,
    required String account,
  }) async {
    if (_currentUser == null) return;

    _currentUser = _currentUser!.copyWith(
      defaultBuilding: building,
      defaultAccount: account,
    );
    notifyListeners();

    // Persist to Firestore
    try {
      await _trainingRepository.saveUser(_currentUser!);
    } catch (e) {
      // Fallback if save fails - revert changes
      print('Error saving user defaults: $e');
    }
  }

  /// Login with email and password
  /// TODO: Implement real authentication
  Future<void> login(String email, String password) async {
    // Placeholder for real authentication
    // This will be connected to Firebase Auth later
  }

  /// Logout
  Future<void> logout() async {
    _currentUser = null;
    notifyListeners();
  }

  /// Switch to a different user for testing (remove in production)
  void switchUserForTesting(AppUser user) {
    _currentUser = user;
    notifyListeners();
  }
}
